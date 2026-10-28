import os,json,time,re,subprocess
from datetime import datetime,timedelta,date
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0].replace("cmd('SELECT',2)","cmd('SELECT',3)"))
admin=login('s2_a_admin');business=login('s2_a_business');finance=login('s2_a_finance');bad=login('s2_b_admin');emp=login('s2_a_employee');platform=login('s2_platform')
now=datetime.now();today=now.date();last=today-timedelta(days=1);days=[]
while len(days)<8:
 if last.weekday()<5:days.append(last)
 last-=timedelta(days=1)
first=min(days)
check('默认仅工作日及提醒模式',api('/reports/config',platform)['data']['rule']['weekdays_only'] and api('/reports/config',platform)['data']['rule']['mode']=='REMIND_ONLY')
check('企业不可配置规则',api('/reports/config',admin).get('code')==403)
check('计报起点配置',api('/reports/start-date',platform,'PUT',{'companyId':1,'date':str(first)}).get('code')==200)
r=api('/reports/compliance?companyId=1',business)['data'];check('周末不计入漏报',r['missingCount']==8 and all(date.fromisoformat(d).weekday()<5 for d in r['missingDates']))
check('连续工作日计数正确',r['consecutiveDays']==8 and r['state']=='ALERT')
check('漏报不限制既有任务查询',api('/biz/task/list',business).get('code')==200)
check('模式保持仅提醒',r['mode']=='REMIND_ONLY')
check('跨企业漏报查询拒绝',api('/reports/compliance?companyId=2',admin).get('code')==403)
check('普通员工无填报查询权',api('/reports?companyId=1',emp).get('code')==403)
body={'companyId':1,'outputDate':str(max(days)),'outputValue':100,'unit':'元','remark':'测试'}
check('财务不能保存',api('/reports',finance,'POST',body).get('code')==403)
check('负值拒绝',api('/reports',business,'POST',{**body,'outputValue':-1}).get('code')==400)
check('未来日期拒绝',api('/reports',business,'POST',{**body,'outputDate':str(today+timedelta(days=1))}).get('code')==400)
check('不同计量单位拒绝',api('/reports',business,'POST',{**body,'unit':'万元'}).get('code')==400)
check('非法日期查询拒绝',api('/reports?companyId=1&from=bad',business).get('code')==400)
check('非法月份拒绝',api('/reports/month?companyId=1&month=wrong',business).get('code')==400)
def getday(d):return api('/reports?companyId=1&from='+str(d)+'&to='+str(d),business)['data']['rows']
def fill(d,amount=100):
 rows=getday(d);payload={**body,'outputDate':str(d),'outputValue':amount}
 if rows:
  old=rows[0];id=old['id'];r=api('/reports/'+str(id),business,'PUT',{**payload,'version':old['version']})
 else:
  r=api('/reports',business,'POST',payload);id=r.get('data')
 if r.get('code')!=200:raise RuntimeError('save '+str(d)+': '+str(r))
 row=api('/reports/'+str(id)+'?companyId=1',business)['data'];r=api('/reports/'+str(id)+'/submit',business,'POST',{'companyId':1,'version':row['version']})
 if r.get('code')!=200:raise RuntimeError('submit '+str(d)+': '+str(r))
 return id
id=fill(max(days));row=api('/reports/'+str(id)+'?companyId=1',business)['data']
check('正常提交并查询',row['status']=='SUBMITTED')
check('同日重复保存拒绝',api('/reports',business,'POST',body).get('code')==409)
check('已提交不可直接改',api('/reports/'+str(id),business,'PUT',{**body,'version':row['version']}).get('code')==409)
check('重复提交拒绝',api('/reports/'+str(id)+'/submit',business,'POST',{'companyId':1,'version':row['version']}).get('code')==409)
check('跨企业直接明细拒绝',api('/reports/'+str(id)+'?companyId=2',bad).get('code')==404)
check('跨企业提交拒绝',api('/reports/'+str(id)+'/submit',bad,'POST',{'companyId':2,'version':0}).get('code')==404)
check('草稿不算完成提交',api('/reports/compliance?companyId=1',business)['data']['missingCount']==7)
# Explicit holiday and make-up workday calendar overrides.
holiday=min(days)
check('单独配置节假日',api('/reports/calendar',platform,'PUT',{'date':str(holiday),'required':False,'remark':'测试放假'}).get('code')==200)
check('节假日从漏报移除',str(holiday) not in api('/reports/compliance?companyId=1',business)['data']['missingDates'])
weekend=first
while weekend.weekday()<5:weekend-=timedelta(days=1)
api('/reports/start-date',platform,'PUT',{'companyId':1,'date':str(weekend)})
check('调休周末可配置应报',api('/reports/calendar',platform,'PUT',{'date':str(weekend),'required':True,'remark':'测试调休'}).get('code')==200)
check('调休周末识别漏报',str(weekend) in api('/reports/compliance?companyId=1',business)['data']['missingDates'])
for d in api('/reports/compliance?companyId=1',business)['data']['missingDates']:fill(date.fromisoformat(d))
r=api('/reports/compliance?companyId=1',business)['data'];check('补齐后恢复正常统计',r['state']=='NORMAL' and r['missingCount']==0 and r['consecutiveDays']==0)
check('补齐后历史提醒关闭',all(x['resolved'] for x in api('/reports/reminders?companyId=1',business)['data']))
# Verify scheduled execution independently of the manual check endpoint.
config=(ROOT/'RuoYi-Vue-backend/ruoyi-admin/src/main/resources/application-druid.yml').read_text(encoding='utf-8-sig');env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
def sql(q):
 database=env['STAGE02_TEST_DB']
 if not database.startswith('ry_platform_s6test_'):raise RuntimeError('Fresh test database required')
 subprocess.run(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4',database],input=q.encode('utf-8'),env=env,check=True)
sql(f"UPDATE biz_company SET reporting_start_date='{first}' WHERE id=2; DELETE FROM biz_report_reminder WHERE company_id=2; DELETE FROM biz_report_compliance WHERE company_id=2;")
scheduled=False
for _ in range(8):
 time.sleep(1)
 if api('/reports/reminders?companyId=2',bad)['data']:scheduled=True;break
check('定时任务自动生成提醒',scheduled)
before=len(api('/reports/reminders?companyId=2',bad)['data']);time.sleep(2);check('提醒去重',len(api('/reports/reminders?companyId=2',bad)['data'])==before)
# Test an actual pre-deadline reminder using a cutoff a few minutes from now.
cutoff=(datetime.now()+timedelta(minutes=3)).strftime('%H:%M:%S');rule=api('/reports/config',platform)['data']['rule']
api('/reports/config',platform,'PUT',{'cutoff':cutoff,'remindMinutes':60,'thresholdDays':7,'weekdaysOnly':True,'version':rule['version']})
api('/reports/calendar',platform,'PUT',{'date':str(today),'required':True,'remark':'截止提醒测试'})
api('/reports/check',platform,'POST');check('提前站内提醒生成',any(x['reminder_type']=='BEFORE_DUE' for x in api('/reports/reminders?companyId=1',business)['data']))
api('/reports/check',platform,'POST')
check('截止前提醒不提前关闭',any(x['reminder_type']=='BEFORE_DUE' and not x['resolved'] for x in api('/reports/reminders?companyId=1',business)['data']))
fill(today);api('/reports/check',platform,'POST')
check('提交当天数据后关闭截止提醒',all(x['resolved'] for x in api('/reports/reminders?companyId=1',business)['data'] if x['reminder_type']=='BEFORE_DUE'))
rule=api('/reports/config',platform)['data']['rule'];api('/reports/config',platform,'PUT',{'cutoff':'23:59:00','remindMinutes':60,'thresholdDays':7,'weekdaysOnly':True,'version':rule['version']})
# Previous-month complete details and confirmation/return lifecycle.
monthEnd=today.replace(day=1)-timedelta(days=1);monthStart=monthEnd.replace(day=1);month=str(monthStart)[:7]
check('当前月禁止提前确认',api('/reports/month/review',platform,'POST',{'companyId':1,'month':str(today)[:7],'confirm':True,'version':0,'opinion':'提前'}).get('code')==400)
api('/reports/start-date',platform,'PUT',{'companyId':1,'date':str(monthStart)})
required=[];d=monthStart
while d<=monthEnd:
 if d.weekday()<5:required.append(d)
 d+=timedelta(days=1)
for d in required[:-1]:fill(d)
check('漏报月份不能确认',api('/reports/month/review',platform,'POST',{'companyId':1,'month':month,'confirm':True,'version':0,'opinion':'漏报核对'}).get('code')==409)
fill(required[-1]);summary=api('/reports/month?companyId=1&month='+month,finance)['data']
check('月度汇总等于提交明细',summary['submittedCount']==len(required) and float(summary['totalValue'])==sum(float(x['output_value']) for x in summary['rows']))
check('企业不能确认月度',api('/reports/month/review',admin,'POST',{'companyId':1,'month':month,'confirm':True,'version':0,'opinion':'越权'}).get('code')==403)
check('月度退回修改',api('/reports/month/review',platform,'POST',{'companyId':1,'month':month,'confirm':False,'version':0,'opinion':'请修正首日金额'}).get('code')==200)
check('退回明细可修改',all(x['status']=='RETURNED' for x in api('/reports/month?companyId=1&month='+month,finance)['data']['rows']))
for index,d in enumerate(required):fill(d,150 if index==0 else 100)
summary=api('/reports/month?companyId=1&month='+month,finance)['data'];expected=len(required)*100+50
check('修改重提后汇总正确',float(summary['totalValue'])==expected)
check('月度确认成功',api('/reports/month/review',platform,'POST',{'companyId':1,'month':month,'confirm':True,'version':summary['version'],'opinion':'月度核对一致'}).get('code')==200)
summary=api('/reports/month?companyId=1&month='+month,finance)['data'];check('确认快照及核对轨迹一致',summary['status']=='CONFIRMED' and len(summary['audits'])==2 and float(summary['audits'][0]['total_value'])==expected and all(x['status']=='CONFIRMED' for x in summary['rows']))
record=summary['rows'][0]
check('已确认明细禁止改',api('/reports/'+str(record['id']),business,'PUT',{**body,'outputDate':str(record['output_date'])[:10],'version':record['version']}).get('code')==409)
check('旧入口不能绕过确认锁',api('/biz/daily_output/'+str(record['id']),business,'PUT',{**body,'outputDate':str(record['output_date'])[:10],'version':record['version']}).get('code')==409)
check('确认月份禁止改日历',api('/reports/calendar',platform,'PUT',{'date':str(monthStart),'required':False,'remark':'改口径'}).get('code')==409)
check('确认后禁止改计报起点',api('/reports/start-date',platform,'PUT',{'companyId':1,'date':str(today)}).get('code')==409)
rule=api('/reports/config',platform)['data']['rule'];check('确认后禁止改工作日口径',api('/reports/config',platform,'PUT',{'cutoff':'23:59:00','remindMinutes':60,'thresholdDays':7,'weekdaysOnly':False,'version':rule['version']}).get('code')==409)
check('匿名访问拒绝',api('/reports/companies').get('code')==401)
Path('tests/stage06/results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
