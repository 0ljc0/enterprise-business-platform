import os,json,urllib.request,urllib.error
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
exec((ROOT/'tests/stage02/test_stage02.py').read_text(encoding='utf-8').split('for n in range(30):')[0])
# The runner provides a fresh database for each run.
a=login('s2_unbound');platform=login('s2_platform');other=login('s2_a_employee');admin=login('s2_a_admin')
def upload(token,content=b'%PDF-1.4\n%%EOF',ctype='application/pdf'):
 boundary='stage03Boundary';body=('--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="license.pdf"\r\nContent-Type: '+ctype+'\r\n\r\n').encode()+content+('\r\n--'+boundary+'--\r\n').encode()
 req=urllib.request.Request(base+'/onboarding/licenses',data=body,headers={'Content-Type':'multipart/form-data; boundary='+boundary,'Authorization':'Bearer '+token})
 try:return json.load(urllib.request.urlopen(req))
 except urllib.error.HTTPError as e:return json.load(e)
def code(n):
 chars='0123456789ABCDEFGHJKLMNPQRTUWXY';s='91310000'+str(n).zfill(9);weights=[1,3,9,27,19,26,16,17,20,29,25,13,8,24,10,30,28];return s+chars[(31-sum(chars.index(c)*w for c,w in zip(s,weights))%31)%31]
license=upload(a);check('营业执照上传',license.get('code')==200);lid=license['data']
check('伪装PDF拒绝',upload(a,b'<script>alert(1)</script>').get('code')==400)
body={'companyName':'阶段三测试企业','creditCode':code(1),'contactName':'测试负责人','contactPhone':'13800000001','address':'测试地址','introduction':'测试简介','licenseId':lid}
check('非法信用代码拒绝',api('/onboarding/applications',a,'POST',{**body,'creditCode':'123'}).get('code')==400)
check('冒用他人附件拒绝',api('/onboarding/applications',other,'POST',body).get('code')==400)
r=api('/onboarding/applications',a,'POST',body);check('保存草稿',r.get('code')==200,r);id=r['data']
check('重复申请拒绝',api('/onboarding/applications',a,'POST',body).get('code')==409)
check('本人查看申请',api(f'/onboarding/applications/{id}',a).get('code')==200)
check('其他企业不可读申请',api(f'/onboarding/applications/{id}',other).get('code')==403)
check('无token不可查看',api('/onboarding/applications').get('code')==401)
check('草稿提交',api(f'/onboarding/applications/{id}/submit',a,'POST').get('code')==200)
check('重复提交拒绝',api(f'/onboarding/applications/{id}/submit',a,'POST').get('code')==409)
check('普通用户不可审核',api(f'/onboarding/applications/{id}/review',other,'POST',{'approve':True,'opinion':'违规'}).get('code')==403)
check('空审核意见拒绝',api(f'/onboarding/applications/{id}/review',platform,'POST',{'approve':False,'opinion':''}).get('code')==400)
check('驳回成功',api(f'/onboarding/applications/{id}/review',platform,'POST',{'approve':False,'opinion':'补充企业简介'}).get('code')==200)
r=api(f'/onboarding/applications/{id}',a)['data'];check('驳回意见留存',r['status']=='REJECTED' and r['audits'][0]['opinion']=='补充企业简介')
updated={**body,'introduction':'补充后的简介','version':r['version']}
check('驳回后修改成功',api(f'/onboarding/applications/{id}',a,'PUT',updated).get('code')==200)
check('旧版本修改拒绝',api(f'/onboarding/applications/{id}',a,'PUT',updated).get('code')==409)
check('重新提交成功',api(f'/onboarding/applications/{id}/submit',a,'POST').get('code')==200)
check('审批轮次递增',api(f'/onboarding/applications/{id}',a)['data']['round_no']==2)
check('审核通过成功',api(f'/onboarding/applications/{id}/review',platform,'POST',{'approve':True,'opinion':'审核通过'}).get('code')==200)
check('重复审批拒绝',api(f'/onboarding/applications/{id}/review',platform,'POST',{'approve':True,'opinion':'重复'}).get('code')==409)
r=api(f'/onboarding/applications/{id}',a)['data'];check('通过状态及双轮轨迹',r['status']=='APPROVED' and len(r['audits'])==2 and r['company_id'] is not None)
a=login('s2_unbound');info=api('/getInfo',a);check('重新登录获得企业管理员角色','company_admin' in info['roles']);companies=api('/onboarding/companies',a);check('企业正常且仅看自己',companies.get('code')==200 and len(companies['data'])==1 and companies['data'][0]['status']=='ACTIVE');company=companies['data'][0]
check('企业资料修改',api('/onboarding/companies/'+str(company['id']),a,'PUT',{**body,'companyName':'更新后的企业','version':company['version']}).get('code')==200)
check('企业不可修改其他企业',api('/onboarding/companies/1',a,'PUT',{**body,'version':0}).get('code')==403)
check('已入驻账号不可重复申请',api('/onboarding/applications',a,'POST',body).get('code')==409)
# A platform actor must never self-approve.
pl=upload(platform)['data'];r=api('/onboarding/applications',platform,'POST',{**body,'creditCode':code(2),'licenseId':pl});pid=r['data'];api(f'/onboarding/applications/{pid}/submit',platform,'POST')
check('禁止平台自审',api(f'/onboarding/applications/{pid}/review',platform,'POST',{'approve':True,'opinion':'自审'}).get('code')==403)
def download(token):
 req=urllib.request.Request(base+'/onboarding/licenses/'+str(lid),headers={'Authorization':'Bearer '+token})
 try:
  with urllib.request.urlopen(req) as response:return response.status,response.read()
 except urllib.error.HTTPError as e:return e.code,e.read()
check('本人可下载执照',download(a)[0]==200)
check('平台可下载执照',download(platform)[0]==200)
status,raw=download(other)
try:denied=json.loads(raw).get('code')==403
except:denied=status==403
check('其他企业禁止下载执照',denied)
Path('tests/stage03/results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
