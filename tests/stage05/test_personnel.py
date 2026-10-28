import os,json,urllib.request,urllib.error,csv,io
from datetime import datetime,timedelta
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0].replace("cmd('SELECT',2)","cmd('SELECT',3)"))
admin=login('s2_a_admin');hr=login('s2_a_hr');bad=login('s2_b_admin');emp=login('s2_a_employee');a=login('s4_applicant');other=login('s4_other')
body={'companyId':1,'realName':'档案测试员工','contactPhone':'13800000001','jobTitle':'测试岗位'}
id=api('/employees/applications',a,'POST',body)['data'];api(f'/employees/applications/{id}/submit',a,'POST');api(f'/employees/applications/{id}/review',admin,'POST',{'approve':True,'opinion':'同意'});a=login('s4_applicant');profile=api('/employees/me',a)['data'];eid=profile['id'];user=profile['user_id']
check('人事仅查本企业人员',all(x['company_id']==1 for x in api('/personnel',hr)['data']['rows']))
check('管理员可查人员详情',api(f'/personnel/{eid}',admin).get('code')==200)
check('其他企业详情拒绝',api(f'/personnel/{eid}',bad).get('code')==404)
check('普通员工无人员管理权',api('/personnel',emp).get('code')==403)
check('人员状态筛选',all(x['status']=='ACTIVE' for x in api('/personnel?status=ACTIVE',hr)['data']['rows']))
check('门禁员工可按账号编号搜索',any(x['user_id']==user for x in api('/personnel?keyword='+str(user),hr)['data']['rows']))
check('状态值校验',api('/personnel?status=DELETED',hr).get('code')==400)
check('分页范围校验',api('/personnel?pageSize=999',hr).get('code')==400)
check('本企业人员统计',api('/personnel/stats',hr)['data']['active']==6)
payload={**body,'realName':'=2+2','employeeNo':'TEST-NEW','version':profile['version']}
check('人事维护档案',api(f'/personnel/{eid}',hr,'PUT',{'data':payload,'reason':'修改测试'}).get('code')==200)
check('历史版本更新拒绝',api(f'/personnel/{eid}',hr,'PUT',{'data':payload,'reason':'旧版'}).get('code')==409)
check('跨企业修改拒绝',api(f'/personnel/{eid}',bad,'PUT',{'data':payload,'reason':'越权'}).get('code')==404)
check('人员修改轨迹',len(api(f'/personnel/history/EMPLOYEE/{eid}',hr)['data'])==1)
def download(token):
 req=urllib.request.Request(base+'/personnel/export',headers={'Authorization':'Bearer '+token})
 try:
  with urllib.request.urlopen(req) as r:return r.status,r.read()
 except urllib.error.HTTPError as e:return e.code,e.read()
status,raw=download(hr);check('人事导出成功',status==200)
check('导出UTF8签名',raw.startswith(b'\xef\xbb\xbf'))
try:
 rows=list(csv.reader(io.StringIO(raw.decode('utf-8-sig'))));check('CSV正确分行且公式中和',len(rows)==7 and any("'=2+2" in row for row in rows))
except Exception as ex:check('CSV正确分行且公式中和',False,str(ex))
check('普通员工禁止导出',api('/personnel/export',emp).get('code')==403)
now=datetime.now();grant={'userId':user,'deviceCode':'DOOR_A_01','validFrom':(now-timedelta(days=1)).strftime('%Y-%m-%dT%H:%M:%S'),'validTo':(now+timedelta(days=30)).strftime('%Y-%m-%dT%H:%M:%S'),'reason':'入职门禁记录'}
r=api('/personnel/access',hr,'POST',grant);check('新增平台门禁记录',r.get('code')==200,r);gid=r['data']
check('重复门禁记录拒绝',api('/personnel/access',hr,'POST',grant).get('code')==409)
row=next(x for x in api('/personnel/access',hr)['data']['rows'] if x['id']==gid)
check('门禁不冒充真实设备生效',row['sync_status']=='NOT_CONNECTED' and row['record_state']=='VALID')
check('门禁无效期限拒绝',api('/personnel/access',hr,'POST',{**grant,'deviceCode':'BAD','validTo':grant['validFrom']}).get('code')==400)
check('跨企业授权员工拒绝',api('/personnel/access',bad,'POST',grant).get('code')==403)
check('普通员工无授权权',api('/personnel/access',emp,'POST',grant).get('code')==403)
check('修改授权有效期',api(f'/personnel/access/{gid}',hr,'PUT',{**grant,'version':row['version'],'reason':'延期'}).get('code')==200)
check('门禁旧版本拒绝',api(f'/personnel/access/{gid}',hr,'PUT',{**grant,'version':row['version'],'reason':'重复'}).get('code')==409)
check('门禁历史可追溯',len(api(f'/personnel/history/ACCESS/{gid}',hr)['data'])==2)
check('跨企业门禁轨迹拒绝',api(f'/personnel/history/ACCESS/{gid}',bad).get('code')==404)
row=next(x for x in api('/personnel/access',hr)['data']['rows'] if x['id']==gid)
check('撤销授权',api(f'/personnel/access/{gid}/revoke',hr,'POST',{'version':row['version'],'reason':'临时撤销'}).get('code')==200)
row=next(x for x in api('/personnel/access',hr)['data']['rows'] if x['id']==gid)
check('已撤销状态正确',row['status']=='REVOKED' and row['record_state']=='REVOKED')
check('重新记录授权',api(f'/personnel/access/{gid}',hr,'PUT',{**grant,'version':row['version'],'reason':'恢复记录'}).get('code')==200)
# Existing employee205 has an unfinished sample assignment.
existing=next(x for x in api('/personnel',hr)['data']['rows'] if x['user_id']==205)
check('未结束任务阻止离职',api(f"/personnel/{existing['id']}/leave",hr,'POST',{'version':existing['version'],'reason':'任务未完'}).get('code')==409)
check('本人离职操作拒绝',api('/personnel/1/leave',admin,'POST',{'version':0,'reason':'自离'}).get('code')==403)
p=api(f'/personnel/{eid}',hr)['data']
check('跨企业离职拒绝',api(f'/personnel/{eid}/leave',bad,'POST',{'version':p['version'],'reason':'越权'}).get('code')==404)
check('空离职原因拒绝',api(f'/personnel/{eid}/leave',hr,'POST',{'version':p['version'],'reason':''}).get('code')==400)
check('办理离职成功',api(f'/personnel/{eid}/leave',hr,'POST',{'version':p['version'],'reason':'员工离职'}).get('code')==200)
check('离职旧会话失效',api('/getInfo',a).get('code')==401)
a=login('s4_applicant');check('离职仍能登录申请入驻',api('/employees/companies',a).get('code')==200)
check('离职不保留企业业务角色',not({'company_admin','company_hr','company_business','company_finance','employee'} & set(api('/getInfo',a)['roles'])))
check('离职无企业业务数据权限',api('/biz/work_record/list',a).get('code')==403)
check('离职无本人在职资料',api('/employees/me',a).get('code')==403)
left=api(f'/personnel/{eid}',hr)['data'];check('离职状态及日期正确',left['status']=='LEFT' and left['leave_date'] is not None)
row=next(x for x in api('/personnel/access',hr)['data']['rows'] if x['id']==gid);check('离职自动撤销门禁记录',row['status']=='REVOKED' and row['sync_status']=='NOT_CONNECTED')
check('离职不可重新授权',api(f'/personnel/access/{gid}',hr,'PUT',{**grant,'version':row['version'],'reason':'违规恢复'}).get('code')==403)
check('离职统计正确',api('/personnel/stats',hr)['data']['departed']==1)
check('离职不可修改档案',api(f'/personnel/{eid}',hr,'PUT',{'data':{**payload,'version':left['version']},'reason':'修改离职'}).get('code')==409)
check('离职轨迹保存',any(x['action']=='LEAVE' for x in api(f'/personnel/history/EMPLOYEE/{eid}',hr)['data']))
check('重复离职拒绝',api(f'/personnel/{eid}/leave',hr,'POST',{'version':left['version'],'reason':'重复'}).get('code')==409)
check('无归属账号不能直接补录',api('/personnel',hr,'POST',{'userId':api('/getInfo',other)['user']['userId'],'data':{**body,'employeeNo':'NO'}}).get('code')==403)
# A missing archive may be filled only for an already approved company member.
import subprocess,re
config=(ROOT/'RuoYi-Vue-backend/ruoyi-admin/src/main/resources/application-druid.yml').read_text(encoding='utf-8-sig');env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
def sql(q):
 database=env['STAGE02_TEST_DB']
 if not database.startswith('ry_platform_s5test_'):raise RuntimeError('Dedicated test database required')
 subprocess.run(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4',database],input=q.encode('utf-8'),env=env,check=True)
otherid=api('/getInfo',other)['user']['userId']
sql(f"INSERT INTO biz_company_user(company_id,user_id,status) VALUES(1,{otherid},'ACTIVE');")
check('已授权缺档账号候选',any(x['user_id']==otherid for x in api('/personnel/candidates',hr)['data']))
check('已授权账号补录成功',api('/personnel',hr,'POST',{'userId':otherid,'data':{**body,'employeeNo':'FILLED'}}).get('code')==200)
check('重复补录拒绝',api('/personnel',hr,'POST',{'userId':otherid,'data':{**body,'employeeNo':'FILLED'}}).get('code')==409)
filled=next(x for x in api('/personnel',hr)['data']['rows'] if x['user_id']==otherid)
check('补录轨迹可查询',api(f"/personnel/history/EMPLOYEE/{filled['id']}",hr)['data'][0]['action']=='CREATE')
sql(f"INSERT INTO biz_access_permission(company_id,user_id,device_code,status,sync_status) VALUES(1,{otherid},'OLD_DRAFT','DRAFT','NOT_CONNECTED');")
check('历史门禁草稿不显示有效',next(x for x in api('/personnel/access',hr)['data']['rows'] if x['device_code']=='OLD_DRAFT')['record_state']=='INACTIVE')
Path('tests/stage05/results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
