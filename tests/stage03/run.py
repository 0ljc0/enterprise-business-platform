"""Create a fresh integration database, start a separate backend, and run the cases."""
from pathlib import Path
import os,subprocess,re,datetime,time,urllib.request,sys
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
back=ROOT/'RuoYi-Vue-backend'
config=(back/'ruoyi-admin/src/main/resources/application-druid.yml').read_text(encoding='utf-8-sig')
env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
db='ry_platform_s3test_'+datetime.datetime.now().strftime('%Y%m%d%H%M%S')
base=['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4']
def sql(query,database=None):
 subprocess.run(base+([database] if database else []),input=query.encode('utf-8'),env=env,check=True)
sql('CREATE DATABASE '+db+' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
for path in ['sql/ry_20260417.sql','sql/quartz.sql','sql/stage02/01_schema.sql','sql/stage02/02_permissions.sql','sql/stage02/03_demo.local.sql','sql/stage03/01_company_onboarding.sql']:
 sql((back/path).read_text(encoding='utf-8-sig'),db)
port=18084;env['STAGE02_TEST_DB']=db;env['STAGE02_TEST_URL']='http://127.0.0.1:'+str(port)
with open(ROOT/'tests/stage03/runtime.log','w',encoding='utf-8') as output:
 process=subprocess.Popen(['java','-Dlogging.config=ruoyi-admin/src/main/resources/logback.xml','-jar','ruoyi-admin/target/ruoyi-admin.jar','--server.port='+str(port),'--spring.datasource.druid.master.url=jdbc:mysql://127.0.0.1:3306/'+db+'?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT%2B8'],cwd=back,env=env,stdout=output,stderr=output)
 try:
  ready=False
  for _ in range(60):
   if process.poll() is not None:raise RuntimeError('Test server failed; inspect runtime.log')
   try:
    urllib.request.urlopen(env['STAGE02_TEST_URL']+'/captchaImage',timeout=2).close();ready=True;break
   except Exception:time.sleep(1)
  if not ready:raise RuntimeError('Test server startup timed out')
  for script in ['test_company_onboarding.py']:
   subprocess.run([sys.executable,str(ROOT/'tests/stage03'/script)],env=env,check=True)
 finally:
  process.terminate();process.wait(timeout=20)
print('Test database retained:',db)
