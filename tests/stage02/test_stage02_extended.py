import os
from pathlib import Path
os.chdir(Path(__file__).resolve().parents[2])
from pathlib import Path
import os,re,subprocess,json
# Reuse only the API helpers, without rerunning the mutation test sequence.
exec(Path('tests/stage02/test_stage02.py').read_text(encoding='utf-8-sig').split('for n in range(30):')[0])
text=Path('RuoYi-Vue-backend/ruoyi-admin/src/main/resources/application-druid.yml').read_text(encoding='utf-8-sig');env=os.environ.copy();env['MYSQL_PWD']=os.environ['MYSQL_PWD']
def sql(q,ok=True):
 r=subprocess.run(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','--default-character-set=utf8mb4',os.environ.get('STAGE02_TEST_DB','ry_platform_stage02')],input=q.encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE,env=env)
 if ok and r.returncode:raise RuntimeError(r.stderr.decode(errors='replace'))
 return r.returncode
sample="""INSERT INTO biz_task(id,company_id,task_code,title,status) VALUES(1,1,'S2-A','A任务','EXECUTING'),(2,2,'S2-B','B任务','EXECUTING');
INSERT INTO biz_task_signup(id,company_id,task_id,contact_user_id,promised_quantity,status) VALUES(1,1,1,201,10,'APPROVED'),(2,2,2,206,10,'APPROVED');
INSERT INTO biz_task_assignment(id,company_id,task_id,signup_id,user_id,assigned_quantity,status) VALUES(1,1,1,1,205,10,'EXECUTING'),(2,2,2,2,207,10,'EXECUTING');
INSERT INTO biz_work_record(id,company_id,assignment_id,user_id,work_date,quantity,status) VALUES(1,1,1,205,'2026-10-23',2,'DRAFT'),(2,2,2,207,'2026-10-23',3,'DRAFT');"""
admin=login('s2_a_admin');emp=login('s2_a_employee');platform=login('s2_platform')
modules=['company','company_apply','employee_apply','employee_info','access_permission','daily_output','project','task','task_signup','task_assignment','work_record','audit_record']
for m in modules:
 r=api('/biz/'+m+'/list',admin);check(m+' A查询隔离',r.get('code')==200 and all((x['id']==1 if m=='company' else x.get('company_id')==1) for x in r.get('data',{}).get('rows',[])))
for m in ['task','task_assignment','work_record']:
 r=api('/biz/'+m+'/list',emp);check(m+' 员工本人范围',r.get('code')==200 and r['data']['total']==1 and r['data']['rows'][0]['id']==1)
 check(m+' 员工拒绝跨企业详情',api('/biz/'+m+'/2',emp).get('code')==404)
check('表名SQL注入拒绝',api('/biz/company%20union%20select/list',admin).get('code')!=200)
queries={
 '重复有效企业归属拒绝':"INSERT INTO biz_company_user(company_id,user_id) VALUES(2,205)",
 '跨企业分配外键拒绝':"INSERT INTO biz_task_assignment(company_id,task_id,signup_id,user_id,assigned_quantity) VALUES(2,1,1,207,1)",
 '跨企业工作记录外键拒绝':"INSERT INTO biz_work_record(company_id,assignment_id,user_id,work_date,quantity) VALUES(2,1,207,'2026-10-25',1)",
 '重复每日填报拒绝':"INSERT INTO biz_daily_output(company_id,output_date,output_value) VALUES(1,'2026-10-23',1)",
 '申请人自审拒绝':"INSERT INTO biz_audit_record(company_id,business_type,business_id,round_no,applicant_id,reviewer_id,from_status,to_status,opinion) VALUES(1,'company_apply',999,1,201,201,'PENDING','APPROVED','test')",
 '平台任务归属约束拒绝':"INSERT INTO biz_task(company_id,task_code,title,publisher_type) VALUES(1,'BAD','bad','PLATFORM')"
}
for name,q in queries.items():check(name,sql('START TRANSACTION;'+q+';ROLLBACK;',False)!=0)
# Revoking membership is effective immediately despite an already issued token.
sql("UPDATE biz_company_user SET status='LEFT' WHERE user_id=205;")
try:check('已登录账号离职即时拒绝',api('/biz/work_record/list',emp).get('code')==403)
finally:sql("UPDATE biz_company_user SET status='ACTIVE' WHERE user_id=205;")
# Disabled company also fails closed.
sql("UPDATE biz_company SET status='DISABLED' WHERE id=1;")
try:check('企业停用即时拒绝',api('/biz/daily_output/list',admin).get('code')==403)
finally:sql("UPDATE biz_company SET status='ACTIVE' WHERE id=1;")
old=json.loads(Path('stage02-test-results.json').read_text(encoding='utf-8'));old.extend(results)
Path('stage02-test-results.json').write_text(json.dumps(old,ensure_ascii=False,indent=2),encoding='utf-8')
print('SUMMARY',sum(x['passed'] for x in old),'/',len(old))
if not all(x['passed'] for x in old):raise SystemExit(1)
