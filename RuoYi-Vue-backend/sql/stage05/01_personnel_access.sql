CREATE TABLE biz_personnel_change (
 id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY, company_id bigint NOT NULL, record_type varchar(20) NOT NULL, record_id bigint NOT NULL, action varchar(20) NOT NULL, before_value text NOT NULL, after_value text NOT NULL, reason varchar(500) NOT NULL, operator_id bigint NOT NULL, create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY idx_change_scope(company_id,record_type,record_id,id),FOREIGN KEY(company_id) REFERENCES biz_company(id), FOREIGN KEY(operator_id) REFERENCES sys_user(user_id)
) ENGINE=InnoDB COMMENT='人员和平台内门禁变更轨迹';
ALTER TABLE biz_access_permission MODIFY sync_status varchar(20) NOT NULL DEFAULT 'NOT_CONNECTED' COMMENT '未接入真实设备';
UPDATE biz_access_permission SET sync_status='NOT_CONNECTED';
INSERT INTO sys_role(role_id,role_name,role_key,role_sort,data_scope,status,del_flag) VALUES(206,'入驻申请人','company_applicant',206,'5','0','0');
INSERT INTO sys_role_menu(role_id,menu_id) VALUES(206,6000),(206,6500),(206,6600),(206,6603);
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(6700,'人员档案与统计',6000,8,'personnel','business/personnel/index','PersonnelManagement','C','0','0','biz:personnel:list','peoples'),
(6710,'门禁授权记录',6000,9,'access-records','business/personnel/index','AccessRecords','C','0','0','biz:access:list','lock'),
(6701,'维护人员档案',6700,1,'',NULL,'','F','0','0','biz:personnel:edit','#'),
(6702,'导出人员',6700,2,'',NULL,'','F','0','0','biz:personnel:export','#'),
(6703,'离职处理',6700,3,'',NULL,'','F','0','0','biz:personnel:leave','#'),
(6711,'维护授权记录',6710,1,'',NULL,'','F','0','0','biz:access:edit','#');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT r.role_id,m.menu_id FROM sys_role r JOIN sys_menu m ON m.menu_id IN (6700,6701,6702,6703,6710,6711) WHERE r.role_key IN ('company_admin','company_hr');
