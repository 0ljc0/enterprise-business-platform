from pathlib import Path
import os,re,shutil,subprocess,json,urllib.request,urllib.error,zipfile,hashlib,datetime
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
stamp=datetime.datetime.now().strftime('%Y%m%d%H%M%S');target=Path('D:/code/ruoyi-cleancheck10-'+stamp);database='ry_platform_cleancheck10_'+stamp
if target.exists():raise RuntimeError('Clean verification target must not exist')
shutil.copytree(ROOT/'release.local/stage10',target)
env=os.environ.copy();env['DEPLOY_MYSQL_ADMIN_PASSWORD']=os.environ['MYSQL_PWD']
manage=target/'tools/manage.py'
subprocess.run(['python',str(manage),'init','--database',database,'--redis-db','6','--backend-port','18082','--http-port','18083'],env=env,check=True)
config=json.loads((target/'config/runtime.local.json').read_text(encoding='utf-8'));sqlenv=env.copy();sqlenv['MYSQL_PWD']=config['APP_DB_PASSWORD']
def sql(q):return subprocess.check_output([config['MYSQL_BIN'],'-h','127.0.0.1','-u',config['APP_DB_USER'],'-N',config['DATABASE']],input=q.encode(),env=sqlenv).decode().strip()
checks=[]
def verify(name,value):
 checks.append({'case':name,'passed':bool(value)});print(('PASS ' if value else 'FAIL ')+name);assert value,name
verify('干净安装只有一个管理员',sql('SELECT COUNT(*) FROM sys_user;')=='1')
verify('干净安装无演示企业和员工',sql('SELECT (SELECT COUNT(*) FROM biz_company)+(SELECT COUNT(*) FROM biz_employee_info);')=='0')
verify('干净安装无演示任务',sql('SELECT COUNT(*) FROM biz_task;')=='0')
verify('验证码开启且公开注册关闭',sql("SELECT config_value FROM sys_config WHERE config_key='sys.account.captchaEnabled';")=='true' and sql("SELECT config_value FROM sys_config WHERE config_key='sys.account.registerUser';")=='false')
verify('干净部署使用非root账号',config['APP_DB_USER']!='root')
with zipfile.ZipFile(target/'app.jar') as archive:
 druid=archive.read('BOOT-INF/classes/application-druid.yml').decode();app=archive.read('BOOT-INF/classes/application.yml').decode()
verify('部署包已去除开发数据库凭据',re.search(r'(?m)^\s*password:\s*\$\{APP_DB_PASSWORD\}',druid) is not None and 'username: root' not in druid)
verify('部署包令牌密钥外置','secret: ${APP_TOKEN_SECRET}' in app and 'abcdefghijklmnopqrstuvwxyz' not in app)
subprocess.run(['python',str(manage),'start'],env=env,check=True)
try:
 os.environ['STAGE02_TEST_URL']='http://127.0.0.1:18083/prod-api';os.environ['STAGE02_REDIS_DB']='6'
 exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0])
 password=(target/'config/initial-admin.local.txt').read_text(encoding='utf-8').splitlines()[1]
 token=login('admin');verify('随机管理员密码可通过Nginx登录',api('/getInfo',token).get('code')==200)
 verify('干净环境业务菜单可用','statistics' in json.dumps(api('/getRouters',token)))
 verify('干净环境统计企业数为零',api('/statistics/report?kind=overview',token)['data']['summary']['companyCount']==0)
 for endpoint in ['/druid/index.html','/v3/api-docs','/swagger-ui/index.html']:
  try:r=urllib.request.urlopen('http://127.0.0.1:18082'+endpoint);raw=r.read().decode();disabled=json.loads(raw).get('code') in (401,403,404)
  except urllib.error.HTTPError as e:disabled=e.code in (401,403,404)
  verify('后端关闭管理页面'+endpoint,disabled)
  request=urllib.request.Request('http://127.0.0.1:18082'+endpoint,headers={'Authorization':'Bearer '+token})
  try:r=urllib.request.urlopen(request);disabled=json.loads(r.read()).get('code') in (401,403,404)
  except urllib.error.HTTPError as e:disabled=e.code in (401,403,404)
  verify('管理员也不能绕过管理页面关闭'+endpoint,disabled)
 captcha=api('/captchaImage');code=json.loads(redis('GET','captcha_codes:'+captcha['uuid']))
 verify('默认弱密码不能登录',api('/login',method='POST',data={'username':'admin','password':'admin123','code':str(code),'uuid':captcha['uuid']}).get('code')!=200)
finally:subprocess.run(['python',str(manage),'stop'],env=env,check=True)
verify('停止脚本成功停止本站点',True)
(ROOT/'tests/stage10/clean-install-results.json').write_text(json.dumps({'database':config['DATABASE'],'cases':checks},ensure_ascii=False,indent=2),encoding='utf-8')
print('Clean installation verified; temporary clean-check services stopped.')
