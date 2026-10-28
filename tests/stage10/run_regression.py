"""Historical business suites against the current schema in isolated databases."""
from pathlib import Path
import os,re,subprocess,datetime,time,urllib.request,json,sys,argparse
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
back=ROOT/'RuoYi-Vue-backend';out=ROOT/'tests/stage10';env=os.environ.copy();env['STAGE02_REDIS_DB']='3'
env['MYSQL_PWD']=os.environ['MYSQL_PWD']
MIGRATIONS=['sql/ry_20260417.sql','sql/quartz.sql','sql/stage02/01_schema.sql','sql/stage02/02_permissions.sql','sql/stage02/03_demo.local.sql','sql/stage03/01_company_onboarding.sql','sql/stage04/01_employee.sql','sql/stage04/02_demo.local.sql','sql/stage05/01_personnel_access.sql','sql/stage06/01_daily_reporting.sql','sql/stage07/01_tasks_signup.sql','sql/stage07/02_company_internal_only.sql','sql/stage08/01_execution.sql','sql/stage09/01_statistics.sql']
base=['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4']
def sql(q,db=None):subprocess.run(base+([db] if db else []),input=q.encode(),env=env,stdout=subprocess.DEVNULL,check=True)
previous=out/'regression-results.json'
parser=argparse.ArgumentParser();parser.add_argument('--resume',action='store_true');args=parser.parse_args()
all_results=[x for x in json.loads(previous.read_text(encoding='utf-8')) if x['exitCode']==0] if args.resume and previous.exists() else []
stamp=datetime.datetime.now().strftime('%Y%m%d%H%M%S')
for stage,script in [('03','test_company_onboarding.py'),('04','test_employees.py'),('05','test_personnel.py'),('06','test_reporting.py'),('07','test_tasks.py'),('08','test_execution.py'),('09','test_statistics.py')]:
 if any(x['stage']==stage for x in all_results):continue
 db='ry_platform_s'+str(int(stage))+'test_'+stamp+'_'+stage
 sql('CREATE DATABASE '+db+' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
 for migration in MIGRATIONS:sql((back/migration).read_text(encoding='utf-8-sig'),db)
 env['STAGE02_TEST_DB']=db;env['STAGE02_TEST_URL']='http://127.0.0.1:18100'
 with open(out/f'stage{stage}-runtime.log','w',encoding='utf-8') as log:
  process=subprocess.Popen(['java','-Dlogging.config=ruoyi-admin/src/main/resources/logback.xml','-jar','ruoyi-admin/target/ruoyi-admin.jar','--business.reporting.check-delay-ms=1500','--business.reporting.initial-delay-ms=1500','--spring.data.redis.database=3','--server.port=18100','--server.address=127.0.0.1','--spring.datasource.druid.master.url=jdbc:mysql://127.0.0.1:3306/'+db+'?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT%2B8'],cwd=back,env=env,stdout=log,stderr=log)
  try:
   for retry in range(90):
    if process.poll() is not None:raise RuntimeError('Server startup failed')
    try:urllib.request.urlopen(env['STAGE02_TEST_URL']+'/captchaImage',timeout=2).close();break
    except Exception:time.sleep(1)
   else:raise RuntimeError('Startup timeout')
   with open(out/f'stage{stage}-cases.log','w',encoding='utf-8') as cases:r=subprocess.run([sys.executable,str(ROOT/'tests'/('stage'+stage)/script)],env=env,stdout=cases,stderr=cases)
   data=json.loads((ROOT/'tests'/('stage'+stage)/'results.json').read_text(encoding='utf-8-sig')) if r.returncode==0 else []
   entry={'stage':stage,'database':db,'exitCode':r.returncode,'passed':sum(x['passed'] for x in data),'total':len(data),'cases':data};all_results.append(entry)
   print('Stage',stage,'exit',r.returncode,'passed',entry['passed'],'/',len(data),flush=True)
  finally:process.terminate();process.wait(timeout=25)
 (out/'regression-results.json').write_text(json.dumps(all_results,ensure_ascii=False,indent=2),encoding='utf-8')
 if r.returncode:raise SystemExit('Regression failed; inspect stage'+stage+'-cases.log')
print('All current-schema regression suites passed.',flush=True)
