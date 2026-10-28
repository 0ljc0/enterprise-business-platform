"""Build a clean release bundle; no demo accounts or local runtime secrets."""
from pathlib import Path
import os,re,subprocess,datetime,json,hashlib,zipfile,shutil
ROOT=Path(__file__).resolve().parents[2];back=ROOT/'RuoYi-Vue-backend';here=Path(__file__).parent
release_root=(ROOT/'release.local').resolve();bundle=(release_root/'stage10').resolve()
if bundle.parent!=release_root or bundle.name!='stage10':raise RuntimeError('Unexpected staging path')
if (bundle/'config/runtime.local.json').exists():raise RuntimeError('Refusing to package initialized runtime secrets')
if bundle.exists():shutil.rmtree(bundle)
bundle.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
db='ry_platform_cleaninit_'+datetime.datetime.now().strftime('%Y%m%d%H%M%S')
mysql=['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4']
def sql(query,database=None):subprocess.run(mysql+([database] if database else []),input=query.encode(),env=env,check=True,stdout=subprocess.DEVNULL)
sql('CREATE DATABASE '+db+' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
migrations=['sql/ry_20260417.sql','sql/quartz.sql','sql/stage02/01_schema.sql','sql/stage02/02_permissions.sql','sql/stage03/01_company_onboarding.sql','sql/stage04/01_employee.sql','sql/stage05/01_personnel_access.sql','sql/stage06/01_daily_reporting.sql','sql/stage07/01_tasks_signup.sql','sql/stage07/02_company_internal_only.sql','sql/stage08/01_execution.sql','sql/stage09/01_statistics.sql']
for path in migrations:sql((back/path).read_text(encoding='utf-8-sig'),db)
sql("DELETE FROM sys_user_role WHERE user_id<>1; DELETE FROM sys_user_post; DELETE FROM sys_user WHERE user_id<>1; UPDATE sys_user SET password='!BOOTSTRAP_REQUIRED',status='1',email='',phonenumber='' WHERE user_id=1; DELETE FROM sys_job; DELETE FROM sys_job_log; DELETE FROM sys_notice; DELETE FROM sys_oper_log; DELETE FROM sys_logininfor; UPDATE sys_config SET config_value='false' WHERE config_key='sys.account.registerUser'; UPDATE sys_config SET config_value='true' WHERE config_key='sys.account.captchaEnabled';",db)
for name in ['sql','config','tools/lib','nginx/conf','nginx/logs','logs','uploads','run','backups']:(bundle/name).mkdir(parents=True,exist_ok=True)
with open(bundle/'sql/init.sql','wb') as file:subprocess.run(['D:/mysql/bin/mysqldump.exe','-h','127.0.0.1','-u','root','--no-tablespaces','--set-gtid-purged=OFF','--hex-blob','--skip-dump-date',db],env=env,stdout=file,check=True)
with open(bundle/'sql/schema-only.sql','wb') as file:subprocess.run(['D:/mysql/bin/mysqldump.exe','-h','127.0.0.1','-u','root','--no-data','--no-tablespaces','--set-gtid-purged=OFF','--skip-dump-date',db],env=env,stdout=file,check=True)
shutil.copy2(back/'ruoyi-admin/target/ruoyi-admin.jar',bundle/'app.jar')
# Remove developer connection credentials from the distributed executable itself.
with zipfile.ZipFile(bundle/'app.jar') as source, zipfile.ZipFile(bundle/'app.sanitized.jar','w') as target:
 for info in source.infolist():
  data=source.read(info.filename)
  if info.filename=='BOOT-INF/classes/application-druid.yml':
   text=data.decode('utf-8').replace('\r\n','\n');text=re.sub(r'(?m)^(\s*username:) root$',r'\1 ${APP_DB_USER}',text);text=re.sub(r'(?m)^(\s*url:) jdbc:.*$',r'\1 ${APP_DB_URL}',text);text=re.sub(r'(?m)^(\s*password:) .+$',r'\1 ${APP_DB_PASSWORD}',text);text=re.sub(r'(?m)^(\s*login-password:) .+$',r'\1 ${APP_DRUID_PASSWORD:disabled}',text);data=text.encode()
  if info.filename=='BOOT-INF/classes/application.yml':data=data.replace(b'secret: abcdefghijklmnopqrstuvwxyz',b'secret: ${APP_TOKEN_SECRET}')
  target.writestr(info,data)
(bundle/'app.sanitized.jar').replace(bundle/'app.jar')
shutil.copytree(ROOT/'RuoYi-Vue3/dist',bundle/'nginx/html',dirs_exist_ok=True)
nginx=here/'downloads.local/nginx-1.31.8';shutil.copy2(nginx/'nginx.exe',bundle/'nginx/nginx.exe');shutil.copy2(nginx/'conf/mime.types',bundle/'nginx/conf/mime.types');shutil.copy2(nginx/'docs/LICENSE',bundle/'nginx/LICENSE')
(bundle/'nginx/licenses').mkdir(exist_ok=True)
for file in (nginx/'docs').iterdir():
 if file.is_file() and ('LICEN' in file.name):shutil.copy2(file,bundle/'nginx/licenses'/file.name)
shutil.copy2(here/'nginx-source.json',bundle/'nginx/source.json');shutil.copy2(here/'nginx.conf.template',bundle/'config/nginx.conf.template')
if (ROOT/'docs/stage10').exists():shutil.copytree(ROOT/'docs/stage10',bundle/'docs',dirs_exist_ok=True)
for file in (here/'tools').glob('*'):
 if file.is_file():shutil.copy2(file,bundle/'tools'/file.name)
with zipfile.ZipFile(bundle/'app.jar') as archive:
 for name in archive.namelist():
  if name.startswith('BOOT-INF/lib/') and ('spring-security-crypto-' in name or 'spring-jcl-' in name):(bundle/'tools/lib'/Path(name).name).write_bytes(archive.read(name))
subprocess.run(['javac','-cp',str(bundle/'tools/lib/*'),'-d',str(bundle/'tools/lib'),str(bundle/'tools/PasswordHash.java')],check=True)
(bundle/'README.txt').write_text('Windows验收部署包。要求JDK17+、Python3.10+、MySQL8、Redis。\n首次安装: python tools/manage.py init --database ry_platform_newsite\n启动: python tools/manage.py start\n停止: python tools/manage.py stop\n管理员凭据生成到config/initial-admin.local.txt。默认访问 http://127.0.0.1:18081 。\n完整说明见源码 docs/stage10。不要把验收数据库作为生产库。\n',encoding='utf-8')
manifest={str(f.relative_to(bundle)).replace('\\','/'):hashlib.sha256(f.read_bytes()).hexdigest() for f in bundle.rglob('*') if f.is_file() and f.name!='manifest.json'}
(bundle/'manifest.json').write_text(json.dumps({'builtAt':datetime.datetime.now().isoformat(),'initDatabase':db,'files':manifest},indent=2),encoding='utf-8')
archive=shutil.make_archive(str(ROOT/'release.local/ruoyi-stage10-clean'),'zip',bundle)
print('Clean package:',archive,'files:',len(manifest),'bootstrap admin locked until init')
