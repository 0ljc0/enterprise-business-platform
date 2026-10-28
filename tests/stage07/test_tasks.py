import os,json,concurrent.futures,re,subprocess
from datetime import datetime,timedelta
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0].replace("cmd('SELECT',2)","cmd('SELECT',3)"))
p=login('s2_platform');a=login('s2_a_admin');b=login('s2_b_admin');business=login('s2_a_business');employee=login('s2_a_employee');finance=login('s2_a_finance')
now=datetime.now();tomorrow=(now+timedelta(days=1)).date();end=(now+timedelta(days=7)).date()
body={'title':'平台任务测试','description':'任务说明','targetQuantity':100,'unit':'件','signupDeadline':(now+timedelta(hours=4)).strftime('%Y-%m-%dT%H:%M:%S'),'startDate':str(tomorrow),'endDate':str(end),'maxCompanies':2,'audience':'SHARED'}
def task(id,token=p):return api('/tasks/'+str(id),token)['data']
def create(token=p,changes=None):
 r=api('/tasks',token,'POST',{**body,**(changes or {})})
 if r.get('code')!=200:raise RuntimeError('create '+str(r))
 return r['data']
def publish(id,token=p):return api(f'/tasks/{id}/publish',token,'POST',{'version':task(id,token)['version']})
def apply(id,token,quantity):return api(f'/tasks/{id}/signups',token,'POST',{'quantity':quantity})
def signup(id,token=p):return api('/tasks/signups/'+str(id),token)['data']
def review(id,approve=True,opinion='审核意见'):
 row=signup(id);return api(f'/tasks/signups/{id}/review',p,'POST',{'approve':approve,'opinion':opinion,'version':row['version']})
check('普通员工不能发布',api('/tasks',employee,'POST',body).get('code')==403)
check('财务不能发布',api('/tasks',finance,'POST',body).get('code')==403)
check('目标量必须为正',api('/tasks',p,'POST',{**body,'targetQuantity':0}).get('code')==400)
check('企业容量校验',api('/tasks',p,'POST',{**body,'maxCompanies':0}).get('code')==400)
id=create();check('平台创建草稿',task(id)['status']=='DRAFT')
check('企业不可查看未发布平台草稿',api(f'/tasks/{id}',a).get('code')==404)
row=task(id);check('平台修改草稿',api(f'/tasks/{id}',p,'PUT',{**body,'title':'修改后的平台任务','version':row['version']}).get('code')==200)
check('历史版本修改拒绝',api(f'/tasks/{id}',p,'PUT',{**body,'version':row['version']}).get('code')==409)
check('平台发布任务',publish(id).get('code')==200)
check('平台任务详情不暴露发布账号信息','publisher_id' not in api(f'/tasks/{id}',a)['data'] and 'create_by' not in api(f'/tasks/{id}',a)['data'])
check('企业可查询可报名任务',any(x['id']==id for x in api('/tasks',a)['data']['rows']))
row=task(id);check('发布后禁止改任务',api(f'/tasks/{id}',p,'PUT',{**body,'version':row['version']}).get('code')==409)
check('企业不可改平台任务',api(f'/tasks/{id}',a,'PUT',{**body,'audience':'INTERNAL','maxCompanies':1,'version':row['version']}).get('code')==403)
check('普通员工不可报名',apply(id,employee,40).get('code')==403)
check('报名工作量正数校验',apply(id,a,0).get('code')==400)
r=apply(id,a,40);check('企业A报名成功',r.get('code')==200);sa=r['data']
check('企业重复报名拒绝',apply(id,a,40).get('code')==409)
check('企业B无法查A报名',api('/tasks/signups/'+str(sa),b).get('code')==403)
check('企业不可审核报名',api(f'/tasks/signups/{sa}/review',a,'POST',{'approve':True,'opinion':'越权','version':0}).get('code')==403)
check('空审核意见拒绝',review(sa,True,'').get('code')==400)
check('待审核允许撤回',api(f'/tasks/signups/{sa}/withdraw',a,'POST',{'version':signup(sa)['version']}).get('code')==200)
check('撤回后可重新提交',apply(id,a,40).get('code')==200)
check('平台驳回报名',review(sa,False,'请完善承诺量').get('code')==200)
check('驳回后可修改重提',apply(id,a,40).get('code')==200)
check('审核轮次递增',signup(sa)['round_no']==3)
check('平台审核通过',review(sa).get('code')==200)
check('报名通过可进入分配环节',signup(sa,a)['readyForAssignment'])
check('已通过不可取消',api(f'/tasks/signups/{sa}/withdraw',a,'POST',{'version':signup(sa)['version']}).get('code')==409)
check('重复审核拒绝',review(sa).get('code')==409)
check('审批意见历史留存',len(signup(sa,a)['audits'])==2)
check('承诺量超过剩余总量拒绝',apply(id,b,70).get('code')==409)
sb=apply(id,b,50)['data'];check('企业B在剩余容量内报名',review(sb).get('code')==200)
check('已通过数量统计正确',task(id)['approved_companies']==2 and float(task(id)['approved_quantity'])==90)
check('满容量任务退出可报名列表',all(x['id']!=id for x in api('/tasks',a)['data']['rows']))
check('企业仅看自己的报名记录',all(x['company_id']==1 for x in api('/tasks/signups',a)['data']['rows']))
check('平台可集中查看报名',any(x['id']==sa for x in api('/tasks/signups?review=true',p)['data']['rows']))
# Corporate tasks are internal-only, enforced even for forged API payloads.
check('企业不能创建共享任务',api('/tasks',a,'POST',body).get('code')==400)
check('企业内部任务容量固定一家',api('/tasks',a,'POST',{**body,'audience':'INTERNAL','maxCompanies':2}).get('code')==400)
internal=create(a,{'audience':'INTERNAL','maxCompanies':1,'title':'企业内部任务'})
check('企业创建内部草稿',task(internal,a)['publisher_type']=='COMPANY')
check('其他企业不能改草稿',api(f'/tasks/{internal}',b,'PUT',{**body,'audience':'INTERNAL','maxCompanies':1,'version':0}).get('code')==403)
check('内部草稿不公开',api(f'/tasks/{internal}',b).get('code')==404)
check('企业发布内部任务',publish(internal,a).get('code')==200)
check('内部任务不在其他企业列表',all(x['id']!=internal for x in api('/tasks',b)['data']['rows']))
check('内部任务不向其他企业公开',api(f'/tasks/{internal}',b).get('code')==404)
check('内部任务跨企业报名拒绝',apply(internal,b,10).get('code')==403)
inside=apply(internal,a,10);check('本企业可承接内部任务',inside.get('code')==200)
check('内部任务无需平台重复审核',signup(inside['data'],a)['readyForAssignment'])
shared=create(changes={'title':'平台任务关闭测试','targetQuantity':20});publish(shared)
sharedSignup=apply(shared,b,10)['data']
# Real concurrent approvals must not exceed a one-company capacity.
cap=create(changes={'title':'并发容量测试','maxCompanies':1});publish(cap)
x=apply(cap,a,30)['data'];y=apply(cap,b,30)['data']
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool: responses=list(pool.map(review,[x,y]))
check('并发审核不突破企业容量',sorted(r['code'] for r in responses)==[200,409] and task(cap)['approved_companies']==1)
# Workload must be rechecked at approval, not only application time.
qty=create(changes={'title':'工作量竞争','maxCompanies':2,'targetQuantity':100});publish(qty)
x=apply(qty,a,70)['data'];y=apply(qty,b,70)['data']
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool: amounts=list(pool.map(review,[x,y]))
check('审核再次校验剩余工作量',sorted(r['code'] for r in amounts)==[200,409])
check('并发审核不突破总工作量',float(task(qty)['approved_quantity'])==70)
# Closing recruitment preserves approved rights, blocks new/review approvals.
row=task(shared);check('任务关闭招募',api(f'/tasks/{shared}/close',p,'POST',{'version':row['version'],'reason':'招募结束'}).get('code')==200)
check('关闭后不能通过待审报名',review(sharedSignup).get('code')==409)
check('关闭后可驳回待审报名',review(sharedSignup,False,'任务关闭').get('code')==200)
check('关闭后不可重提',apply(shared,b,10).get('code')==409)
row=task(id);check('平台任务关闭',api(f'/tasks/{id}/close',p,'POST',{'version':row['version'],'reason':'结束报名'}).get('code')==200)
check('关闭保留已通过报名',signup(sa,a)['readyForAssignment'])
check('关闭任务不在可报名列表',all(x['id']!=id for x in api('/tasks',a)['data']['rows']))
# Deadline tests use only the fresh integration database.
config=(ROOT/'RuoYi-Vue-backend/ruoyi-admin/src/main/resources/application-druid.yml').read_text(encoding='utf-8-sig');env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
def sql(q):
 database=env['STAGE02_TEST_DB']
 if not database.startswith('ry_platform_s7test_'):raise RuntimeError('Dedicated test database required')
 subprocess.run(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root',database],input=q.encode('utf-8'),env=env,check=True)
expired=create(changes={'signupDeadline':(now-timedelta(days=1)).strftime('%Y-%m-%dT%H:%M:%S')})
check('截止已过不可发布',publish(expired).get('code')==400)
expiry=create(changes={'title':'报名截止测试'});publish(expiry);pending=apply(expiry,a,20)['data'];sql(f"UPDATE biz_task SET signup_deadline=DATE_SUB(NOW(),INTERVAL 1 MINUTE) WHERE id={expiry};")
check('截止后不能报名',apply(expiry,b,20).get('code')==409)
check('截止后已有报名仍可审核',review(pending).get('code')==200)
sql("UPDATE biz_company SET reporting_start_date=DATE_SUB(CURDATE(),INTERVAL 30 DAY) WHERE id=1;")
compliance=api('/reports/compliance?companyId=1',business)['data']
check('连续漏报仍仅提醒',compliance['mode']=='REMIND_ONLY' and compliance['state']=='ALERT')
over=create(changes={'title':'漏报仅提醒报名回归'});publish(over)
check('漏报不会阻止企业报名',apply(over,a,20).get('code')==200)
result=subprocess.run(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root',env['STAGE02_TEST_DB']],input=f"UPDATE biz_task SET audience='SHARED' WHERE id={internal};".encode(),env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
check('数据库约束拒绝企业共享',result.returncode!=0)
check('匿名任务查询拒绝',api('/tasks').get('code')==401)
Path('tests/stage07/results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
