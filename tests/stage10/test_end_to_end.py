"""Exercise the final business chain through the packaged Nginx /prod-api proxy."""
from pathlib import Path
import os,json,urllib.request,urllib.error,urllib.parse,zipfile,io,datetime,time,concurrent.futures
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
os.environ['STAGE02_TEST_URL']='http://127.0.0.1:18081/prod-api';os.environ['STAGE02_REDIS_DB']='5'
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0])
def ok(name,response):check(name,response.get('code')==200,response);assert response.get('code')==200,(name,response);return response.get('data')
platform=login('s2_platform');applicant=login('s2_unbound');employee=login('s4_applicant');other=login('s2_b_admin')
check('生产构建首页可访问',b'<html' in urllib.request.urlopen('http://127.0.0.1:18081/').read().lower())
check('前端历史路由刷新可访问',urllib.request.urlopen('http://127.0.0.1:18081/business/statistics').status==200)
for endpoint in ['/druid/','/swagger-ui/index.html','/v3/api-docs']:
 try:urllib.request.urlopen(base+endpoint);status=200
 except urllib.error.HTTPError as e:status=e.code
 check('Nginx关闭管理路径'+endpoint,status==404)
check('验证码保持启用',api('/captchaImage').get('captchaEnabled') is True)
check('匿名业务接口拒绝',api('/statistics/options').get('code')==401)
boundary='AcceptanceBoundary';content=b'%PDF-1.4\n%%EOF'
body=('--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="license.pdf"\r\nContent-Type: application/pdf\r\n\r\n').encode()+content+('\r\n--'+boundary+'--\r\n').encode()
req=urllib.request.Request(base+'/onboarding/licenses',data=body,headers={'Content-Type':'multipart/form-data; boundary='+boundary,'Authorization':'Bearer '+applicant})
lid=ok('企业执照通过代理上传',json.load(urllib.request.urlopen(req)))
chars='0123456789ABCDEFGHJKLMNPQRTUWXY';credit='91310000123456789';weights=[1,3,9,27,19,26,16,17,20,29,25,13,8,24,10,30,28];credit+=chars[(31-sum(chars.index(c)*w for c,w in zip(credit,weights))%31)%31]
data={'companyName':'第十阶段端到端验收企业','creditCode':credit,'contactName':'验收负责人','contactPhone':'13800000008','address':'验收地址','introduction':'验收企业','licenseId':lid}
application=ok('企业保存入驻申请',api('/onboarding/applications',applicant,'POST',data))
ok('企业提交审核',api(f'/onboarding/applications/{application}/submit',applicant,'POST'))
ok('平台驳回企业申请',api(f'/onboarding/applications/{application}/review',platform,'POST',{'approve':False,'opinion':'补充简介'}))
detail=api(f'/onboarding/applications/{application}',applicant)['data']
ok('企业修改重提',api(f'/onboarding/applications/{application}',applicant,'PUT',{**data,'introduction':'补充完整简介','version':detail['version']}));ok('企业重新提交',api(f'/onboarding/applications/{application}/submit',applicant,'POST'))
ok('平台通过企业申请',api(f'/onboarding/applications/{application}/review',platform,'POST',{'approve':True,'opinion':'准予入驻'}))
admin=login('s2_unbound');company=api('/onboarding/companies',admin)['data'][0]['id']
check('企业管理员角色生效','company_admin' in api('/getInfo',admin)['roles'])
ed={'companyId':company,'realName':'验收员工','contactPhone':'13800000009','jobTitle':'执行人员'}
eid=ok('员工保存入驻申请',api('/employees/applications',employee,'POST',ed));ok('员工提交',api(f'/employees/applications/{eid}/submit',employee,'POST'))
ok('企业驳回员工申请',api(f'/employees/applications/{eid}/review',admin,'POST',{'approve':False,'opinion':'完善姓名'}));detail=api(f'/employees/applications/{eid}',employee)['data']
ok('员工修改申请',api(f'/employees/applications/{eid}',employee,'PUT',{**ed,'realName':'验收员工完整姓名','version':detail['version']}));ok('员工重提',api(f'/employees/applications/{eid}/submit',employee,'POST'))
ok('企业通过员工申请',api(f'/employees/applications/{eid}/review',admin,'POST',{'approve':True,'opinion':'同意入职'}));check('审核后旧员工会话失效',api('/employees/me',employee).get('code')==401)
employee=login('s4_applicant');user=api('/employees/me',employee)['data']['user_id'];today=datetime.date.today();now=datetime.datetime.now()
task={'title':'完整验收平台任务','description':'第十阶段验收','targetQuantity':100,'unit':'件','signupDeadline':(now+datetime.timedelta(minutes=20)).strftime('%Y-%m-%dT%H:%M:%S'),'startDate':str(today),'endDate':str(today+datetime.timedelta(days=7)),'maxCompanies':1,'audience':'SHARED'}
tid=ok('平台新建任务',api('/tasks',platform,'POST',task));detail=api(f'/tasks/{tid}',platform)['data'];ok('平台发布任务',api(f'/tasks/{tid}/publish',platform,'POST',{'version':detail['version']}))
ok('任务发布方维护报价',api(f'/statistics/prices/{tid}',platform,'PUT',{'unitPrice':'2.5000','version':0,'opinion':'验收单位报价'}))
sid=ok('企业报名平台任务',api(f'/tasks/{tid}/signups',admin,'POST',{'quantity':100}));ok('平台审核报名',api(f'/tasks/signups/{sid}/review',platform,'POST',{'version':0,'approve':True,'opinion':'审核通过'}))
pid=ok('企业创建执行项目',api('/execution/projects',admin,'POST',{'signupId':sid,'projectName':'第十阶段验收项目'}))
check('其他企业不可读取验收项目',api(f'/execution/projects/{pid}?companyId=2',other).get('code')==404)
aid=ok('企业分配给入驻员工',api(f'/execution/projects/{pid}/assignments',admin,'POST',{'signupId':sid,'userId':user,'quantity':100,'dueDate':str(today+datetime.timedelta(days=7))}))
def mine():return api(f'/execution/mine/{aid}',employee)['data']
ok('员工领取',api(f'/execution/assignments/{aid}/claim',employee,'POST',{'version':mine()['version']}))
wid=ok('员工填写工作量',api(f'/execution/assignments/{aid}/records',employee,'POST',{'workDate':str(today),'quantity':100,'remark':'完成验收任务'}))
record=next(x for x in mine()['records'] if x['id']==wid);ok('员工提交工作量',api(f'/execution/records/{wid}/submit',employee,'POST',{'version':record['version']}))
project=lambda:api(f'/execution/projects/{pid}?companyId={company}',admin)['data']
record=next(x for x in project()['workRecords'] if x['id']==wid);ok('企业确认工作量',api(f'/execution/records/{wid}/review',admin,'POST',{'version':record['version'],'approve':True,'opinion':'核验完成'}))
ok('员工完成分配任务',api(f'/execution/assignments/{aid}/finish',employee,'POST',{'version':mine()['version']}))
output=ok('企业填写每日业务产值',api('/reports',admin,'POST',{'companyId':company,'outputDate':str(today),'outputValue':350,'unit':'元','remark':'实际业务填报，与估值分开'}))
rows=api(f'/reports?companyId={company}&from={today}&to={today}',admin)['data']['rows'];report=next(x for x in rows if x['id']==output)
ok('企业提交业务产值',api(f'/reports/{output}/submit',admin,'POST',{'version':report['version']}))
stats=api('/statistics/report?kind=estimates',admin)['data'];row=next(x for x in stats['rows'] if x['id']==pid)
check('确认工作量与项目进度一致',float(row['confirmedQuantity'])==100 and float(row['percent'])==100)
check('预估金额与已报产值分开',float(row['plannedEstimate'])==250 and float(api('/statistics/report?kind=outputs',admin)['data']['summary']['reportedValue'])==350)
req=urllib.request.Request(base+'/statistics/export?kind=estimates',headers={'Authorization':'Bearer '+admin});download=urllib.request.urlopen(req);data=download.read()
with zipfile.ZipFile(io.BytesIO(data)) as workbook:check('Nginx代理Excel可解析','xl/workbook.xml' in workbook.namelist())
check('普通员工不能导出企业报表',api('/statistics/export?kind=estimates',employee).get('code')==403)
for action in ['complete','archive']:ok('项目'+action,api(f'/execution/projects/{pid}/{action}',admin,'POST',{'version':project()['version'],'opinion':'验收完成'}))
check('归档后项目只读',api(f'/execution/projects/{pid}/assignments',admin,'POST',{'signupId':sid,'userId':user,'quantity':1,'dueDate':str(today)}).get('code')==409)
routes=json.dumps(api('/getRouters',admin),ensure_ascii=False);check('企业获得统计和业务菜单','statistics' in routes)
info=api('/getInfo',employee);check('员工无管理员按钮权限',not any(x.startswith('system:') for x in info.get('permissions',[])))
# Modest concurrency smoke check; not an internet-scale capacity claim.
def request(_):
 begin=time.perf_counter();r=api('/statistics/report?kind=overview',admin);return r.get('code')==200,(time.perf_counter()-begin)*1000
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:timings=list(pool.map(request,range(32)))
check('8并发32次统计查询均成功',all(x[0] for x in timings));latencies=sorted(x[1] for x in timings)
ok('员工退出登录',api('/logout',employee,'POST'));check('退出后旧令牌失效',api('/getInfo',employee).get('code')==401)
out=ROOT/'tests/stage10';(out/'end-to-end-results.json').write_text(json.dumps({'companyId':company,'projectId':pid,'cases':results,'loadSmoke':{'requests':32,'concurrency':8,'p50Ms':round(latencies[15],2),'p95Ms':round(latencies[30],2),'maxMs':round(max(latencies),2)}},ensure_ascii=False,indent=2),encoding='utf-8')
print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
