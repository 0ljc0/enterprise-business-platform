from pathlib import Path
import argparse,os,re,secrets,subprocess,tempfile,zipfile
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--database',required=True);p.add_argument('--mysql-bin',default='mysql');p.add_argument('--mysql-user',default='root');a=p.parse_args()
if not re.fullmatch(r'ry_platform_[A-Za-z0-9_]{1,40}',a.database):raise ValueError('Use a new ry_platform_* database name')
if not os.environ.get('MYSQL_PWD'):raise RuntimeError('Set MYSQL_PWD for the database administrator first')
jar=ROOT/'RuoYi-Vue-backend/ruoyi-admin/target/ruoyi-admin.jar'
if not jar.exists():raise RuntimeError('Build the backend first')
password=secrets.token_urlsafe(15);env=os.environ.copy();env['BOOTSTRAP_PASSWORD']=password
with tempfile.TemporaryDirectory() as tmp:
 folder=Path(tmp)
 with zipfile.ZipFile(jar) as z:
  for n in z.namelist():
   if n.startswith('BOOT-INF/lib/') and ('spring-security-crypto-' in n or 'spring-jcl-' in n):(folder/Path(n).name).write_bytes(z.read(n))
 subprocess.run(['javac','-cp',str(folder/'*'),'-d',str(folder),str(ROOT/'deploy/stage10/tools/PasswordHash.java')],check=True)
 encoded=subprocess.check_output(['java','-cp',str(folder)+os.pathsep+str(folder/'*'),'PasswordHash'],env=env,text=True).strip()
mysql=[a.mysql_bin,'-h','127.0.0.1','-u',a.mysql_user,'--default-character-set=utf8mb4']
def sql(text,db=None):subprocess.run(mysql+([db] if db else []),input=text.encode('utf-8'),check=True,stdout=subprocess.DEVNULL)
sql('CREATE DATABASE `'+a.database+'` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
sql((ROOT/'database/init.sql').read_text(encoding='utf-8-sig'),a.database)
sql("UPDATE sys_user SET password='"+encoded+"',status='0',pwd_update_date=NOW() WHERE user_id=1;",a.database)
file=ROOT/'initial-admin.local.txt';file.write_text('admin\n'+password+'\n',encoding='utf-8')
if os.name=='nt':
 who=subprocess.check_output(['whoami'],text=True).strip();subprocess.run(['icacls',str(file),'/inheritance:r','/grant:r',who+':(F)','SYSTEM:(F)'],check=True,stdout=subprocess.DEVNULL)
else:file.chmod(0o600)
print('Initialized new database. Initial administrator is saved in ignored initial-admin.local.txt; protect this file.')
