import os,json,re,subprocess,urllib.request,urllib.error,urllib.parse,zipfile,io,xml.etree.ElementTree as ET
from decimal import Decimal
from datetime import datetime,timedelta
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];os.chdir(ROOT)
exec((ROOT/'tests/stage08/test_execution.py').read_text(encoding='utf-8').split('tid,sid=make();')[0])
def stats(kind,token=a,company=None,fromDay=None,toDay=None,group='DAY'):
 params={'kind':kind,'pageSize':100,'group':group}
 if company is not None:params['companyId']=company
 if fromDay:params['from']=str(fromDay)
 if toDay:params['to']=str(toDay)
 return api('/statistics/report?'+urllib.parse.urlencode(params),token)
def quote(tid,price,token=a,version=0):return api(f'/statistics/prices/{tid}',token,'PUT',{'unitPrice':str(price),'version':version,'opinion':'任务发布方报价'})
def estimate(pid,token=a,company=None):return next(x for x in stats('estimates',token,company)['data']['rows'] if x['id']==pid)
# First quote at association time freezes a project snapshot.
tid,sid=make(100);check('任务发布方报价',quote(tid,'2.1250').get('code')==200)
pid=link(sid,name='报价项目A')['data'];aa=assignment(pid,sid,205,100)['data'];claim(aa,e);ww=save(aa,e,40)['data'];submit(aa,ww,e);review(pid,ww)
row=estimate(pid);check('计划工作量按快照单价估值',Decimal(row['plannedEstimate'])==Decimal('212.50'))
check('实际确认工作量独立展示',Decimal(row['confirmedQuantity'])==40 and Decimal(row['confirmedEstimate'])==85)
check('进度仅计已确认量',Decimal(row['percent'])==40)
check('发布方更新报价',quote(tid,'3',version=1).get('code')==200)
check('已有项目快照不随任务报价重算',Decimal(estimate(pid)['plannedEstimate'])==Decimal('212.50'))
check('报价旧版本拒绝',quote(tid,'4',version=0).get('code')==409)
check('负报价拒绝',quote(tid,'-1',version=2).get('code')==400)
check('报价超过四位小数拒绝',quote(tid,'1.12345',version=2).get('code')==400)
check('财务不能修改任务报价',quote(tid,'2',f,2).get('code')==403)
check('平台不能改企业发布方报价',quote(tid,'2',p,2).get('code')==403)
check('其他企业不能改报价',quote(tid,'2',bad,2).get('code')==403)
# Missing price is null, not zero; only an active project can explicitly fill its missing snapshot.
t2,s2=make(10);p2=link(s2,name='缺价项目')['data'];check('未报价不按零估算',estimate(p2)['plannedEstimate'] is None and estimate(p2)['unpricedTaskCount']==1)
quote(t2,'4');check('已有缺价项目不被自动覆盖',estimate(p2)['plannedEstimate'] is None)
check('本企业主动补录缺失快照',api(f'/statistics/projects/{p2}/price-snapshot',a,'POST',{'opinion':'补充发布方报价'}).get('data')==1)
check('补录后金额可计算',Decimal(estimate(p2)['plannedEstimate'])==40)
check('快照补录幂等且不覆盖',api(f'/statistics/projects/{p2}/price-snapshot',a,'POST',{'opinion':'重复补录'}).get('data')==0)
check('其他企业不能补录快照',api(f'/statistics/projects/{p2}/price-snapshot',bad,'POST',{'opinion':'越权'}).get('code')==404)
# An archived unpriced project remains unpriced.
br=api('/tasks',bad,'POST',{**body,'title':'企业B归档项目','targetQuantity':20});bt=br['data'];tr=api('/tasks/'+str(bt),bad)['data'];api(f'/tasks/{bt}/publish',bad,'POST',{'version':tr['version']});bs=api(f'/tasks/{bt}/signups',bad,'POST',{'quantity':20})['data'];bp=api('/execution/projects',bad,'POST',{'signupId':bs,'projectName':'B已归档缺价'})['data']
bb=assignment(bp,bs,207,20,bad)['data'];claim(bb,be);bw=save(bb,be,20)['data'];submit(bb,bw,be);recordB=record(bb,bw,be);api(f'/execution/records/{bw}/review',bad,'POST',{'version':recordB['version'],'approve':True,'opinion':'确认'});finish(bb,be)
for action in ['complete','archive']:
 current=api(f'/execution/projects/{bp}?companyId=2',bad)['data'];api(f'/execution/projects/{bp}/{action}',bad,'POST',{'version':current['version'],'opinion':'完成归档'})
quote(bt,'5',bad);check('归档项目禁止补录报价',api(f'/statistics/projects/{bp}/price-snapshot',bad,'POST',{'opinion':'归档补价'}).get('code')==409)
check('归档缺价报表保留未报价',estimate(bp,bad,2)['plannedEstimate'] is None)
# Same platform task can have different first-linked snapshots after a quote revision.
gt=api('/tasks',p,'POST',{**body,'title':'平台报价快照','targetQuantity':20,'maxCompanies':2,'audience':'SHARED'})['data'];tr=api('/tasks/'+str(gt),p)['data'];api(f'/tasks/{gt}/publish',p,'POST',{'version':tr['version']})
gs=[]
for token in [a,bad]:
 ss=api(f'/tasks/{gt}/signups',token,'POST',{'quantity':10})['data'];api(f'/tasks/signups/{ss}/review',p,'POST',{'version':0,'approve':True,'opinion':'通过'});gs.append(ss)
quote(gt,'1.25',p);ga=link(gs[0],name='平台报价A')['data'];quote(gt,'1.5',p,1);gb=api('/execution/projects',bad,'POST',{'signupId':gs[1],'projectName':'平台报价B'})['data']
check('新旧项目分别保留报价快照',Decimal(estimate(ga)['plannedEstimate'])==Decimal('12.50') and Decimal(estimate(gb,bad,2)['plannedEstimate'])==15)
# A draft unit change invalidates an existing per-unit quote.
draft=api('/tasks',a,'POST',{**body,'title':'单位变更作废报价'})['data'];quote(draft,'10');tr=api('/tasks/'+str(draft),a)['data'];api('/tasks/'+str(draft),a,'PUT',{**body,'title':'单位变更作废报价','unit':'小时','version':tr['version']})
check('任务单位变更后旧报价失效',api('/tasks/'+str(draft),a)['data']['unit_price'] is None)
# Reporting fixtures are inserted only in the dedicated test database.
config=(ROOT/'RuoYi-Vue-backend/ruoyi-admin/src/main/resources/application-druid.yml').read_text(encoding='utf-8-sig');env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
def sql(q):
 database=env['STAGE02_TEST_DB']
 if not database.startswith('ry_platform_s9test_'):raise RuntimeError('Dedicated test database required')
 return subprocess.run(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4','-N',database],input=q.encode(),env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True).stdout.decode().strip()
sql(f"UPDATE biz_daily_output SET output_date='{today}',output_value=123.45,status='SUBMITTED' WHERE id=1; UPDATE biz_daily_output SET output_date='{today}',output_value=200,status='CONFIRMED' WHERE id=2; INSERT INTO biz_daily_output(company_id,output_date,output_value,unit,status) VALUES(1,'{today-timedelta(days=1)}',10,'元','DRAFT'),(1,'{today-timedelta(days=2)}',20,'元','RETURNED');")
check('平台工作台企业数',stats('overview',p)['data']['summary']['companyCount']==2)
check('平台工作台员工去重人数',stats('overview',p)['data']['summary']['employeeCount']==7)
check('平台工作台项目数',stats('overview',p)['data']['summary']['projectCount']==5)
check('平台本月产值仅计已报',Decimal(stats('overview',p)['data']['summary']['monthReportedValue'])==Decimal('323.45'))
check('企业工作台范围正确',stats('overview',a)['data']['summary']['companyCount']==1 and Decimal(stats('overview',a)['data']['summary']['monthReportedValue'])==Decimal('123.45'))
check('日趋势与已报明细一致',sum(Decimal(x['reported']) for x in stats('outputs',p)['data']['trend'])==Decimal('323.45'))
check('月趋势与已报明细一致',sum(Decimal(x['reported']) for x in stats('outputs',p,group='MONTH')['data']['trend'])==Decimal('323.45'))
check('草稿退回金额单列',Decimal(stats('outputs',a)['data']['summary']['draftValue'])==10 and Decimal(stats('outputs',a)['data']['summary']['returnedValue'])==20)
check('财务可查看本企业产值',stats('outputs',f).get('code')==200)
check('跨企业统计查询拒绝',stats('outputs',a,2).get('code')==403)
check('人事无财务统计权限',stats('outputs',hr).get('code')==403)
check('人事仅获得人员报表',set(x['key'] for x in api('/statistics/options',hr)['data']['kinds'])=={'personnel'})
check('人事员工档案范围',stats('personnel',hr)['data']['summary']['profileCount']==5)
check('财务无人员明细权限',stats('personnel',f).get('code')==403)
check('业务岗无财务核对报表权限',stats('reconciliation',business).get('code')==403)
check('普通员工无统计工作台',api('/statistics/options',e).get('code')==403)
check('企业无平台全量报表',stats('full',a).get('code')==403)
check('平台可查全量业务报表',stats('full',p).get('code')==200)
check('非法报表类型拒绝',stats('unknown',p).get('code')==400)
check('非法分组拒绝',stats('outputs',p,group='YEAR').get('code')==400)
check('过大日期区间拒绝',stats('outputs',p,fromDay=today-timedelta(days=400),toDay=today).get('code')==400)
check('项目统计与执行明细一致',Decimal(estimate(pid)['confirmedQuantity'])==Decimal(str(progress(pid)['confirmedQuantity'])))
# A financial reconciliation must expand partial date filters to full natural months.
last=today.replace(day=1)-timedelta(days=1);month=str(last)[:7];fixture=last.replace(day=15)
sql(f"INSERT INTO biz_daily_output(company_id,output_date,output_value,unit,status) VALUES(1,'{fixture}',50,'元','CONFIRMED'),(2,'{fixture}',80,'元','SUBMITTED'); INSERT INTO biz_report_month(company_id,report_month,status,version) VALUES(1,'{month}','CONFIRMED',1); INSERT INTO biz_report_month_audit(company_id,report_month,action,record_count,total_value,opinion,reviewer_id) VALUES(1,'{month}','CONFIRMED',1,50,'快照测试',200);")
recon=stats('reconciliation',p,fromDay=last.replace(day=20),toDay=last.replace(day=21))['data']['rows'];ra=next(x for x in recon if x['company_id']==1);rb=next(x for x in recon if x['company_id']==2)
check('财务按完整自然月核对',Decimal(ra['reportedValue'])==50 and Decimal(ra['snapshotValue'])==50 and Decimal(ra['difference'])==0)
check('无快照不伪造零差异',rb['snapshotValue'] is None and rb['difference'] is None and rb['checkStatus']=='UNREVIEWED')
# Use an authorized personal update to insert formula-looking text for Excel validation.
profile=api('/employees/me',e)['data'];api('/employees/me/'+str(profile['id']),e,'PUT',{'realName':'=2+2','contactPhone':'13800000001','version':profile['version']})
ns={'m':'http://schemas.openxmlformats.org/spreadsheetml/2006/main','r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
def workbook(kind,token=a,company=None):
 params={'kind':kind}
 if company is not None:params['companyId']=company
 req=urllib.request.Request(base+'/statistics/export?'+urllib.parse.urlencode(params),headers={'Authorization':'Bearer '+token})
 try:
  with urllib.request.urlopen(req) as response:raw=response.read()
 except urllib.error.HTTPError as err:raw=err.read()
 if not raw.startswith(b'PK'):return json.loads(raw),None
 folder=ROOT/'tests/stage09/artifacts';folder.mkdir(exist_ok=True);(folder/(kind+'-'+str(company or 'scope')+'.xlsx')).write_bytes(raw)
 z=zipfile.ZipFile(io.BytesIO(raw));book=ET.fromstring(z.read('xl/workbook.xml'));rels=ET.fromstring(z.read('xl/_rels/workbook.xml.rels'));targets={x.attrib['Id']:x.attrib['Target'] for x in rels};shared=[]
 if 'xl/sharedStrings.xml' in z.namelist():shared=[''.join(x.itertext()) for x in ET.fromstring(z.read('xl/sharedStrings.xml'))]
 sheets={};formula=False
 for sheet in book.find('m:sheets',ns):
  target=targets[sheet.attrib['{'+ns['r']+'}id']];path=target.lstrip('/') if target.startswith('/') else 'xl/'+target;root=ET.fromstring(z.read(path));rows=[]
  formula|=bool(root.findall('.//m:f',ns))
  for row in root.findall('.//m:sheetData/m:row',ns):
   values={}
   for cell in row:
    value=cell.find('m:v',ns);text=''.join(t.text or '' for t in cell.findall('.//m:t',ns))
    if cell.attrib.get('t')=='s':text=shared[int(value.text)]
    elif value is not None:text=value.text
    values[cell.attrib['r']]=(text,cell.attrib.get('t'))
   rows.append(values)
  sheets[sheet.attrib['name']]={'rows':rows,'freeze':bool(root.findall('.//m:pane',ns)),'filter':bool(root.findall('.//m:autoFilter',ns))}
 return {'sheets':sheets,'formula':formula,'external':any(x.startswith('xl/externalLinks/') for x in z.namelist())},raw
for category in ['overview','outputs','projects','estimates','personnel','reconciliation','full']:
 book,raw=workbook(category,p);check(category+' Excel可解析',raw is not None and len(book['sheets'])>=3)
book,raw=workbook('personnel',hr);check('Excel中文工作表与冻结筛选',all(x['freeze'] and x['filter'] for x in book['sheets'].values()))
check('Excel公式样文本不执行',not book['formula'] and not book['external'] and any(v[0]=='=2+2' for sheet in book['sheets'].values() for row in sheet['rows'] for v in row.values()))
book,raw=workbook('outputs',a,2);check('跨企业Excel导出拒绝',raw is None and book.get('code')==403)
book,raw=workbook('full',a);check('企业伪造全量导出拒绝',raw is None and book.get('code')==403)
book,raw=workbook('reconciliation',hr);check('人事财务Excel导出拒绝',raw is None and book.get('code')==403)
book,raw=workbook('outputs',e);check('普通员工Excel导出拒绝',raw is None and book.get('code')==403)
book,raw=workbook('full',p);check('平台全量Excel包含业务分表',{'企业','人员档案','项目执行','每日业务产值','月度核对','工作量明细'}<=set(book['sheets']))
# Precision must be preserved in JSON and the spreadsheet's string cells.
sql("UPDATE biz_daily_output SET output_value=1234567890123456.78 WHERE id=1;")
try:
 check('报表金额精度不经浮点丢失',stats('outputs',a)['data']['summary']['reportedValue']=='1234567890123456.78')
 book,raw=workbook('outputs',a);check('Excel高精度金额按文本完整保留',any(v[0]=='1234567890123456.78' and v[1] in ['inlineStr','s'] for sheet in book['sheets'].values() for row in sheet['rows'] for v in row.values()))
finally:sql('UPDATE biz_daily_output SET output_value=123.45 WHERE id=1;')
check('匿名报表查询拒绝',api('/statistics/report?kind=overview').get('code')==401)
Path('tests/stage09/results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in results),'/',len(results))
if not all(x['passed'] for x in results):raise SystemExit(1)
