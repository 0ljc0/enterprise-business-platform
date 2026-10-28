import os
from pathlib import Path
os.chdir(Path(__file__).resolve().parents[2])
from pathlib import Path
import json
exec(Path('tests/stage02/test_stage02.py').read_text(encoding='utf-8-sig').split('for n in range(30):')[0])
expected={
's2_platform':{'company','company_apply','employee_apply','employee_info','access_permission','daily_output','task','task_signup','task_assignment','project','work_record','audit_record'},
's2_a_admin':{'company','company_apply','employee_apply','employee_info','access_permission','daily_output','task','task_signup','task_assignment','project','work_record','audit_record'},
's2_a_hr':{'employee_apply','employee_info','access_permission'},
's2_a_business':{'company','daily_output','task','task_signup','task_assignment','project','work_record'},
's2_a_finance':{'company','daily_output','project','work_record'},
's2_a_employee':{'employee_apply','employee_info','task','task_assignment','work_record'}}
for name,wanted in expected.items():
 token=login(name);r=api('/getRouters',token)
 parents=r.get('data',[]);children=[x['path'] for parent in parents for x in parent.get('children',[]) if parent.get('path')=='/business']
 check(name+' 精确菜单矩阵',set(children)==wanted,children)
 perms=set(api('/getInfo',token).get('permissions',[]));writes={p for p in perms if p.endswith(':add') or p.endswith(':edit')}
 check(name+' 精确按钮矩阵',writes==({'biz:daily_output:add','biz:daily_output:edit'} if name in ['s2_platform','s2_a_admin','s2_a_business'] else set()))
old=json.loads(Path('stage02-test-results.json').read_text(encoding='utf-8'));old.extend(results);Path('stage02-test-results.json').write_text(json.dumps(old,ensure_ascii=False,indent=2),encoding='utf-8');print('SUMMARY',sum(x['passed'] for x in old),'/',len(old))
if not all(x['passed'] for x in old):raise SystemExit(1)
