ALTER TABLE biz_task ADD unit_price decimal(18,4) NULL COMMENT '每工作量单位报价，元；空表示未报价',ADD price_version int NOT NULL DEFAULT 0,ADD CHECK(unit_price IS NULL OR unit_price>=0);
ALTER TABLE biz_project_task ADD unit_price decimal(18,4) NULL COMMENT '项目报价快照，不自动覆盖',ADD price_version int NULL,ADD price_snapshot_time datetime NULL,ADD CHECK(unit_price IS NULL OR unit_price>=0);
CREATE TABLE biz_task_price_audit(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,task_id bigint NOT NULL,company_id bigint NULL,old_price decimal(18,4) NULL,new_price decimal(18,4) NULL,price_version int NOT NULL,opinion varchar(500) NOT NULL,actor_id bigint NOT NULL,create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(task_id) REFERENCES biz_task(id),FOREIGN KEY(company_id) REFERENCES biz_company(id),FOREIGN KEY(actor_id) REFERENCES sys_user(user_id),KEY idx_task_price(task_id,id));
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(7100,'统计工作台与报表',6000,17,'statistics','business/statistics/index','StatisticsReports','C','0','0','biz:statistics:read','chart'),
(7101,'Excel报表导出',7100,1,'',NULL,'','F','0','0','biz:statistics:export','#'),
(7102,'任务报价维护',7100,2,'',NULL,'','F','0','0','biz:statistics:price','#');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,7100 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business','company_finance','company_hr');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,7101 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business','company_finance','company_hr');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,7102 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business');
