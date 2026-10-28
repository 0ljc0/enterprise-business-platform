ALTER TABLE biz_company ADD reporting_start_date date NULL COMMENT '开始计报日期，空则按企业创建日';
UPDATE biz_company SET reporting_start_date=DATE(create_time);
CREATE TABLE biz_report_rule(id int NOT NULL PRIMARY KEY,cutoff_time time NOT NULL,remind_minutes int NOT NULL,threshold_days int NOT NULL,weekdays_only boolean NOT NULL,mode varchar(20) NOT NULL DEFAULT 'REMIND_ONLY',version int NOT NULL DEFAULT 0);
INSERT INTO biz_report_rule VALUES(1,'23:59:00',60,7,1,'REMIND_ONLY',0);
CREATE TABLE biz_report_calendar(business_date date NOT NULL PRIMARY KEY,required_day boolean NOT NULL,remark varchar(200) NOT NULL,update_by varchar(64) NOT NULL);
CREATE TABLE biz_report_compliance(company_id bigint NOT NULL PRIMARY KEY,missing_count int NOT NULL,consecutive_days int NOT NULL,report_state varchar(20) NOT NULL,last_checked datetime NOT NULL, FOREIGN KEY(company_id) REFERENCES biz_company(id));
CREATE TABLE biz_report_reminder(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,company_id bigint NOT NULL,business_date date NOT NULL,reminder_type varchar(20) NOT NULL,content varchar(500) NOT NULL,resolved boolean NOT NULL DEFAULT 0,create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,UNIQUE KEY uk_remind(company_id,business_date,reminder_type),FOREIGN KEY(company_id) REFERENCES biz_company(id));
CREATE TABLE biz_report_month(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,company_id bigint NOT NULL,report_month char(7) NOT NULL,status varchar(20) NOT NULL DEFAULT 'OPEN',version int NOT NULL DEFAULT 0,UNIQUE KEY uk_month(company_id,report_month),FOREIGN KEY(company_id) REFERENCES biz_company(id));
CREATE TABLE biz_report_month_audit(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,company_id bigint NOT NULL,report_month char(7) NOT NULL,action varchar(20) NOT NULL,record_count int NOT NULL,total_value decimal(24,2) NOT NULL,opinion varchar(500) NOT NULL,reviewer_id bigint NOT NULL,create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(company_id) REFERENCES biz_company(id),FOREIGN KEY(reviewer_id) REFERENCES sys_user(user_id),KEY idx_month_audit(company_id,report_month,id));
UPDATE sys_menu SET component='business/reporting/index' WHERE menu_id=6150;
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(6800,'填报规则与日历',6000,10,'report-rules','business/reporting/index','ReportRules','C','0','0','biz:report:config','date'),
(6810,'填报查询',6150,1,'',NULL,'','F','0','0','biz:report:read','#'),
(6811,'填报提交',6150,2,'',NULL,'','F','0','0','biz:report:write','#'),
(6812,'月度核对',6150,3,'',NULL,'','F','0','0','biz:report:review','#');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6810 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business','company_finance');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6811 FROM sys_role WHERE role_key IN ('platform_admin','company_admin','company_business');
INSERT INTO sys_role_menu(role_id,menu_id) VALUES(200,6800),(200,6812);
