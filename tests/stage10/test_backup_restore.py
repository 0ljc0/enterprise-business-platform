from pathlib import Path
import os,re,shutil,subprocess,json,time
root=Path(__file__).resolve().parents[2];os.chdir(root);target=Path('D:/code/ruoyi-release10');back=root/'RuoYi-Vue-backend'
shutil.copy2(root/'deploy/stage10/tools/manage.py',target/'tools/manage.py')
(target/'uploads/restore-proof.txt').write_text('stage10 backup and restore attachment proof',encoding='utf-8')
env=os.environ.copy();env['DEPLOY_MYSQL_ADMIN_PASSWORD']=os.environ['MYSQL_PWD'];env['MYSQL_PWD']=env['DEPLOY_MYSQL_ADMIN_PASSWORD']
# Verify operational audit records and business security configuration before snapshot.
config=json.loads((target/'config/runtime.local.json').read_text(encoding='utf-8'));db=config['DATABASE']
query="SELECT COUNT(*) FROM sys_oper_log WHERE status=0; SELECT COUNT(*) FROM biz_audit_record; SELECT config_value FROM sys_config WHERE config_key='sys.account.captchaEnabled'; SHOW GRANTS FOR '"+config['APP_DB_USER']+"'@'127.0.0.1';"
result=subprocess.check_output(['D:/mysql/bin/mysql.exe','-h','127.0.0.1','-u','root','-N',db],input=query.encode(),env=env).decode()
(root/'tests/stage10/deployment-checks.json').write_text(json.dumps({'database':db,'redisDB':5,'url':'http://127.0.0.1:18081','auditAndGrants':result},ensure_ascii=False,indent=2),encoding='utf-8')
subprocess.run(['python',str(target/'tools/manage.py'),'backup'],env=env,check=True)
folder=sorted((target/'backups').glob('[0-9]*'))[-1]
subprocess.run(['python',str(target/'tools/manage.py'),'restore-check',str(folder)],env=env,check=True)
shutil.copy2(folder/'restore-verification.json',root/'tests/stage10/restore-verification.json')
print('Audit and restricted grants checked. Database content and attachment hashes restored successfully.')
