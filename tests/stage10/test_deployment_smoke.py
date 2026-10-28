from pathlib import Path
import os,json,urllib.request,urllib.error,hashlib
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
os.environ['STAGE02_TEST_URL']='http://127.0.0.1:18081/prod-api';os.environ['STAGE02_REDIS_DB']='5'
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0])
for name in ['s2_platform','s2_a_admin','s2_a_hr','s2_a_business','s2_a_finance','s2_a_employee','s2_b_admin','s2_b_employee']:
 token=login(name);check(name+'最终部署登录与菜单',api('/getInfo',token).get('code')==200 and api('/getRouters',token).get('code')==200)
admin=login('s2_unbound');row=json.loads((ROOT/'tests/stage10/end-to-end-results.json').read_text(encoding='utf-8'));pid=row['projectId'];company=row['companyId']
project=api(f'/execution/projects/{pid}?companyId={company}',admin)['data'];check('升级后归档状态和确认工作量保留',project['status']=='ARCHIVED' and float(project['confirmedQuantity'])==100)
data=api('/statistics/report?kind=estimates',admin)['data'];estimate=next(x for x in data['rows'] if x['id']==pid);check('升级后报价快照金额保留',float(estimate['plannedEstimate'])==250)
for endpoint in ['/druid/index.html','/swagger-ui/index.html','/v3/api-docs']:
 try:
  response=urllib.request.urlopen(urllib.request.Request('http://127.0.0.1:18080'+endpoint,headers={'Authorization':'Bearer '+admin}));denied=json.loads(response.read()).get('code') in (401,403,404)
 except urllib.error.HTTPError as error:denied=error.code in (401,403,404)
 check('最终后端关闭管理入口'+endpoint,denied)
req=urllib.request.urlopen('http://127.0.0.1:18081/');html=req.read();check('前端安全响应头',req.headers.get('X-Content-Type-Options')=='nosniff' and req.headers.get('X-Frame-Options')=='SAMEORIGIN')
target=Path('D:/code/ruoyi-release10');check('最终运行JAR与干净包一致',hashlib.sha256((target/'app.jar').read_bytes()).digest()==hashlib.sha256((ROOT/'release.local/stage10/app.jar').read_bytes()).digest())
(ROOT/'tests/stage10/deployment-smoke-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
