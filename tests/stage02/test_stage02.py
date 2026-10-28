import os
from pathlib import Path
os.chdir(Path(__file__).resolve().parents[2])
import json,urllib.request,urllib.error,socket,time
from pathlib import Path
base=os.environ.get('STAGE02_TEST_URL','http://127.0.0.1:18082')
def api(path,token=None,method='GET',data=None):
 headers={'Content-Type':'application/json'}
 if token:headers['Authorization']='Bearer '+token
 req=urllib.request.Request(base+path,data=json.dumps(data).encode() if data is not None else None,headers=headers,method=method)
 try:
  with urllib.request.urlopen(req,timeout=20) as r:return json.load(r)
 except urllib.error.HTTPError as e:
  try:return json.load(e)
  except:return {'code':e.code}
def redis(*args):
 s=socket.create_connection(('127.0.0.1',6379),5);f=s.makefile('rb')
 def cmd(*parts):
  parts=[str(x).encode() for x in parts];s.sendall(b'*'+str(len(parts)).encode()+b'\r\n'+b''.join(b'$'+str(len(x)).encode()+b'\r\n'+x+b'\r\n' for x in parts));line=f.readline()
  if line[:1]==b'$':
   n=int(line[1:]);return None if n<0 else f.read(n+2)[:-2].decode()
  return line[1:].strip().decode()
 cmd('SELECT',int(os.environ.get('STAGE02_REDIS_DB','2')));out=cmd(*args);s.close();return out
password=Path('seed-credentials.local.txt').read_text(encoding='utf-8-sig').splitlines()[0].strip()
results=[]
def check(name,condition,detail=''):
 results.append({'case':name,'passed':bool(condition),'detail':str(detail)});print(('PASS ' if condition else 'FAIL ')+name)
def login(name):
 captcha=api('/captchaImage');raw=redis('GET','captcha_codes:'+captcha['uuid']);code=json.loads(raw)
 r=api('/login',method='POST',data={'username':name,'password':password,'code':str(code),'uuid':captcha['uuid']})
 if r.get('code')!=200:raise RuntimeError(name+': '+str(r))
 return r['token']
for n in range(30):
 try:api('/captchaImage');break
 except Exception:time.sleep(1)
users=['s2_platform','s2_a_admin','s2_a_hr','s2_a_business','s2_a_finance','s2_a_employee','s2_b_admin','s2_b_employee','s2_unbound'];tokens={}
for name in users:
 token=login(name);tokens[name]=token
 info=api('/getInfo',token);routes=api('/getRouters',token)
 check(name+' login/menu',info.get('code')==200 and routes.get('code')==200 and ('业务平台' in json.dumps(routes,ensure_ascii=False)))
 if name=='s2_a_finance':check('财务无写权限','biz:daily_output:edit' not in info.get('permissions',[]))
 if name=='s2_a_employee':check('员工无系统授权权限',not any(p.startswith('system:') for p in info.get('permissions',[])))
a=tokens['s2_a_admin'];b=tokens['s2_b_admin'];plat=tokens['s2_platform'];fin=tokens['s2_a_finance'];emp=tokens['s2_a_employee']
r=api('/biz/daily_output/list',a);check('A列表仅企业A',r.get('code')==200 and r['data']['total']==1 and all(x['company_id']==1 for x in r['data']['rows']))
r=api('/biz/daily_output/list',b);check('B列表仅企业B',r.get('code')==200 and r['data']['total']==1 and all(x['company_id']==2 for x in r['data']['rows']))
r=api('/biz/daily_output/list',plat);check('平台跨企业查询',r.get('code')==200 and r['data']['total']==2)
check('A伪造companyId拒绝',api('/biz/daily_output/list?companyId=2',a).get('code')==403)
check('A直接读取B编号拒绝',api('/biz/daily_output/2',a).get('code')==404)
body={'companyId':1,'outputDate':'2026-10-23','outputValue':123,'unit':'元','remark':'stage02 test','version':0}
check('A修改B记录拒绝',api('/biz/daily_output/2',a,'PUT',body).get('code')==404)
check('财务直接修改拒绝',api('/biz/daily_output/1',fin,'PUT',body).get('code')==403)
check('员工产值接口拒绝',api('/biz/daily_output/list',emp).get('code')==403)
check('无归属账号拒绝',api('/biz/employee_info/list',tokens['s2_unbound']).get('code')==403)
check('无token拒绝',api('/biz/daily_output/list').get('code')==401)
check('非法模块拒绝',api('/biz/not_a_table/list',a).get('code')==400)
check('非法分页拒绝',api('/biz/daily_output/list?pageSize=1000',a).get('code')==400)
check('负产值拒绝',api('/biz/daily_output/1',a,'PUT',{**body,'outputValue':-1}).get('code')==400)
check('归属不可转移',api('/biz/daily_output/1',a,'PUT',{**body,'companyId':2}).get('code')==403)
check('正常编辑成功',api('/biz/daily_output/1',a,'PUT',body).get('code')==200)
check('旧版本重复更新拒绝',api('/biz/daily_output/1',a,'PUT',body).get('code')==409)
r=api('/biz/daily_output/2',b);check('B数据未被修改',r.get('code')==200 and float(r['data']['output_value'])==200)
check('A伪造企业新增拒绝',api('/biz/daily_output',a,'POST',{**body,'companyId':2,'outputDate':'2026-10-24'}).get('code')==403)
check('正常新增成功',api('/biz/daily_output',a,'POST',{**body,'companyId':None,'outputDate':'2026-10-24'}).get('code')==200)
check('员工档案仅本人',all(x['user_id']==205 for x in api('/biz/employee_info/list',emp)['data']['rows']))
check('员工不可读同企业他人档案',api('/biz/employee_info/1',emp).get('code')==404)
Path('stage02-test-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
