ALTER TABLE biz_task ADD audience varchar(20) NOT NULL DEFAULT 'INTERNAL' COMMENT '历史任务默认企业内部；新共享任务为SHARED',ADD max_companies int NOT NULL DEFAULT 1 COMMENT '审核通过企业数上限',ADD publisher_id bigint NULL COMMENT '发布账号',ADD close_reason varchar(500) NOT NULL DEFAULT '',ADD FOREIGN KEY(publisher_id) REFERENCES sys_user(user_id),ADD CHECK(max_companies>0),ADD CHECK(audience IN ('SHARED','INTERNAL'));
CREATE TABLE biz_task_event(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,task_id bigint NOT NULL,signup_id bigint NULL,company_id bigint NULL,action varchar(30) NOT NULL,actor_id bigint NOT NULL,opinion varchar(500) NOT NULL,create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(task_id) REFERENCES biz_task(id),FOREIGN KEY(signup_id) REFERENCES biz_task_signup(id),FOREIGN KEY(company_id) REFERENCES biz_company(id),FOREIGN KEY(actor_id) REFERENCES sys_user(user_id),KEY idx_task_event(task_id,id),KEY idx_signup_event(signup_id,id));
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(6900,'任务发布管理',6000,11,'task-manage','business/tasks/index','TaskManage','C','0','0','biz:tasks:manage','edit'),
(6901,'可报名任务',6000,12,'task-market','business/tasks/index','TaskMarket','C','0','0','biz:tasks:read','list'),
(6902,'企业报名记录',6000,13,'task-signups','business/tasks/index','TaskSignups','C','0','0','biz:tasks:signup','form'),
(6903,'平台报名审核',6000,14,'task-reviews','business/tasks/index','TaskReviews','C','0','0','biz:tasks:review','validCode');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6900 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6901 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6902 FROM sys_role WHERE role_key IN ('company_admin','company_business');
INSERT INTO sys_role_menu(role_id,menu_id) VALUES(200,6903);
