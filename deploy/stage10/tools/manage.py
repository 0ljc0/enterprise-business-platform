"""Windows acceptance deployment. Python 3.10+, JDK17+, MySQL8 and Redis required.
Never imports into an existing database. Restore verification always creates a new one.
Runtime secrets stay in config/runtime.local.json, never in command line arguments.
"""
from pathlib import Path
import argparse,datetime,getpass,hashlib,json,os,re,secrets,shutil,socket,subprocess,sys,time,urllib.request,zipfile
ROOT=Path(__file__).resolve().parents[1]
CONFIG=ROOT/'config/runtime.local.json'
def execute(args,**kw):return subprocess.run([str(x) for x in args],check=True,**kw)
def protect(path):
    if os.name=='nt':
        who=subprocess.check_output(['whoami'],text=True).strip()
        execute(['icacls',path,'/inheritance:r','/grant:r',who+':(F)','SYSTEM:(F)','/T'],stdout=subprocess.DEVNULL)
def settings():return json.loads(CONFIG.read_text(encoding='utf-8'))
def sql(config,query,database=None,admin=False,capture=True):
    env=os.environ.copy();env['MYSQL_PWD']=os.environ.get('DEPLOY_MYSQL_ADMIN_PASSWORD') or getpass.getpass('MySQL administrator password: ') if admin else config['APP_DB_PASSWORD']
    user='root' if admin else config['APP_DB_USER']
    return execute([config['MYSQL_BIN'],'-h','127.0.0.1','-u',user,'--default-character-set=utf8mb4','-N']+([database] if database else []),input=query.encode(),env=env,stdout=subprocess.PIPE if capture else subprocess.DEVNULL).stdout
def dbname(config):return config['DATABASE']
def schema_fingerprint(config,db,admin=False):
    names=sql(config,'SHOW TABLES;',db,admin).decode().splitlines()
    return {t:int(sql(config,'SELECT COUNT(*) FROM `'+t+'`;',db,admin)) for t in names}
def table_checksums(config,db,admin=False):
    names=sql(config,'SHOW TABLES;',db,admin).decode().splitlines()
    return {t:sql(config,'CHECKSUM TABLE `'+t+'` EXTENDED;',db,admin).decode().strip().split('\t')[-1] for t in names}
def init(args):
    if CONFIG.exists():raise RuntimeError('Already configured. Existing configuration is never overwritten.')
    if not re.fullmatch(r'ry_platform_[a-zA-Z0-9_]{1,40}',args.database):raise ValueError('Use a new ry_platform_* database name')
    if not 0<=args.redis_db<=15 or not 1<=args.backend_port<=65535 or not 1<=args.http_port<=65535 or args.backend_port==args.http_port:raise ValueError('Invalid Redis database or service ports')
    if any(ord(c)>127 or c.isspace() for c in str(ROOT)):raise RuntimeError('Deploy into an ASCII path without spaces, for example D:/code/ruoyi-release10')
    config={'DATABASE':args.database,'MYSQL_BIN':str(Path(args.mysql_bin).resolve()),'APP_DB_USER':'bp_'+secrets.token_hex(6),'APP_DB_PASSWORD':secrets.token_urlsafe(32),'APP_TOKEN_SECRET':secrets.token_urlsafe(48),'APP_DB_URL':'jdbc:mysql://127.0.0.1:3306/'+args.database+'?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT%2B8','APP_REDIS_DB':str(args.redis_db),'APP_REDIS_HOST':'127.0.0.1','APP_REDIS_PORT':'6379','APP_REDIS_PASSWORD':os.environ.get('DEPLOY_REDIS_PASSWORD',''),'APP_PORT':str(args.backend_port),'HTTP_PORT':args.http_port,'APP_UPLOAD_PATH':str(ROOT/'uploads').replace('\\','/'),'LOG_PATH':str(ROOT/'logs').replace('\\','/')}
    # CREATE DATABASE fails rather than reusing or clearing a database.
    sql(config,'CREATE DATABASE `'+args.database+'` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;',admin=True)
    sql(config,(ROOT/'sql/init.sql').read_text(encoding='utf-8-sig'),args.database,admin=True)
    # RuoYi login validates a maximum of 20 characters before checking BCrypt.
    password=secrets.token_urlsafe(15);hashenv=os.environ.copy();hashenv['BOOTSTRAP_PASSWORD']=password
    encoded=subprocess.check_output(['java','-cp',str(ROOT/'tools/lib')+os.pathsep+str(ROOT/'tools/lib/*'),'PasswordHash'],env=hashenv,text=True).strip()
    sql(config,"UPDATE sys_user SET password='"+encoded+"',status='0',pwd_update_date=NOW() WHERE user_id=1; CREATE USER '"+config['APP_DB_USER']+"'@'127.0.0.1' IDENTIFIED BY '"+config['APP_DB_PASSWORD']+"'; GRANT SELECT,INSERT,UPDATE,DELETE ON `"+args.database+"`.* TO '"+config['APP_DB_USER']+"'@'127.0.0.1';",args.database,admin=True)
    for d in ['config','logs','uploads','backups','run']: (ROOT/d).mkdir(exist_ok=True)
    CONFIG.write_text(json.dumps(config,indent=2),encoding='utf-8');protect(CONFIG)
    credentials=ROOT/'config/initial-admin.local.txt';credentials.write_text('admin\n'+password+'\n',encoding='utf-8');protect(credentials)
    print('Initialized a fresh database with a restricted application user. Initial administrator: config/initial-admin.local.txt')
def occupied(port):
    with socket.socket() as sock:return sock.connect_ex(('127.0.0.1',int(port)))==0
def write_nginx(config):
    template=(ROOT/'config/nginx.conf.template').read_text()
    text=template.replace('__HTTP_PORT__',str(config['HTTP_PORT'])).replace('__BACKEND_PORT__',config['APP_PORT'])
    (ROOT/'nginx/conf/nginx.conf').write_text(text,encoding='ascii')
def start(args=None):
    config=settings()
    (ROOT/'nginx/temp').mkdir(exist_ok=True)
    for port in [config['APP_PORT'],config['HTTP_PORT']]:
        if occupied(port):raise RuntimeError('Port '+str(port)+' is occupied. No existing service was stopped.')
    write_nginx(config)
    execute([ROOT/'nginx/nginx.exe','-t','-p',str(ROOT/'nginx')+'/'],cwd=ROOT/'nginx')
    env=os.environ.copy();env.update({k:str(v) for k,v in config.items() if k.startswith('APP_') or k=='LOG_PATH'})
    with open(ROOT/'logs/backend-console.log','ab') as log:
        process=subprocess.Popen(['java','-jar',str(ROOT/'app.jar'),'--spring.profiles.active=druid,release'],cwd=ROOT,env=env,stdout=log,stderr=log,creationflags=subprocess.CREATE_NO_WINDOW)
    (ROOT/'run/backend.pid').write_text(str(process.pid))
    try:
        for retry in range(90):
            if process.poll() is not None:raise RuntimeError('Backend stopped; inspect logs/backend-console.log')
            try:urllib.request.urlopen('http://127.0.0.1:'+config['APP_PORT']+'/captchaImage',timeout=2).close();break
            except Exception:time.sleep(1)
        else:raise RuntimeError('Backend startup timed out')
        with open(ROOT/'logs/nginx-console.log','ab') as log:
            subprocess.Popen([str(ROOT/'nginx/nginx.exe'),'-p',str(ROOT/'nginx')+'/'],cwd=ROOT/'nginx',stdout=log,stderr=log,creationflags=subprocess.CREATE_NO_WINDOW)
        for retry in range(40):
            if occupied(config['HTTP_PORT']):break
            time.sleep(.25)
        else:raise RuntimeError('Nginx startup timed out')
    except Exception:
        process.terminate();raise
    print('Ready: http://127.0.0.1:'+str(config['HTTP_PORT']))
def stop(args=None):
    if (ROOT/'nginx/logs/nginx.pid').exists():execute([ROOT/'nginx/nginx.exe','-p',str(ROOT/'nginx')+'/','-s','quit'],cwd=ROOT/'nginx')
    pidfile=ROOT/'run/backend.pid'
    if pidfile.exists():
        execute(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',ROOT/'tools/stop-owned.ps1','-ProcessId',pidfile.read_text().strip(),'-RootPath',ROOT]);pidfile.unlink()
    config=settings()
    for retry in range(40):
        if not occupied(config['APP_PORT']) and not occupied(config['HTTP_PORT']):break
        time.sleep(.25)
def backup(args):
    config=settings();running=occupied(config['APP_PORT'])
    if running:stop()
    stamp=datetime.datetime.now().strftime('%Y%m%d%H%M%S');folder=ROOT/'backups'/stamp;folder.mkdir()
    try:
        env=os.environ.copy();env['MYSQL_PWD']=config['APP_DB_PASSWORD'];dump=Path(config['MYSQL_BIN']).with_name('mysqldump.exe')
        with open(folder/'database.sql','wb') as file:
            execute([dump,'-h','127.0.0.1','-u',config['APP_DB_USER'],'--single-transaction','--no-tablespaces','--skip-triggers','--set-gtid-purged=OFF','--hex-blob',dbname(config)],env=env,stdout=file)
        with zipfile.ZipFile(folder/'uploads.zip','w',zipfile.ZIP_DEFLATED) as archive:
            for file in (ROOT/'uploads').rglob('*'):
                if file.is_file():archive.write(file,file.relative_to(ROOT/'uploads'))
        manifest={'database':dbname(config),'counts':schema_fingerprint(config,dbname(config)),'tableChecksums':table_checksums(config,dbname(config)),'uploadHashes':{str(x.relative_to(ROOT/'uploads')).replace('\\','/'):hashlib.sha256(x.read_bytes()).hexdigest() for x in (ROOT/'uploads').rglob('*') if x.is_file()},'files':{x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in folder.iterdir() if x.is_file()}}
        (folder/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8');protect(folder)
        print('Backup:',folder)
    finally:
        if running:start()
def restore_check(args):
    config=settings();folder=Path(args.backup).resolve();manifest=json.loads((folder/'manifest.json').read_text())
    for name,digest in manifest['files'].items():
        if hashlib.sha256((folder/name).read_bytes()).hexdigest()!=digest:raise RuntimeError('Backup hash mismatch')
    database='ry_restorecheck_'+datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    sql(config,'CREATE DATABASE `'+database+'` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;',admin=True)
    sql(config,(folder/'database.sql').read_text(encoding='utf-8-sig'),database,admin=True)
    counts=schema_fingerprint(config,database,admin=True)
    if counts!=manifest['counts']:raise RuntimeError('Restored row count mismatch')
    if table_checksums(config,database,admin=True)!=manifest['tableChecksums']:raise RuntimeError('Restored table content checksum mismatch')
    restored=ROOT/'backups'/('restore-'+database);restored.mkdir()
    with zipfile.ZipFile(folder/'uploads.zip') as archive:
        for item in archive.infolist():
            target=(restored/item.filename).resolve()
            if not target.is_relative_to(restored.resolve()):raise RuntimeError('Unsafe archive path')
        archive.extractall(restored)
    for name,digest in manifest['uploadHashes'].items():
        if hashlib.sha256((restored/name).read_bytes()).hexdigest()!=digest:raise RuntimeError('Restored upload mismatch')
    (folder/'restore-verification.json').write_text(json.dumps({'restoredDatabase':database,'tableCount':len(counts),'rowCountsMatched':True,'tableChecksumsMatched':True,'uploadHashesMatched':True},indent=2),encoding='utf-8')
    print('Restore verified in NEW database:',database,'tables:',len(counts))
    return database
if __name__=='__main__':
    parser=argparse.ArgumentParser();sub=parser.add_subparsers(dest='action',required=True)
    p=sub.add_parser('init');p.add_argument('--database',required=True);p.add_argument('--mysql-bin',default='D:/mysql/bin/mysql.exe');p.add_argument('--redis-db',type=int,default=5);p.add_argument('--backend-port',type=int,default=18080);p.add_argument('--http-port',type=int,default=18081);p.set_defaults(func=init)
    for name,func in [('start',start),('stop',stop),('backup',backup)]:sub.add_parser(name).set_defaults(func=func)
    p=sub.add_parser('restore-check');p.add_argument('backup');p.set_defaults(func=restore_check)
    args=parser.parse_args()
    if args.action in ('init','restore-check') and not os.environ.get('DEPLOY_MYSQL_ADMIN_PASSWORD'):
        os.environ['DEPLOY_MYSQL_ADMIN_PASSWORD']=getpass.getpass('MySQL administrator password: ')
    args.func(args)
