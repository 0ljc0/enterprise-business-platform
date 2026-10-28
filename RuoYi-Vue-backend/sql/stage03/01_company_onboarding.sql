ALTER TABLE biz_audit_record MODIFY company_id bigint NULL COMMENT '审批前可无企业归属';
ALTER TABLE biz_company ADD introduction varchar(2000) NOT NULL DEFAULT '' COMMENT '企业简介';
ALTER TABLE biz_company_apply ADD contact_name varchar(50) NOT NULL DEFAULT '' COMMENT '负责人', ADD address varchar(255) NOT NULL DEFAULT '' COMMENT '地址', ADD introduction varchar(2000) NOT NULL DEFAULT '' COMMENT '简介', ADD UNIQUE KEY uk_application_credit(credit_code), ADD active_applicant bigint GENERATED ALWAYS AS(CASE WHEN status IN ('DRAFT','PENDING') THEN applicant_id ELSE NULL END) STORED, ADD UNIQUE KEY uk_active_applicant(active_applicant);
CREATE TABLE biz_company_license(id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY, owner_id bigint NOT NULL, content_type varchar(40) NOT NULL, file_data mediumblob NOT NULL, create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(owner_id) REFERENCES sys_user(user_id)) ENGINE=InnoDB COMMENT='私有营业执照附件，最大5MB';
INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,component,route_name,menu_type,visible,status,perms,icon) VALUES
(6500,'企业入驻',6000,1,'onboarding','business/onboarding/index','CompanyOnboarding','C','0','0','biz:onboarding:apply','edit'),
(6501,'入驻审核',6000,2,'company-review','business/onboarding/index','CompanyReview','C','0','0','biz:onboarding:review','validCode'),
(6502,'企业资料',6000,3,'company-profile','business/onboarding/index','CompanyProfile','C','0','0','biz:onboarding:manage','table');
INSERT INTO sys_role_menu(role_id,menu_id) SELECT role_id,6500 FROM sys_role WHERE role_id BETWEEN 200 AND 205;
INSERT INTO sys_role_menu(role_id,menu_id) VALUES(200,6501),(200,6502),(201,6502);
