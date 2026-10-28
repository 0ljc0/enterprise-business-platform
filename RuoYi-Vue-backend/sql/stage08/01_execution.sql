ALTER TABLE biz_project ADD unit varchar(20) NOT NULL DEFAULT '' COMMENT '项目工作量单位';
ALTER TABLE biz_task_signup ADD execution_status varchar(20) NOT NULL DEFAULT 'NOT_STARTED';
ALTER TABLE biz_task_assignment ADD project_id bigint NULL,ADD FOREIGN KEY(company_id,project_id) REFERENCES biz_project(company_id,id);
ALTER TABLE biz_work_record ADD round_no int NOT NULL DEFAULT 1;
CREATE TABLE biz_project_task(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,company_id bigint NOT NULL,project_id bigint NOT NULL,signup_id bigint NOT NULL,task_id bigint NOT NULL,target_quantity decimal(18,2) NOT NULL,unit varchar(20) NOT NULL,UNIQUE KEY uk_signup_project(company_id,signup_id),KEY idx_project_links(company_id,project_id),FOREIGN KEY(company_id,project_id) REFERENCES biz_project(company_id,id),FOREIGN KEY(company_id,signup_id,task_id) REFERENCES biz_task_signup(company_id,id,task_id),CHECK(target_quantity>0));
CREATE TABLE biz_execution_event(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,company_id bigint NOT NULL,project_id bigint NOT NULL,assignment_id bigint NULL,record_id bigint NULL,action varchar(30) NOT NULL,before_value text NOT NULL,after_value text NOT NULL,opinion varchar(500) NOT NULL,actor_id bigint NOT NULL,create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,KEY idx_execution_project(company_id,project_id,id),KEY idx_execution_assignment(company_id,assignment_id,id),FOREIGN KEY(company_id,project_id) REFERENCES biz_project(company_id,id),FOREIGN KEY(assignment_id) REFERENCES biz_task_assignment(id),FOREIGN KEY(record_id) REFERENCES biz_work_record(id),FOREIGN KEY(actor_id) REFERENCES sys_user(user_id));
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(7000,'项目执行管理',6000,15,'execution-projects','business/execution/index','ExecutionProjects','C','0','0','biz:execution:read','tree'),
(7001,'我的任务与上报',6000,16,'execution-mine','business/execution/index','ExecutionMine','C','0','0','biz:execution:work','edit'),
(7002,'项目分配与核验',7000,1,'',NULL,'','F','0','0','biz:execution:manage','#');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,7000 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business','company_finance');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,7001 FROM sys_role WHERE role_key IN ('company_admin','company_hr','company_business','company_finance','employee');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,7002 FROM sys_role WHERE role_key IN ('company_admin','company_business');
