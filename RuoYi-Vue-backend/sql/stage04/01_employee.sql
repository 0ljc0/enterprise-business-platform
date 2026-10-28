ALTER TABLE biz_employee_apply ADD real_name varchar(50) NOT NULL DEFAULT '' COMMENT '姓名', ADD contact_phone varchar(30) NOT NULL DEFAULT '' COMMENT '电话', DROP INDEX uk_apply_active, ADD UNIQUE KEY uk_active_employee_applicant(active_user);
ALTER TABLE biz_employee_info ADD contact_phone varchar(30) NOT NULL DEFAULT '' COMMENT '员工电话';
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(6600,'员工入驻',6000,4,'employee-join','business/employees/index','EmployeeJoin','C','0','0','biz:employee:apply','user'),
(6601,'员工审核',6000,5,'employee-review','business/employees/index','EmployeeReview','C','0','0','biz:employee:review','validCode'),
(6602,'员工管理',6000,6,'employees','business/employees/index','EmployeeManage','C','0','0','biz:employee:manage','peoples'),
(6603,'我的员工资料',6000,7,'employee-profile','business/employees/index','EmployeeProfile','C','0','0','biz:employee:profile','user'),
(6604,'分配业务角色',6602,1,'',NULL,'','F','0','0','biz:employee:roles','#');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6600 FROM sys_role WHERE role_id BETWEEN 200 AND 205;
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6603 FROM sys_role WHERE role_id BETWEEN 200 AND 205;
INSERT INTO sys_role_menu(role_id,menu_id) VALUES(201,6601),(202,6601),(201,6602),(202,6602),(201,6604);
