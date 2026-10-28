import os,json,concurrent.futures
from datetime import datetime,timedelta
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0].replace("cmd('SELECT',2)","cmd('SELECT',3)"))
a=login('s2_a_admin');business=login('s2_a_business');e=login('s2_a_employee');bad=login('s2_b_admin');be=login('s2_b_employee');p=login('s2_platform');f=login('s2_a_finance');hr=login('s2_a_hr')
now=datetime.now();today=now.date();end=(now+timedelta(days=7)).date();deadline=min(now+timedelta(minutes=10),now.replace(hour=23,minute=59,second=59))
body={'title':'执行测试任务','description':'测试','targetQuantity':100,'unit':'件','signupDeadline':deadline.strftime('%Y-%m-%dT%H:%M:%S'),'startDate':str(today),'endDate':str(end),'maxCompanies':1,'audience':'INTERNAL'}
def make(quantity=100,unit='件'):
 r=api('/tasks',a,'POST',{**body,'targetQuantity':quantity,'unit':unit});tid=r['data'];t=api('/tasks/'+str(tid),a)['data'];api(f'/tasks/{tid}/publish',a,'POST',{'version':t['version']});r=api(f'/tasks/{tid}/signups',a,'POST',{'quantity':quantity});return tid,r['data']
def link(sid,existing=None,name='项目测试'):
 return api('/execution/projects',a,'POST',{'signupId':sid,'projectId':existing,'projectName':name})
def progress(pid,token=a):return api(f'/execution/projects/{pid}?companyId=1',token)['data']
def own(aid,token):return api('/execution/mine/'+str(aid),token)['data']
def assignment(pid,sid,user,quantity,token=a):return api(f'/execution/projects/{pid}/assignments',token,'POST',{'signupId':sid,'userId':user,'quantity':quantity,'dueDate':str(end)})
def record(aid,rid,token):return next(x for x in own(aid,token)['records'] if x['id']==rid)
def submit(aid,rid,token):return api(f'/execution/records/{rid}/submit',token,'POST',{'version':record(aid,rid,token)['version']})
def review(pid,rid,approve=True,token=a):
 w=next(x for x in progress(pid)['workRecords'] if x['id']==rid)
 return api(f'/execution/records/{rid}/review',token,'POST',{'version':w['version'],'approve':approve,'opinion':'确认' if approve else '请更正'})
def claim(aid,token):return api(f'/execution/assignments/{aid}/claim',token,'POST',{'version':own(aid,token)['version']})
def finish(aid,token):return api(f'/execution/assignments/{aid}/finish',token,'POST',{'version':own(aid,token)['version']})
def save(aid,token,q,rid=None):
 data={'workDate':str(today),'quantity':q,'remark':'每日上报'}
 if rid:data['version']=record(aid,rid,token)['version']
 return api(f'/execution/assignments/{aid}/records'+('/'+str(rid) if rid else ''),token,'PUT' if rid else 'POST',data)
def complete(pid,archive=False):
 return api(f'/execution/projects/{pid}/'+('archive' if archive else 'complete'),a,'POST',{'version':progress(pid)['version'],'opinion':'项目归档' if archive else '项目完成核验'})
tid,sid=make();check('已通过任务可作为项目来源',any(x['id']==sid for x in api('/execution/approved',a)['data']))
check('历史缺日期演示任务不进入候选',all(x['id'] not in [1,2] for x in api('/execution/approved',a)['data']))
check('历史缺日期任务明确拒绝',link(1).get('code')==409)
check('财务不可建项目',api('/execution/projects',f,'POST',{'signupId':sid,'projectName':'越权'}).get('code')==403)
check('其他企业不可关联报名',api('/execution/projects',bad,'POST',{'signupId':sid,'projectName':'越权'}).get('code')==404)
r=link(sid);check('审核通过报名建项目',r.get('code')==200,r);pid=r['data']
check('重复关联拒绝',link(sid).get('code')==409)
check('企业项目目标取承诺量',float(progress(pid)['totalQuantity'])==100)
check('平台可查看项目进度',api(f'/execution/projects/{pid}?companyId=1',p).get('code')==200)
check('其他企业项目详情拒绝',api(f'/execution/projects/{pid}?companyId=2',bad).get('code')==404)
check('普通员工不能查看全项目成员',api(f'/execution/projects/{pid}?companyId=1',e).get('code')==403)
check('跨企业员工分配拒绝',assignment(pid,sid,207,20).get('code')==403)
check('分配超承诺量拒绝',assignment(pid,sid,205,101).get('code')==409)
check('未完成项目不能确认',complete(pid).get('code')==409)
x=assignment(pid,sid,205,60);check('向员工分配任务',x.get('code')==200);aid=x['data']
check('第二次分配超剩余量拒绝',assignment(pid,sid,203,41).get('code')==409)
bid=assignment(pid,sid,203,40)['data']
check('员工只看本人分配',all(x['user_id']==205 for x in api('/execution/mine',e)['data']))
check('同企业其他员工不可查详情',api('/execution/mine/'+str(aid),business).get('code')==403)
check('其他企业不可领取',api(f'/execution/assignments/{aid}/claim',be,'POST',{'version':0}).get('code')==404)
check('同企业他人不可领取',api(f'/execution/assignments/{aid}/claim',business,'POST',{'version':0}).get('code')==403)
check('未领取不可上报',save(aid,e,30).get('code')==409)
check('员工领取任务',claim(aid,e).get('code')==200)
check('重复领取拒绝',claim(aid,e).get('code')==409)
check('未来工作日期拒绝',api(f'/execution/assignments/{aid}/records',e,'POST',{'workDate':str(today+timedelta(days=1)),'quantity':1}).get('code')==400)
check('零工作量拒绝',save(aid,e,0).get('code')==400)
check('超过分配量拒绝',save(aid,e,61).get('code')==409)
r=save(aid,e,30);check('保存每日工作量草稿',r.get('code')==200);wid=r['data']
check('同日期重复上报拒绝',save(aid,e,1).get('code')==409)
check('草稿不计入进度',float(progress(pid)['confirmedQuantity'])==0)
check('提交工作量',submit(aid,wid,e).get('code')==200)
check('待审核不计入进度',float(progress(pid)['confirmedQuantity'])==0)
check('已提交不能直接改',save(aid,e,35,wid).get('code')==409)
check('其他企业无权审核',api(f'/execution/records/{wid}/review',bad,'POST',{'version':0,'approve':True,'opinion':'越权'}).get('code')==404)
check('审核退回',review(pid,wid,False).get('code')==200)
check('退回后员工可更正',save(aid,e,30,wid).get('code')==200)
check('更正重提',submit(aid,wid,e).get('code')==200)
check('工作量确认',review(pid,wid).get('code')==200)
check('重复确认工作量拒绝',review(pid,wid).get('code')==409)
check('进度30百分比准确',float(progress(pid)['confirmedQuantity'])==30 and float(progress(pid)['percent'])==30)
check('尚未达到分配量不能完成',finish(aid,e).get('code')==409)
w=record(aid,wid,e);check('已确认不得直接改',save(aid,e,60,wid).get('code')==409)
check('更正退回需意见',api(f'/execution/records/{wid}/reopen',a,'POST',{'version':w['version'],'opinion':''}).get('code')==400)
check('已确认留痕退回更正',api(f'/execution/records/{wid}/reopen',a,'POST',{'version':w['version'],'opinion':'数量应为60'}).get('code')==200)
check('退回更正暂不计入进度',float(progress(pid)['confirmedQuantity'])==0)
check('更正数量保存',save(aid,e,60,wid).get('code')==200)
submit(aid,wid,e);review(pid,wid)
check('更正后进度60百分比',float(progress(pid)['percent'])==60)
check('员工完成任务',finish(aid,e).get('code')==200)
check('已完成分配禁止更正',api(f'/execution/records/{wid}/reopen',a,'POST',{'version':record(aid,wid,e)['version'],'opinion':'不可再变更'}).get('code')==409)
claim(bid,business);bw=save(bid,business,40)['data']
check('作废草稿留痕',api(f'/execution/records/{bw}/void',business,'POST',{'version':record(bid,bw,business)['version'],'opinion':'重填'}).get('code')==200)
check('作废记录可修改后再提',save(bid,business,40,bw).get('code')==200)
submit(bid,bw,business)
check('业务岗不能审核自己工作量',review(pid,bw,True,business).get('code')==403)
review(pid,bw);finish(bid,business)
q=progress(pid);check('项目总量进度百分比正确',float(q['totalQuantity'])==100 and float(q['confirmedQuantity'])==100 and float(q['remainingQuantity'])==0 and float(q['percent'])==100)
check('成员工作量汇总正确',sum(float(x['confirmedQuantity']) for x in q['members'])==100)
check('工作量更正与审批可追溯',sum(x['action']=='WORK_REVIEW' for x in q['events'])>=4 and any(x['action']=='CORRECTION' for x in q['events']))
check('未确认项目不能归档',complete(pid,True).get('code')==409)
check('项目完成确认',complete(pid).get('code')==200)
check('企业执行状态更新完成',api('/tasks/signups/'+str(sid),a)['data']['execution_status']=='COMPLETED')
check('项目归档',complete(pid,True).get('code')==200)
check('归档状态可查询',progress(pid)['status']=='ARCHIVED')
check('归档后禁止再分配',assignment(pid,sid,204,1).get('code')==409)
check('归档后禁止修改工作记录',save(aid,e,60,wid).get('code')==409)
t=api('/tasks/'+str(tid),a)['data'];check('任务完成确认',api(f'/execution/tasks/{tid}/complete',a,'POST',{'version':t['version'],'opinion':'全部完成'}).get('code')==200)
check('任务已完成状态正确',api('/tasks/'+str(tid),a)['data']['status']=='COMPLETED')
# Link different tasks into one project; member totals must not duplicate per-assignment quantities.
t1,s1=make(10);pid2=link(s1,name='关联项目')['data'];t2,s2=make(20)
check('关联已有同单位项目',link(s2,pid2).get('code')==200)
t3,s3=make(5,'小时');check('不同单位不能混入同一项目',link(s3,pid2).get('code')==400)
for ss,quantity in [(s1,10),(s2,20)]:
 aa=assignment(pid2,ss,205,quantity)['data'];claim(aa,e);rr=save(aa,e,quantity)['data'];submit(aa,rr,e);review(pid2,rr)
q=progress(pid2);check('跨任务同成员汇总不重复',float(q['confirmedQuantity'])==30 and len(q['members'])==1 and float(q['members'][0]['confirmedQuantity'])==30)
check('每条分配进度独立',sorted(float(x['confirmed_quantity']) for x in q['assignments'])==[10,20])
# Capacity races use current reads behind the company lock.
tc,sc=make(50);pc=link(sc,name='并发分配')['data']
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool: race=list(pool.map(lambda user:assignment(pc,sc,user,30),[205,203]))
check('并发分配不超企业承诺量',sorted(x['code'] for x in race)==[200,409] and sum(float(x['assigned_quantity']) for x in progress(pc)['assignments'])==30)
pending=progress(pc)['assignments'][0]
check('待领取分配可取消',api(f"/execution/assignments/{pending['id']}/cancel",a,'POST',{'version':pending['version'],'opinion':'调整分配'}).get('code')==200)
check('取消后可重新分配',assignment(pc,sc,pending['user_id'],50).get('code')==200)
check('匿名执行接口拒绝',api('/execution/mine').get('code')==401)
# Platform task execution spans separate enterprise projects.
r=api('/tasks',p,'POST',{**body,'title':'平台跨企业执行','audience':'SHARED','maxCompanies':2});globalTask=r['data'];tr=api('/tasks/'+str(globalTask),p)['data'];api(f'/tasks/{globalTask}/publish',p,'POST',{'version':tr['version']})
spa=api(f'/tasks/{globalTask}/signups',a,'POST',{'quantity':60})['data']
check('未审核报名不得建项目',link(spa).get('code')==409)
api(f'/tasks/signups/{spa}/review',p,'POST',{'version':0,'approve':True,'opinion':'企业A通过'})
pa=link(spa,name='平台任务企业A项目')['data']
check('平台任务企业项目目标取各自承诺量',float(progress(pa)['totalQuantity'])==60)
spb=api(f'/tasks/{globalTask}/signups',bad,'POST',{'quantity':40})['data'];api(f'/tasks/signups/{spb}/review',p,'POST',{'version':0,'approve':True,'opinion':'企业B通过'})
pb=api('/execution/projects',bad,'POST',{'signupId':spb,'projectName':'企业B项目'})['data']
aa=assignment(pa,spa,205,60)['data'];claim(aa,e);rr=save(aa,e,60)['data'];submit(aa,rr,e);review(pa,rr);finish(aa,e);complete(pa)
tr=api('/tasks/'+str(globalTask),p)['data']
check('平台任务不能因一家完成就提前结束',api(f'/execution/tasks/{globalTask}/complete',p,'POST',{'version':tr['version'],'opinion':'尚缺B企业'}).get('code')==409)
check('企业不能确认平台任务完成',api(f'/execution/tasks/{globalTask}/complete',a,'POST',{'version':tr['version'],'opinion':'越权确认'}).get('code')==403)
bb=assignment(pb,spb,207,40,bad)['data'];claim(bb,be);br=save(bb,be,40)['data'];submit(bb,br,be)
brecord=record(bb,br,be);check('企业B核验自己的工作量',api(f'/execution/records/{br}/review',bad,'POST',{'version':brecord['version'],'approve':True,'opinion':'B企业确认'}).get('code')==200)
finish(bb,be);bp=api(f'/execution/projects/{pb}?companyId=2',bad)['data'];check('企业B独立进度100百分比',float(bp['totalQuantity'])==40 and float(bp['percent'])==100)
api(f'/execution/projects/{pb}/complete',bad,'POST',{'version':bp['version'],'opinion':'B项目完成'})
check('全部企业完成后平台任务可完成',api(f'/execution/tasks/{globalTask}/complete',p,'POST',{'version':tr['version'],'opinion':'全部企业完成'}).get('code')==200)
check('财务不可读取其他企业项目',api(f'/execution/projects/{pb}?companyId=1',f).get('code')==404)
# The duplicate-day check must remain correct when two saves race.
current=next(x for x in progress(pc)['assignments'] if x['status']=='PENDING');actor=e if current['user_id']==205 else business
claim(current['id'],actor)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool: duplicate=list(pool.map(lambda _:save(current['id'],actor,20),[1,2]))
check('并发同日报量只保存一条',sorted(x['code'] for x in duplicate)==[200,409] and len(own(current['id'],actor)['records'])==1)
Path('tests/stage08/results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
