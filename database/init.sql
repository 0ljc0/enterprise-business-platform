-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: ry_platform_cleaninit_20261026165815
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `biz_access_permission`
--

DROP TABLE IF EXISTS `biz_access_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_access_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `user_id` bigint NOT NULL COMMENT '账号',
  `device_code` varchar(80) NOT NULL COMMENT '设备编号',
  `valid_from` datetime DEFAULT NULL COMMENT '有效期开始',
  `valid_to` datetime DEFAULT NULL COMMENT '有效期结束',
  `sync_status` varchar(20) NOT NULL DEFAULT 'NOT_CONNECTED' COMMENT '未接入真实设备',
  `last_error` varchar(500) DEFAULT NULL COMMENT '最后同步错误',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_device` (`company_id`,`user_id`,`device_code`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  CONSTRAINT `biz_access_permission_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_access_permission_ibfk_2` FOREIGN KEY (`company_id`, `user_id`) REFERENCES `biz_employee_info` (`company_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门禁授权';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_access_permission`
--

LOCK TABLES `biz_access_permission` WRITE;
/*!40000 ALTER TABLE `biz_access_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_access_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_audit_record`
--

DROP TABLE IF EXISTS `biz_audit_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_audit_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint DEFAULT NULL COMMENT '审批前可无企业归属',
  `business_type` varchar(40) NOT NULL COMMENT '业务类型',
  `business_id` bigint NOT NULL COMMENT '业务ID，按business_type逻辑关联',
  `round_no` int NOT NULL COMMENT '审批轮次',
  `applicant_id` bigint NOT NULL COMMENT '申请人',
  `reviewer_id` bigint NOT NULL COMMENT '审核人',
  `from_status` varchar(20) NOT NULL COMMENT '原状态',
  `to_status` varchar(20) NOT NULL COMMENT '新状态',
  `opinion` varchar(500) NOT NULL COMMENT '审核意见',
  `reviewed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审核时间',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_audit_round` (`business_type`,`business_id`,`round_no`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `applicant_id` (`applicant_id`),
  KEY `reviewer_id` (`reviewer_id`),
  CONSTRAINT `biz_audit_record_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_audit_record_ibfk_2` FOREIGN KEY (`applicant_id`) REFERENCES `sys_user` (`user_id`),
  CONSTRAINT `biz_audit_record_ibfk_3` FOREIGN KEY (`reviewer_id`) REFERENCES `sys_user` (`user_id`),
  CONSTRAINT `biz_audit_record_chk_1` CHECK ((`applicant_id` <> `reviewer_id`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审批轨迹';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_audit_record`
--

LOCK TABLES `biz_audit_record` WRITE;
/*!40000 ALTER TABLE `biz_audit_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_audit_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_company`
--

DROP TABLE IF EXISTS `biz_company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_company` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_name` varchar(100) NOT NULL COMMENT '企业名称',
  `credit_code` char(18) NOT NULL COMMENT '统一社会信用代码',
  `contact_name` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(30) DEFAULT NULL COMMENT '电话',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `introduction` varchar(2000) NOT NULL DEFAULT '' COMMENT '企业简介',
  `reporting_start_date` date DEFAULT NULL COMMENT '开始计报日期，空则按企业创建日',
  PRIMARY KEY (`id`),
  UNIQUE KEY `credit_code` (`credit_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='企业';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_company`
--

LOCK TABLES `biz_company` WRITE;
/*!40000 ALTER TABLE `biz_company` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_company` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_company_apply`
--

DROP TABLE IF EXISTS `biz_company_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_company_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint DEFAULT NULL COMMENT '企业归属，服务端控制',
  `applicant_id` bigint NOT NULL COMMENT '申请账号',
  `company_name` varchar(100) NOT NULL COMMENT '申请企业名称',
  `credit_code` char(18) NOT NULL COMMENT '信用代码',
  `contact_phone` varchar(30) DEFAULT NULL COMMENT '联系电话',
  `qualification_ref` varchar(255) DEFAULT NULL COMMENT '资质附件引用',
  `round_no` int NOT NULL DEFAULT '1' COMMENT '审批轮次',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `contact_name` varchar(50) NOT NULL DEFAULT '' COMMENT '负责人',
  `address` varchar(255) NOT NULL DEFAULT '' COMMENT '地址',
  `introduction` varchar(2000) NOT NULL DEFAULT '' COMMENT '简介',
  `active_applicant` bigint GENERATED ALWAYS AS ((case when (`status` in (_utf8mb4'DRAFT',_utf8mb4'PENDING')) then `applicant_id` else NULL end)) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_application_credit` (`credit_code`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_active_applicant` (`active_applicant`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `applicant_id` (`applicant_id`),
  CONSTRAINT `biz_company_apply_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_company_apply_ibfk_2` FOREIGN KEY (`applicant_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='企业申请';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_company_apply`
--

LOCK TABLES `biz_company_apply` WRITE;
/*!40000 ALTER TABLE `biz_company_apply` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_company_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_company_license`
--

DROP TABLE IF EXISTS `biz_company_license`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_company_license` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `owner_id` bigint NOT NULL,
  `content_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_data` mediumblob NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `biz_company_license_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='私有营业执照附件，最大5MB';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_company_license`
--

LOCK TABLES `biz_company_license` WRITE;
/*!40000 ALTER TABLE `biz_company_license` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_company_license` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_company_user`
--

DROP TABLE IF EXISTS `biz_company_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_company_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业',
  `user_id` bigint NOT NULL COMMENT '若依账号',
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/LEFT',
  `active_user` bigint GENERATED ALWAYS AS ((case when (`status` = _utf8mb4'ACTIVE') then `user_id` else NULL end)) STORED,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_membership` (`company_id`,`user_id`),
  UNIQUE KEY `uk_active_user` (`active_user`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `biz_company_user_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_company_user_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='企业归属关系；同账号仅一有效企业';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_company_user`
--

LOCK TABLES `biz_company_user` WRITE;
/*!40000 ALTER TABLE `biz_company_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_company_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_daily_output`
--

DROP TABLE IF EXISTS `biz_daily_output`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_daily_output` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `output_date` date NOT NULL COMMENT '业务日期',
  `output_value` decimal(18,2) NOT NULL COMMENT '每日产值，不小于0',
  `unit` varchar(20) NOT NULL DEFAULT '元' COMMENT '计量单位',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_output_day` (`company_id`,`output_date`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  CONSTRAINT `biz_daily_output_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_daily_output_chk_1` CHECK ((`output_value` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='业务填报';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_daily_output`
--

LOCK TABLES `biz_daily_output` WRITE;
/*!40000 ALTER TABLE `biz_daily_output` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_daily_output` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_employee_apply`
--

DROP TABLE IF EXISTS `biz_employee_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_employee_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `user_id` bigint NOT NULL COMMENT '申请账号',
  `job_title` varchar(80) DEFAULT NULL COMMENT '申请岗位',
  `round_no` int NOT NULL DEFAULT '1' COMMENT '审批轮次',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `active_user` bigint GENERATED ALWAYS AS ((case when (`status` in (_utf8mb4'DRAFT',_utf8mb4'PENDING')) then `user_id` else NULL end)) STORED,
  `real_name` varchar(50) NOT NULL DEFAULT '' COMMENT '姓名',
  `contact_phone` varchar(30) NOT NULL DEFAULT '' COMMENT '电话',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_active_employee_applicant` (`active_user`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `biz_employee_apply_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_employee_apply_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='员工申请';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_employee_apply`
--

LOCK TABLES `biz_employee_apply` WRITE;
/*!40000 ALTER TABLE `biz_employee_apply` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_employee_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_employee_info`
--

DROP TABLE IF EXISTS `biz_employee_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_employee_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `user_id` bigint NOT NULL COMMENT '关联若依账号',
  `employee_no` varchar(40) NOT NULL COMMENT '企业内工号',
  `real_name` varchar(50) NOT NULL COMMENT '姓名',
  `job_title` varchar(80) DEFAULT NULL COMMENT '岗位',
  `entry_date` date DEFAULT NULL COMMENT '入职日期',
  `leave_date` date DEFAULT NULL COMMENT '离职日期',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `contact_phone` varchar(30) NOT NULL DEFAULT '' COMMENT '员工电话',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_employee_no` (`company_id`,`employee_no`),
  UNIQUE KEY `uk_employee_user` (`company_id`,`user_id`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `biz_employee_info_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_employee_info_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='员工档案';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_employee_info`
--

LOCK TABLES `biz_employee_info` WRITE;
/*!40000 ALTER TABLE `biz_employee_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_employee_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_execution_event`
--

DROP TABLE IF EXISTS `biz_execution_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_execution_event` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `assignment_id` bigint DEFAULT NULL,
  `record_id` bigint DEFAULT NULL,
  `action` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `before_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `after_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `opinion` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` bigint NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_execution_project` (`company_id`,`project_id`,`id`),
  KEY `idx_execution_assignment` (`company_id`,`assignment_id`,`id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `record_id` (`record_id`),
  KEY `actor_id` (`actor_id`),
  CONSTRAINT `biz_execution_event_ibfk_1` FOREIGN KEY (`company_id`, `project_id`) REFERENCES `biz_project` (`company_id`, `id`),
  CONSTRAINT `biz_execution_event_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `biz_task_assignment` (`id`),
  CONSTRAINT `biz_execution_event_ibfk_3` FOREIGN KEY (`record_id`) REFERENCES `biz_work_record` (`id`),
  CONSTRAINT `biz_execution_event_ibfk_4` FOREIGN KEY (`actor_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_execution_event`
--

LOCK TABLES `biz_execution_event` WRITE;
/*!40000 ALTER TABLE `biz_execution_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_execution_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_personnel_change`
--

DROP TABLE IF EXISTS `biz_personnel_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_personnel_change` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `record_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_id` bigint NOT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `before_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `after_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `operator_id` bigint NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_change_scope` (`company_id`,`record_type`,`record_id`,`id`),
  KEY `operator_id` (`operator_id`),
  CONSTRAINT `biz_personnel_change_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_personnel_change_ibfk_2` FOREIGN KEY (`operator_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='人员和平台内门禁变更轨迹';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_personnel_change`
--

LOCK TABLES `biz_personnel_change` WRITE;
/*!40000 ALTER TABLE `biz_personnel_change` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_personnel_change` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_project`
--

DROP TABLE IF EXISTS `biz_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `project_code` varchar(50) NOT NULL COMMENT '企业内项目编号',
  `project_name` varchar(100) NOT NULL COMMENT '项目名称',
  `owner_user_id` bigint DEFAULT NULL COMMENT '负责人账号',
  `start_date` date DEFAULT NULL COMMENT '开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `unit` varchar(20) NOT NULL DEFAULT '' COMMENT '项目工作量单位',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_project_code` (`company_id`,`project_code`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `company_id` (`company_id`,`owner_user_id`),
  CONSTRAINT `biz_project_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_project_ibfk_2` FOREIGN KEY (`company_id`, `owner_user_id`) REFERENCES `biz_employee_info` (`company_id`, `user_id`),
  CONSTRAINT `biz_project_chk_1` CHECK (((`end_date` is null) or (`start_date` is null) or (`end_date` >= `start_date`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='项目';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_project`
--

LOCK TABLES `biz_project` WRITE;
/*!40000 ALTER TABLE `biz_project` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_project_task`
--

DROP TABLE IF EXISTS `biz_project_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_project_task` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `signup_id` bigint NOT NULL,
  `task_id` bigint NOT NULL,
  `target_quantity` decimal(18,2) NOT NULL,
  `unit` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit_price` decimal(18,4) DEFAULT NULL COMMENT '项目报价快照，不自动覆盖',
  `price_version` int DEFAULT NULL,
  `price_snapshot_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_signup_project` (`company_id`,`signup_id`),
  KEY `idx_project_links` (`company_id`,`project_id`),
  KEY `company_id` (`company_id`,`signup_id`,`task_id`),
  CONSTRAINT `biz_project_task_ibfk_1` FOREIGN KEY (`company_id`, `project_id`) REFERENCES `biz_project` (`company_id`, `id`),
  CONSTRAINT `biz_project_task_ibfk_2` FOREIGN KEY (`company_id`, `signup_id`, `task_id`) REFERENCES `biz_task_signup` (`company_id`, `id`, `task_id`),
  CONSTRAINT `biz_project_task_chk_1` CHECK ((`target_quantity` > 0)),
  CONSTRAINT `biz_project_task_chk_2` CHECK (((`unit_price` is null) or (`unit_price` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_project_task`
--

LOCK TABLES `biz_project_task` WRITE;
/*!40000 ALTER TABLE `biz_project_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_project_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_report_calendar`
--

DROP TABLE IF EXISTS `biz_report_calendar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_report_calendar` (
  `business_date` date NOT NULL,
  `required_day` tinyint(1) NOT NULL,
  `remark` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`business_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_report_calendar`
--

LOCK TABLES `biz_report_calendar` WRITE;
/*!40000 ALTER TABLE `biz_report_calendar` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_report_calendar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_report_compliance`
--

DROP TABLE IF EXISTS `biz_report_compliance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_report_compliance` (
  `company_id` bigint NOT NULL,
  `missing_count` int NOT NULL,
  `consecutive_days` int NOT NULL,
  `report_state` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_checked` datetime NOT NULL,
  PRIMARY KEY (`company_id`),
  CONSTRAINT `biz_report_compliance_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_report_compliance`
--

LOCK TABLES `biz_report_compliance` WRITE;
/*!40000 ALTER TABLE `biz_report_compliance` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_report_compliance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_report_month`
--

DROP TABLE IF EXISTS `biz_report_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_report_month` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `report_month` char(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_month` (`company_id`,`report_month`),
  CONSTRAINT `biz_report_month_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_report_month`
--

LOCK TABLES `biz_report_month` WRITE;
/*!40000 ALTER TABLE `biz_report_month` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_report_month` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_report_month_audit`
--

DROP TABLE IF EXISTS `biz_report_month_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_report_month_audit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `report_month` char(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_count` int NOT NULL,
  `total_value` decimal(24,2) NOT NULL,
  `opinion` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reviewer_id` bigint NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `reviewer_id` (`reviewer_id`),
  KEY `idx_month_audit` (`company_id`,`report_month`,`id`),
  CONSTRAINT `biz_report_month_audit_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_report_month_audit_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_report_month_audit`
--

LOCK TABLES `biz_report_month_audit` WRITE;
/*!40000 ALTER TABLE `biz_report_month_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_report_month_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_report_reminder`
--

DROP TABLE IF EXISTS `biz_report_reminder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_report_reminder` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `business_date` date NOT NULL,
  `reminder_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolved` tinyint(1) NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_remind` (`company_id`,`business_date`,`reminder_type`),
  CONSTRAINT `biz_report_reminder_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_report_reminder`
--

LOCK TABLES `biz_report_reminder` WRITE;
/*!40000 ALTER TABLE `biz_report_reminder` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_report_reminder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_report_rule`
--

DROP TABLE IF EXISTS `biz_report_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_report_rule` (
  `id` int NOT NULL,
  `cutoff_time` time NOT NULL,
  `remind_minutes` int NOT NULL,
  `threshold_days` int NOT NULL,
  `weekdays_only` tinyint(1) NOT NULL,
  `mode` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REMIND_ONLY',
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_report_rule`
--

LOCK TABLES `biz_report_rule` WRITE;
/*!40000 ALTER TABLE `biz_report_rule` DISABLE KEYS */;
INSERT INTO `biz_report_rule` VALUES (1,'23:59:00',60,7,1,'REMIND_ONLY',0);
/*!40000 ALTER TABLE `biz_report_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_task`
--

DROP TABLE IF EXISTS `biz_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_task` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint DEFAULT NULL COMMENT '企业归属，服务端控制',
  `task_code` varchar(50) NOT NULL COMMENT '全局任务编号',
  `title` varchar(150) NOT NULL COMMENT '任务标题',
  `publisher_type` varchar(20) NOT NULL DEFAULT 'COMPANY' COMMENT 'PLATFORM/COMPANY',
  `description` text COMMENT '任务说明',
  `project_id` bigint DEFAULT NULL COMMENT '所属项目',
  `target_quantity` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '目标工作量',
  `unit` varchar(20) NOT NULL DEFAULT '件' COMMENT '工作量单位',
  `signup_deadline` datetime DEFAULT NULL COMMENT '报名截止时间',
  `start_date` date DEFAULT NULL COMMENT '开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `audience` varchar(20) NOT NULL DEFAULT 'INTERNAL' COMMENT '历史任务默认企业内部；新共享任务为SHARED',
  `max_companies` int NOT NULL DEFAULT '1' COMMENT '审核通过企业数上限',
  `publisher_id` bigint DEFAULT NULL COMMENT '发布账号',
  `close_reason` varchar(500) NOT NULL DEFAULT '',
  `unit_price` decimal(18,4) DEFAULT NULL COMMENT '每工作量单位报价，元；空表示未报价',
  `price_version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_code` (`task_code`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `company_id` (`company_id`,`project_id`),
  KEY `publisher_id` (`publisher_id`),
  CONSTRAINT `biz_task_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_task_ibfk_2` FOREIGN KEY (`company_id`, `project_id`) REFERENCES `biz_project` (`company_id`, `id`),
  CONSTRAINT `biz_task_ibfk_3` FOREIGN KEY (`publisher_id`) REFERENCES `sys_user` (`user_id`),
  CONSTRAINT `biz_task_chk_1` CHECK ((`publisher_type` in (_utf8mb4'PLATFORM',_utf8mb4'COMPANY'))),
  CONSTRAINT `biz_task_chk_2` CHECK ((((`publisher_type` = _utf8mb4'PLATFORM') and (`company_id` is null)) or ((`publisher_type` = _utf8mb4'COMPANY') and (`company_id` is not null)))),
  CONSTRAINT `biz_task_chk_3` CHECK ((`target_quantity` >= 0)),
  CONSTRAINT `biz_task_chk_4` CHECK ((`max_companies` > 0)),
  CONSTRAINT `biz_task_chk_5` CHECK ((`audience` in (_utf8mb4'SHARED',_utf8mb4'INTERNAL'))),
  CONSTRAINT `biz_task_chk_6` CHECK (((`unit_price` is null) or (`unit_price` >= 0))),
  CONSTRAINT `ck_company_internal_only` CHECK (((`publisher_type` <> _utf8mb4'COMPANY') or ((`audience` = _utf8mb4'INTERNAL') and (`max_companies` = 1))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_task`
--

LOCK TABLES `biz_task` WRITE;
/*!40000 ALTER TABLE `biz_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_task_assignment`
--

DROP TABLE IF EXISTS `biz_task_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_task_assignment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `task_id` bigint NOT NULL COMMENT '任务',
  `signup_id` bigint NOT NULL COMMENT '审核通过的报名记录',
  `user_id` bigint NOT NULL COMMENT '员工账号',
  `assigned_quantity` decimal(18,2) NOT NULL COMMENT '分配工作量',
  `due_date` date DEFAULT NULL COMMENT '截止日期',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `project_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_assign_user` (`task_id`,`company_id`,`user_id`),
  UNIQUE KEY `uk_assign_record` (`company_id`,`id`,`user_id`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `company_id` (`company_id`,`signup_id`,`task_id`),
  KEY `company_id_2` (`company_id`,`user_id`),
  KEY `company_id_3` (`company_id`,`project_id`),
  CONSTRAINT `biz_task_assignment_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_task_assignment_ibfk_2` FOREIGN KEY (`company_id`, `signup_id`, `task_id`) REFERENCES `biz_task_signup` (`company_id`, `id`, `task_id`),
  CONSTRAINT `biz_task_assignment_ibfk_3` FOREIGN KEY (`company_id`, `user_id`) REFERENCES `biz_employee_info` (`company_id`, `user_id`),
  CONSTRAINT `biz_task_assignment_ibfk_4` FOREIGN KEY (`company_id`, `project_id`) REFERENCES `biz_project` (`company_id`, `id`),
  CONSTRAINT `biz_task_assignment_chk_1` CHECK ((`assigned_quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务分配';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_task_assignment`
--

LOCK TABLES `biz_task_assignment` WRITE;
/*!40000 ALTER TABLE `biz_task_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_task_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_task_event`
--

DROP TABLE IF EXISTS `biz_task_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_task_event` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `signup_id` bigint DEFAULT NULL,
  `company_id` bigint DEFAULT NULL,
  `action` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` bigint NOT NULL,
  `opinion` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `actor_id` (`actor_id`),
  KEY `idx_task_event` (`task_id`,`id`),
  KEY `idx_signup_event` (`signup_id`,`id`),
  CONSTRAINT `biz_task_event_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `biz_task` (`id`),
  CONSTRAINT `biz_task_event_ibfk_2` FOREIGN KEY (`signup_id`) REFERENCES `biz_task_signup` (`id`),
  CONSTRAINT `biz_task_event_ibfk_3` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_task_event_ibfk_4` FOREIGN KEY (`actor_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_task_event`
--

LOCK TABLES `biz_task_event` WRITE;
/*!40000 ALTER TABLE `biz_task_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_task_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_task_price_audit`
--

DROP TABLE IF EXISTS `biz_task_price_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_task_price_audit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `old_price` decimal(18,4) DEFAULT NULL,
  `new_price` decimal(18,4) DEFAULT NULL,
  `price_version` int NOT NULL,
  `opinion` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` bigint NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `actor_id` (`actor_id`),
  KEY `idx_task_price` (`task_id`,`id`),
  CONSTRAINT `biz_task_price_audit_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `biz_task` (`id`),
  CONSTRAINT `biz_task_price_audit_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_task_price_audit_ibfk_3` FOREIGN KEY (`actor_id`) REFERENCES `sys_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_task_price_audit`
--

LOCK TABLES `biz_task_price_audit` WRITE;
/*!40000 ALTER TABLE `biz_task_price_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_task_price_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_task_signup`
--

DROP TABLE IF EXISTS `biz_task_signup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_task_signup` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `task_id` bigint NOT NULL COMMENT '报名任务',
  `contact_user_id` bigint NOT NULL COMMENT '报名联系人',
  `promised_quantity` decimal(18,2) NOT NULL COMMENT '承诺数量',
  `round_no` int NOT NULL DEFAULT '1' COMMENT '审批轮次',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `execution_status` varchar(20) NOT NULL DEFAULT 'NOT_STARTED',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_signup` (`task_id`,`company_id`),
  UNIQUE KEY `uk_signup_task` (`company_id`,`id`,`task_id`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `company_id` (`company_id`,`contact_user_id`),
  CONSTRAINT `biz_task_signup_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_task_signup_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `biz_task` (`id`),
  CONSTRAINT `biz_task_signup_ibfk_3` FOREIGN KEY (`company_id`, `contact_user_id`) REFERENCES `biz_employee_info` (`company_id`, `user_id`),
  CONSTRAINT `biz_task_signup_chk_1` CHECK ((`promised_quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务报名';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_task_signup`
--

LOCK TABLES `biz_task_signup` WRITE;
/*!40000 ALTER TABLE `biz_task_signup` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_task_signup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_work_record`
--

DROP TABLE IF EXISTS `biz_work_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_work_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '企业归属，服务端控制',
  `assignment_id` bigint NOT NULL COMMENT '分配记录',
  `user_id` bigint NOT NULL COMMENT '员工账号',
  `work_date` date NOT NULL COMMENT '工作日期',
  `quantity` decimal(18,2) NOT NULL COMMENT '上报工作量',
  `evidence_ref` varchar(255) DEFAULT NULL COMMENT '工作凭证引用',
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `version` int NOT NULL DEFAULT '0' COMMENT '乐观锁版本',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
  `round_no` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_id` (`company_id`,`id`),
  UNIQUE KEY `uk_work_day` (`assignment_id`,`user_id`,`work_date`),
  KEY `idx_scope_status` (`company_id`,`status`,`id`),
  KEY `company_id` (`company_id`,`assignment_id`,`user_id`),
  CONSTRAINT `biz_work_record_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `biz_company` (`id`),
  CONSTRAINT `biz_work_record_ibfk_2` FOREIGN KEY (`company_id`, `assignment_id`, `user_id`) REFERENCES `biz_task_assignment` (`company_id`, `id`, `user_id`),
  CONSTRAINT `biz_work_record_chk_1` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='工作记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_work_record`
--

LOCK TABLES `biz_work_record` WRITE;
/*!40000 ALTER TABLE `biz_work_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_work_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成功能作者',
  `form_col_num` int DEFAULT '1' COMMENT '表单布局（单列 双列 三列）',
  `gen_type` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代码生成业务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '字典类型',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代码生成业务表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

LOCK TABLES `gen_table_column` WRITE;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_blob_triggers`
--

DROP TABLE IF EXISTS `qrtz_blob_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_blob_triggers` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Blob类型的触发器表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_blob_triggers`
--

LOCK TABLES `qrtz_blob_triggers` WRITE;
/*!40000 ALTER TABLE `qrtz_blob_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_blob_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_calendars`
--

DROP TABLE IF EXISTS `qrtz_calendars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_calendars` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`,`calendar_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='日历信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_calendars`
--

LOCK TABLES `qrtz_calendars` WRITE;
/*!40000 ALTER TABLE `qrtz_calendars` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_calendars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_cron_triggers`
--

DROP TABLE IF EXISTS `qrtz_cron_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_cron_triggers` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cron类型的触发器表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_cron_triggers`
--

LOCK TABLES `qrtz_cron_triggers` WRITE;
/*!40000 ALTER TABLE `qrtz_cron_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_cron_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_fired_triggers`
--

DROP TABLE IF EXISTS `qrtz_fired_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_fired_triggers` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`,`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='已触发的触发器表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_fired_triggers`
--

LOCK TABLES `qrtz_fired_triggers` WRITE;
/*!40000 ALTER TABLE `qrtz_fired_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_fired_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_job_details`
--

DROP TABLE IF EXISTS `qrtz_job_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_job_details` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`,`job_name`,`job_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务详细信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_job_details`
--

LOCK TABLES `qrtz_job_details` WRITE;
/*!40000 ALTER TABLE `qrtz_job_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_job_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_locks`
--

DROP TABLE IF EXISTS `qrtz_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_locks` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`,`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='存储的悲观锁信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_locks`
--

LOCK TABLES `qrtz_locks` WRITE;
/*!40000 ALTER TABLE `qrtz_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_paused_trigger_grps`
--

DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_paused_trigger_grps` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`,`trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='暂停的触发器表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_paused_trigger_grps`
--

LOCK TABLES `qrtz_paused_trigger_grps` WRITE;
/*!40000 ALTER TABLE `qrtz_paused_trigger_grps` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_paused_trigger_grps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_scheduler_state`
--

DROP TABLE IF EXISTS `qrtz_scheduler_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_scheduler_state` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`,`instance_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='调度器状态表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_scheduler_state`
--

LOCK TABLES `qrtz_scheduler_state` WRITE;
/*!40000 ALTER TABLE `qrtz_scheduler_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_scheduler_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_simple_triggers`
--

DROP TABLE IF EXISTS `qrtz_simple_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_simple_triggers` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='简单触发器的信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_simple_triggers`
--

LOCK TABLES `qrtz_simple_triggers` WRITE;
/*!40000 ALTER TABLE `qrtz_simple_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_simple_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_simprop_triggers`
--

DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_simprop_triggers` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13,4) DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13,4) DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='同步机制的行锁表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_simprop_triggers`
--

LOCK TABLES `qrtz_simprop_triggers` WRITE;
/*!40000 ALTER TABLE `qrtz_simprop_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_simprop_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrtz_triggers`
--

DROP TABLE IF EXISTS `qrtz_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrtz_triggers` (
  `sched_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  KEY `sched_name` (`sched_name`,`job_name`,`job_group`),
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='触发器详细信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrtz_triggers`
--

LOCK TABLES `qrtz_triggers` WRITE;
/*!40000 ALTER TABLE `qrtz_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) COLLATE utf8mb4_unicode_ci DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='参数配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES (1,'主框架页-默认皮肤样式名称','sys.index.skinName','skin-blue','Y','admin','2026-10-26 16:58:18','',NULL,'蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),(2,'用户管理-账号初始密码','sys.user.initPassword','123456','Y','admin','2026-10-26 16:58:18','',NULL,'初始化密码 123456'),(3,'主框架页-侧边栏主题','sys.index.sideTheme','theme-dark','Y','admin','2026-10-26 16:58:18','',NULL,'深色主题theme-dark，浅色主题theme-light'),(4,'账号自助-验证码开关','sys.account.captchaEnabled','true','Y','admin','2026-10-26 16:58:18','',NULL,'是否开启验证码功能（true开启，false关闭）'),(5,'账号自助-是否开启用户注册功能','sys.account.registerUser','false','Y','admin','2026-10-26 16:58:18','',NULL,'是否开启注册用户功能（true开启，false关闭）'),(6,'用户登录-黑名单列表','sys.login.blackIPList','','Y','admin','2026-10-26 16:58:18','',NULL,'设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）'),(7,'用户管理-初始密码修改策略','sys.account.initPasswordModify','1','Y','admin','2026-10-26 16:58:18','',NULL,'0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框'),(8,'用户管理-账号密码更新周期','sys.account.passwordValidateDays','0','Y','admin','2026-10-26 16:58:18','',NULL,'密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框'),(9,'用户管理-密码字符范围','sys.account.chrtype','0','Y','admin','2026-10-26 16:58:18','',NULL,'默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint DEFAULT '0' COMMENT '父部门id',
  `ancestors` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '部门名称',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `leader` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=200 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES (100,0,'0','若依科技',0,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(101,100,'0,100','深圳总公司',1,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(102,100,'0,100','长沙分公司',2,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(103,101,'0,100,101','研发部门',1,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(104,101,'0,100,101','市场部门',2,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(105,101,'0,100,101','测试部门',3,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(106,101,'0,100,101','财务部门',4,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(107,101,'0,100,101','运维部门',5,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(108,102,'0,100,102','市场部门',1,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL),(109,102,'0,100,102','财务部门',2,'若依','15888888888','ry@qq.com','0','0','admin','2026-10-26 16:58:16','',NULL);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int DEFAULT '0' COMMENT '字典排序',
  `dict_label` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) COLLATE utf8mb4_unicode_ci DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`)
) ENGINE=InnoDB AUTO_INCREMENT=6111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,1,'男','0','sys_user_sex','','','Y','0','admin','2026-10-26 16:58:18','',NULL,'性别男'),(2,2,'女','1','sys_user_sex','','','N','0','admin','2026-10-26 16:58:18','',NULL,'性别女'),(3,3,'未知','2','sys_user_sex','','','N','0','admin','2026-10-26 16:58:18','',NULL,'性别未知'),(4,1,'显示','0','sys_show_hide','','primary','Y','0','admin','2026-10-26 16:58:18','',NULL,'显示菜单'),(5,2,'隐藏','1','sys_show_hide','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'隐藏菜单'),(6,1,'正常','0','sys_normal_disable','','primary','Y','0','admin','2026-10-26 16:58:18','',NULL,'正常状态'),(7,2,'停用','1','sys_normal_disable','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'停用状态'),(8,1,'正常','0','sys_job_status','','primary','Y','0','admin','2026-10-26 16:58:18','',NULL,'正常状态'),(9,2,'暂停','1','sys_job_status','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'停用状态'),(10,1,'默认','DEFAULT','sys_job_group','','','Y','0','admin','2026-10-26 16:58:18','',NULL,'默认分组'),(11,2,'系统','SYSTEM','sys_job_group','','','N','0','admin','2026-10-26 16:58:18','',NULL,'系统分组'),(12,1,'是','Y','sys_yes_no','','primary','Y','0','admin','2026-10-26 16:58:18','',NULL,'系统默认是'),(13,2,'否','N','sys_yes_no','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'系统默认否'),(14,1,'通知','1','sys_notice_type','','warning','Y','0','admin','2026-10-26 16:58:18','',NULL,'通知'),(15,2,'公告','2','sys_notice_type','','success','N','0','admin','2026-10-26 16:58:18','',NULL,'公告'),(16,1,'正常','0','sys_notice_status','','primary','Y','0','admin','2026-10-26 16:58:18','',NULL,'正常状态'),(17,2,'关闭','1','sys_notice_status','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'关闭状态'),(18,99,'其他','0','sys_oper_type','','info','N','0','admin','2026-10-26 16:58:18','',NULL,'其他操作'),(19,1,'新增','1','sys_oper_type','','info','N','0','admin','2026-10-26 16:58:18','',NULL,'新增操作'),(20,2,'修改','2','sys_oper_type','','info','N','0','admin','2026-10-26 16:58:18','',NULL,'修改操作'),(21,3,'删除','3','sys_oper_type','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'删除操作'),(22,4,'授权','4','sys_oper_type','','primary','N','0','admin','2026-10-26 16:58:18','',NULL,'授权操作'),(23,5,'导出','5','sys_oper_type','','warning','N','0','admin','2026-10-26 16:58:18','',NULL,'导出操作'),(24,6,'导入','6','sys_oper_type','','warning','N','0','admin','2026-10-26 16:58:18','',NULL,'导入操作'),(25,7,'强退','7','sys_oper_type','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'强退操作'),(26,8,'生成代码','8','sys_oper_type','','warning','N','0','admin','2026-10-26 16:58:18','',NULL,'生成操作'),(27,9,'清空数据','9','sys_oper_type','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'清空操作'),(28,1,'成功','0','sys_common_status','','primary','N','0','admin','2026-10-26 16:58:18','',NULL,'正常状态'),(29,2,'失败','1','sys_common_status','','danger','N','0','admin','2026-10-26 16:58:18','',NULL,'停用状态'),(6000,0,'ACTIVE','ACTIVE','biz_company_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6001,1,'DISABLED','DISABLED','biz_company_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6010,0,'DRAFT','DRAFT','biz_company_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6011,1,'PENDING','PENDING','biz_company_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6012,2,'APPROVED','APPROVED','biz_company_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6013,3,'REJECTED','REJECTED','biz_company_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6014,4,'WITHDRAWN','WITHDRAWN','biz_company_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6020,0,'DRAFT','DRAFT','biz_employee_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6021,1,'PENDING','PENDING','biz_employee_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6022,2,'APPROVED','APPROVED','biz_employee_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6023,3,'REJECTED','REJECTED','biz_employee_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6024,4,'WITHDRAWN','WITHDRAWN','biz_employee_apply_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6030,0,'ACTIVE','ACTIVE','biz_employee_info_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6031,1,'LEFT','LEFT','biz_employee_info_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6040,0,'ACTIVE','ACTIVE','biz_access_permission_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6041,1,'REVOKED','REVOKED','biz_access_permission_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6050,0,'DRAFT','DRAFT','biz_daily_output_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6051,1,'SUBMITTED','SUBMITTED','biz_daily_output_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6052,2,'CONFIRMED','CONFIRMED','biz_daily_output_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6053,3,'RETURNED','RETURNED','biz_daily_output_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6060,0,'DRAFT','DRAFT','biz_project_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6061,1,'ACTIVE','ACTIVE','biz_project_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6062,2,'COMPLETED','COMPLETED','biz_project_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6063,3,'ARCHIVED','ARCHIVED','biz_project_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6064,4,'CANCELLED','CANCELLED','biz_project_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6070,0,'DRAFT','DRAFT','biz_task_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6071,1,'PUBLISHED','PUBLISHED','biz_task_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6072,2,'EXECUTING','EXECUTING','biz_task_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6073,3,'PENDING_ACCEPTANCE','PENDING_ACCEPTANCE','biz_task_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6074,4,'ARCHIVED','ARCHIVED','biz_task_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6075,5,'CANCELLED','CANCELLED','biz_task_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6080,0,'PENDING','PENDING','biz_task_signup_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6081,1,'APPROVED','APPROVED','biz_task_signup_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6082,2,'REJECTED','REJECTED','biz_task_signup_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6083,3,'WITHDRAWN','WITHDRAWN','biz_task_signup_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6090,0,'PENDING','PENDING','biz_task_assignment_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6091,1,'EXECUTING','EXECUTING','biz_task_assignment_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6092,2,'PENDING_CONFIRM','PENDING_CONFIRM','biz_task_assignment_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6093,3,'COMPLETED','COMPLETED','biz_task_assignment_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6094,4,'CANCELLED','CANCELLED','biz_task_assignment_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6100,0,'DRAFT','DRAFT','biz_work_record_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6101,1,'SUBMITTED','SUBMITTED','biz_work_record_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6102,2,'CONFIRMED','CONFIRMED','biz_work_record_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6103,3,'RETURNED','RETURNED','biz_work_record_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(6110,0,'RECORDED','RECORDED','biz_audit_record_status',NULL,NULL,'N','0','stage02','2026-10-26 16:58:20','',NULL,NULL);
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '字典类型',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=612 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'用户性别','sys_user_sex','0','admin','2026-10-26 16:58:18','',NULL,'用户性别列表'),(2,'菜单状态','sys_show_hide','0','admin','2026-10-26 16:58:18','',NULL,'菜单状态列表'),(3,'系统开关','sys_normal_disable','0','admin','2026-10-26 16:58:18','',NULL,'系统开关列表'),(4,'任务状态','sys_job_status','0','admin','2026-10-26 16:58:18','',NULL,'任务状态列表'),(5,'任务分组','sys_job_group','0','admin','2026-10-26 16:58:18','',NULL,'任务分组列表'),(6,'系统是否','sys_yes_no','0','admin','2026-10-26 16:58:18','',NULL,'系统是否列表'),(7,'通知类型','sys_notice_type','0','admin','2026-10-26 16:58:18','',NULL,'通知类型列表'),(8,'通知状态','sys_notice_status','0','admin','2026-10-26 16:58:18','',NULL,'通知状态列表'),(9,'操作类型','sys_oper_type','0','admin','2026-10-26 16:58:18','',NULL,'操作类型列表'),(10,'系统状态','sys_common_status','0','admin','2026-10-26 16:58:18','',NULL,'登录状态列表'),(600,'企业状态','biz_company_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(601,'企业申请状态','biz_company_apply_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(602,'员工申请状态','biz_employee_apply_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(603,'员工档案状态','biz_employee_info_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(604,'门禁授权状态','biz_access_permission_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(605,'业务填报状态','biz_daily_output_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(606,'项目状态','biz_project_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(607,'任务状态','biz_task_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(608,'任务报名状态','biz_task_signup_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(609,'任务分配状态','biz_task_assignment_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(610,'工作记录状态','biz_work_record_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(611,'审批轨迹状态','biz_audit_record_status','0','stage02','2026-10-26 16:58:20','',NULL,NULL);
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job`
--

DROP TABLE IF EXISTS `sys_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job` (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`,`job_name`,`job_group`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时任务调度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job`
--

LOCK TABLES `sys_job` WRITE;
/*!40000 ALTER TABLE `sys_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job_log`
--

DROP TABLE IF EXISTS `sys_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job_log` (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '日志信息',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '异常信息',
  `start_time` datetime DEFAULT NULL COMMENT '执行开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '执行结束时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时任务调度日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job_log`
--

LOCK TABLES `sys_job_log` WRITE;
/*!40000 ALTER TABLE `sys_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_logininfor`
--

DROP TABLE IF EXISTS `sys_logininfor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_logininfor` (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '操作系统',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '提示消息',
  `login_time` datetime DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`),
  KEY `idx_sys_logininfor_s` (`status`),
  KEY `idx_sys_logininfor_lt` (`login_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统访问记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_logininfor`
--

LOCK TABLES `sys_logininfor` WRITE;
/*!40000 ALTER TABLE `sys_logininfor` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_logininfor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '路由名称',
  `is_frame` int DEFAULT '1' COMMENT '是否为外链（0是 1否）',
  `is_cache` int DEFAULT '0' COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,'系统管理',0,1,'system',NULL,'','',1,0,'M','0','0','','system','admin','2026-10-26 16:58:16','',NULL,'系统管理目录'),(2,'系统监控',0,2,'monitor',NULL,'','',1,0,'M','0','0','','monitor','admin','2026-10-26 16:58:16','',NULL,'系统监控目录'),(3,'系统工具',0,3,'tool',NULL,'','',1,0,'M','0','0','','tool','admin','2026-10-26 16:58:16','',NULL,'系统工具目录'),(4,'若依官网',0,4,'http://ruoyi.vip',NULL,'','',0,0,'M','0','0','','guide','admin','2026-10-26 16:58:16','',NULL,'若依官网地址'),(100,'用户管理',1,1,'user','system/user/index','','',1,0,'C','0','0','system:user:list','user','admin','2026-10-26 16:58:16','',NULL,'用户管理菜单'),(101,'角色管理',1,2,'role','system/role/index','','',1,0,'C','0','0','system:role:list','peoples','admin','2026-10-26 16:58:16','',NULL,'角色管理菜单'),(102,'菜单管理',1,3,'menu','system/menu/index','','',1,0,'C','0','0','system:menu:list','tree-table','admin','2026-10-26 16:58:16','',NULL,'菜单管理菜单'),(103,'部门管理',1,4,'dept','system/dept/index','','',1,0,'C','0','0','system:dept:list','tree','admin','2026-10-26 16:58:16','',NULL,'部门管理菜单'),(104,'岗位管理',1,5,'post','system/post/index','','',1,0,'C','0','0','system:post:list','post','admin','2026-10-26 16:58:16','',NULL,'岗位管理菜单'),(105,'字典管理',1,6,'dict','system/dict/index','','',1,0,'C','0','0','system:dict:list','dict','admin','2026-10-26 16:58:16','',NULL,'字典管理菜单'),(106,'参数设置',1,7,'config','system/config/index','','',1,0,'C','0','0','system:config:list','edit','admin','2026-10-26 16:58:16','',NULL,'参数设置菜单'),(107,'通知公告',1,8,'notice','system/notice/index','','',1,0,'C','0','0','system:notice:list','message','admin','2026-10-26 16:58:16','',NULL,'通知公告菜单'),(108,'日志管理',1,9,'log','','','',1,0,'M','0','0','','log','admin','2026-10-26 16:58:16','',NULL,'日志管理菜单'),(109,'在线用户',2,1,'online','monitor/online/index','','',1,0,'C','0','0','monitor:online:list','online','admin','2026-10-26 16:58:16','',NULL,'在线用户菜单'),(110,'定时任务',2,2,'job','monitor/job/index','','',1,0,'C','0','0','monitor:job:list','job','admin','2026-10-26 16:58:16','',NULL,'定时任务菜单'),(111,'数据监控',2,3,'druid','monitor/druid/index','','',1,0,'C','0','0','monitor:druid:list','druid','admin','2026-10-26 16:58:16','',NULL,'数据监控菜单'),(112,'服务监控',2,4,'server','monitor/server/index','','',1,0,'C','0','0','monitor:server:list','server','admin','2026-10-26 16:58:16','',NULL,'服务监控菜单'),(113,'缓存监控',2,5,'cache','monitor/cache/index','','',1,0,'C','0','0','monitor:cache:list','redis','admin','2026-10-26 16:58:16','',NULL,'缓存监控菜单'),(114,'缓存列表',2,6,'cacheList','monitor/cache/list','','',1,0,'C','0','0','monitor:cache:list','redis-list','admin','2026-10-26 16:58:16','',NULL,'缓存列表菜单'),(115,'表单构建',3,1,'build','tool/build/index','','',1,0,'C','0','0','tool:build:list','build','admin','2026-10-26 16:58:16','',NULL,'表单构建菜单'),(116,'代码生成',3,2,'gen','tool/gen/index','','',1,0,'C','0','0','tool:gen:list','code','admin','2026-10-26 16:58:16','',NULL,'代码生成菜单'),(117,'系统接口',3,3,'swagger','tool/swagger/index','','',1,0,'C','0','0','tool:swagger:list','swagger','admin','2026-10-26 16:58:16','',NULL,'系统接口菜单'),(500,'操作日志',108,1,'operlog','monitor/operlog/index','','',1,0,'C','0','0','monitor:operlog:list','form','admin','2026-10-26 16:58:16','',NULL,'操作日志菜单'),(501,'登录日志',108,2,'logininfor','monitor/logininfor/index','','',1,0,'C','0','0','monitor:logininfor:list','logininfor','admin','2026-10-26 16:58:16','',NULL,'登录日志菜单'),(1000,'用户查询',100,1,'','','','',1,0,'F','0','0','system:user:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1001,'用户新增',100,2,'','','','',1,0,'F','0','0','system:user:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1002,'用户修改',100,3,'','','','',1,0,'F','0','0','system:user:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1003,'用户删除',100,4,'','','','',1,0,'F','0','0','system:user:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1004,'用户导出',100,5,'','','','',1,0,'F','0','0','system:user:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1005,'用户导入',100,6,'','','','',1,0,'F','0','0','system:user:import','#','admin','2026-10-26 16:58:16','',NULL,''),(1006,'重置密码',100,7,'','','','',1,0,'F','0','0','system:user:resetPwd','#','admin','2026-10-26 16:58:16','',NULL,''),(1007,'角色查询',101,1,'','','','',1,0,'F','0','0','system:role:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1008,'角色新增',101,2,'','','','',1,0,'F','0','0','system:role:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1009,'角色修改',101,3,'','','','',1,0,'F','0','0','system:role:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1010,'角色删除',101,4,'','','','',1,0,'F','0','0','system:role:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1011,'角色导出',101,5,'','','','',1,0,'F','0','0','system:role:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1012,'菜单查询',102,1,'','','','',1,0,'F','0','0','system:menu:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1013,'菜单新增',102,2,'','','','',1,0,'F','0','0','system:menu:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1014,'菜单修改',102,3,'','','','',1,0,'F','0','0','system:menu:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1015,'菜单删除',102,4,'','','','',1,0,'F','0','0','system:menu:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1016,'部门查询',103,1,'','','','',1,0,'F','0','0','system:dept:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1017,'部门新增',103,2,'','','','',1,0,'F','0','0','system:dept:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1018,'部门修改',103,3,'','','','',1,0,'F','0','0','system:dept:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1019,'部门删除',103,4,'','','','',1,0,'F','0','0','system:dept:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1020,'岗位查询',104,1,'','','','',1,0,'F','0','0','system:post:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1021,'岗位新增',104,2,'','','','',1,0,'F','0','0','system:post:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1022,'岗位修改',104,3,'','','','',1,0,'F','0','0','system:post:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1023,'岗位删除',104,4,'','','','',1,0,'F','0','0','system:post:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1024,'岗位导出',104,5,'','','','',1,0,'F','0','0','system:post:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1025,'字典查询',105,1,'#','','','',1,0,'F','0','0','system:dict:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1026,'字典新增',105,2,'#','','','',1,0,'F','0','0','system:dict:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1027,'字典修改',105,3,'#','','','',1,0,'F','0','0','system:dict:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1028,'字典删除',105,4,'#','','','',1,0,'F','0','0','system:dict:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1029,'字典导出',105,5,'#','','','',1,0,'F','0','0','system:dict:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1030,'参数查询',106,1,'#','','','',1,0,'F','0','0','system:config:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1031,'参数新增',106,2,'#','','','',1,0,'F','0','0','system:config:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1032,'参数修改',106,3,'#','','','',1,0,'F','0','0','system:config:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1033,'参数删除',106,4,'#','','','',1,0,'F','0','0','system:config:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1034,'参数导出',106,5,'#','','','',1,0,'F','0','0','system:config:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1035,'公告查询',107,1,'#','','','',1,0,'F','0','0','system:notice:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1036,'公告新增',107,2,'#','','','',1,0,'F','0','0','system:notice:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1037,'公告修改',107,3,'#','','','',1,0,'F','0','0','system:notice:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1038,'公告删除',107,4,'#','','','',1,0,'F','0','0','system:notice:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1039,'操作查询',500,1,'#','','','',1,0,'F','0','0','monitor:operlog:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1040,'操作删除',500,2,'#','','','',1,0,'F','0','0','monitor:operlog:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1041,'日志导出',500,3,'#','','','',1,0,'F','0','0','monitor:operlog:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1042,'登录查询',501,1,'#','','','',1,0,'F','0','0','monitor:logininfor:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1043,'登录删除',501,2,'#','','','',1,0,'F','0','0','monitor:logininfor:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1044,'日志导出',501,3,'#','','','',1,0,'F','0','0','monitor:logininfor:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1045,'账户解锁',501,4,'#','','','',1,0,'F','0','0','monitor:logininfor:unlock','#','admin','2026-10-26 16:58:16','',NULL,''),(1046,'在线查询',109,1,'#','','','',1,0,'F','0','0','monitor:online:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1047,'批量强退',109,2,'#','','','',1,0,'F','0','0','monitor:online:batchLogout','#','admin','2026-10-26 16:58:16','',NULL,''),(1048,'单条强退',109,3,'#','','','',1,0,'F','0','0','monitor:online:forceLogout','#','admin','2026-10-26 16:58:16','',NULL,''),(1049,'任务查询',110,1,'#','','','',1,0,'F','0','0','monitor:job:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1050,'任务新增',110,2,'#','','','',1,0,'F','0','0','monitor:job:add','#','admin','2026-10-26 16:58:16','',NULL,''),(1051,'任务修改',110,3,'#','','','',1,0,'F','0','0','monitor:job:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1052,'任务删除',110,4,'#','','','',1,0,'F','0','0','monitor:job:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1053,'状态修改',110,5,'#','','','',1,0,'F','0','0','monitor:job:changeStatus','#','admin','2026-10-26 16:58:16','',NULL,''),(1054,'任务导出',110,6,'#','','','',1,0,'F','0','0','monitor:job:export','#','admin','2026-10-26 16:58:16','',NULL,''),(1055,'生成查询',116,1,'#','','','',1,0,'F','0','0','tool:gen:query','#','admin','2026-10-26 16:58:16','',NULL,''),(1056,'生成修改',116,2,'#','','','',1,0,'F','0','0','tool:gen:edit','#','admin','2026-10-26 16:58:16','',NULL,''),(1057,'生成删除',116,3,'#','','','',1,0,'F','0','0','tool:gen:remove','#','admin','2026-10-26 16:58:16','',NULL,''),(1058,'导入代码',116,4,'#','','','',1,0,'F','0','0','tool:gen:import','#','admin','2026-10-26 16:58:16','',NULL,''),(1059,'预览代码',116,5,'#','','','',1,0,'F','0','0','tool:gen:preview','#','admin','2026-10-26 16:58:16','',NULL,''),(1060,'生成代码',116,6,'#','','','',1,0,'F','0','0','tool:gen:code','#','admin','2026-10-26 16:58:16','',NULL,''),(6000,'业务平台',0,5,'business',NULL,NULL,'',1,0,'M','0','0',NULL,'tree','stage02','2026-10-26 16:58:20','',NULL,''),(6100,'企业',6000,0,'company','business/records/index','{\"module\":\"company\"}','BizCompany',1,0,'C','0','0','biz:company:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6110,'企业申请',6000,1,'company_apply','business/records/index','{\"module\":\"company_apply\"}','BizCompanyapply',1,0,'C','0','0','biz:company_apply:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6120,'员工申请',6000,2,'employee_apply','business/records/index','{\"module\":\"employee_apply\"}','BizEmployeeapply',1,0,'C','0','0','biz:employee_apply:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6130,'员工档案',6000,3,'employee_info','business/records/index','{\"module\":\"employee_info\"}','BizEmployeeinfo',1,0,'C','0','0','biz:employee_info:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6140,'门禁授权',6000,4,'access_permission','business/records/index','{\"module\":\"access_permission\"}','BizAccesspermission',1,0,'C','0','0','biz:access_permission:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6150,'业务填报',6000,5,'daily_output','business/reporting/index','{\"module\":\"daily_output\"}','BizDailyoutput',1,0,'C','0','0','biz:daily_output:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6151,'add',6150,1,'',NULL,NULL,'',1,0,'F','0','0','biz:daily_output:add','#','stage02','2026-10-26 16:58:20','',NULL,''),(6152,'edit',6150,2,'',NULL,NULL,'',1,0,'F','0','0','biz:daily_output:edit','#','stage02','2026-10-26 16:58:20','',NULL,''),(6160,'项目',6000,6,'project','business/records/index','{\"module\":\"project\"}','BizProject',1,0,'C','0','0','biz:project:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6170,'任务',6000,7,'task','business/records/index','{\"module\":\"task\"}','BizTask',1,0,'C','0','0','biz:task:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6180,'任务报名',6000,8,'task_signup','business/records/index','{\"module\":\"task_signup\"}','BizTasksignup',1,0,'C','0','0','biz:task_signup:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6190,'任务分配',6000,9,'task_assignment','business/records/index','{\"module\":\"task_assignment\"}','BizTaskassignment',1,0,'C','0','0','biz:task_assignment:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6200,'工作记录',6000,10,'work_record','business/records/index','{\"module\":\"work_record\"}','BizWorkrecord',1,0,'C','0','0','biz:work_record:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6210,'审批轨迹',6000,11,'audit_record','business/records/index','{\"module\":\"audit_record\"}','BizAuditrecord',1,0,'C','0','0','biz:audit_record:list','list','stage02','2026-10-26 16:58:20','',NULL,''),(6500,'企业入驻',6000,1,'onboarding','business/onboarding/index',NULL,'CompanyOnboarding',1,0,'C','0','0','biz:onboarding:apply','edit','',NULL,'',NULL,''),(6501,'入驻审核',6000,2,'company-review','business/onboarding/index',NULL,'CompanyReview',1,0,'C','0','0','biz:onboarding:review','validCode','',NULL,'',NULL,''),(6502,'企业资料',6000,3,'company-profile','business/onboarding/index',NULL,'CompanyProfile',1,0,'C','0','0','biz:onboarding:manage','table','',NULL,'',NULL,''),(6600,'员工入驻',6000,4,'employee-join','business/employees/index',NULL,'EmployeeJoin',1,0,'C','0','0','biz:employee:apply','user','',NULL,'',NULL,''),(6601,'员工审核',6000,5,'employee-review','business/employees/index',NULL,'EmployeeReview',1,0,'C','0','0','biz:employee:review','validCode','',NULL,'',NULL,''),(6602,'员工管理',6000,6,'employees','business/employees/index',NULL,'EmployeeManage',1,0,'C','0','0','biz:employee:manage','peoples','',NULL,'',NULL,''),(6603,'我的员工资料',6000,7,'employee-profile','business/employees/index',NULL,'EmployeeProfile',1,0,'C','0','0','biz:employee:profile','user','',NULL,'',NULL,''),(6604,'分配业务角色',6602,1,'',NULL,NULL,'',1,0,'F','0','0','biz:employee:roles','#','',NULL,'',NULL,''),(6700,'人员档案与统计',6000,8,'personnel','business/personnel/index',NULL,'PersonnelManagement',1,0,'C','0','0','biz:personnel:list','peoples','',NULL,'',NULL,''),(6701,'维护人员档案',6700,1,'',NULL,NULL,'',1,0,'F','0','0','biz:personnel:edit','#','',NULL,'',NULL,''),(6702,'导出人员',6700,2,'',NULL,NULL,'',1,0,'F','0','0','biz:personnel:export','#','',NULL,'',NULL,''),(6703,'离职处理',6700,3,'',NULL,NULL,'',1,0,'F','0','0','biz:personnel:leave','#','',NULL,'',NULL,''),(6710,'门禁授权记录',6000,9,'access-records','business/personnel/index',NULL,'AccessRecords',1,0,'C','0','0','biz:access:list','lock','',NULL,'',NULL,''),(6711,'维护授权记录',6710,1,'',NULL,NULL,'',1,0,'F','0','0','biz:access:edit','#','',NULL,'',NULL,''),(6800,'填报规则与日历',6000,10,'report-rules','business/reporting/index',NULL,'ReportRules',1,0,'C','0','0','biz:report:config','date','',NULL,'',NULL,''),(6810,'填报查询',6150,1,'',NULL,NULL,'',1,0,'F','0','0','biz:report:read','#','',NULL,'',NULL,''),(6811,'填报提交',6150,2,'',NULL,NULL,'',1,0,'F','0','0','biz:report:write','#','',NULL,'',NULL,''),(6812,'月度核对',6150,3,'',NULL,NULL,'',1,0,'F','0','0','biz:report:review','#','',NULL,'',NULL,''),(6900,'任务发布管理',6000,11,'task-manage','business/tasks/index',NULL,'TaskManage',1,0,'C','0','0','biz:tasks:manage','edit','',NULL,'',NULL,''),(6901,'可报名任务',6000,12,'task-market','business/tasks/index',NULL,'TaskMarket',1,0,'C','0','0','biz:tasks:read','list','',NULL,'',NULL,''),(6902,'企业报名记录',6000,13,'task-signups','business/tasks/index',NULL,'TaskSignups',1,0,'C','0','0','biz:tasks:signup','form','',NULL,'',NULL,''),(6903,'平台报名审核',6000,14,'task-reviews','business/tasks/index',NULL,'TaskReviews',1,0,'C','0','0','biz:tasks:review','validCode','',NULL,'',NULL,''),(7000,'项目执行管理',6000,15,'execution-projects','business/execution/index',NULL,'ExecutionProjects',1,0,'C','0','0','biz:execution:read','tree','',NULL,'',NULL,''),(7001,'我的任务与上报',6000,16,'execution-mine','business/execution/index',NULL,'ExecutionMine',1,0,'C','0','0','biz:execution:work','edit','',NULL,'',NULL,''),(7002,'项目分配与核验',7000,1,'',NULL,NULL,'',1,0,'F','0','0','biz:execution:manage','#','',NULL,'',NULL,''),(7100,'统计工作台与报表',6000,17,'statistics','business/statistics/index',NULL,'StatisticsReports',1,0,'C','0','0','biz:statistics:read','chart','',NULL,'',NULL,''),(7101,'Excel报表导出',7100,1,'',NULL,NULL,'',1,0,'F','0','0','biz:statistics:export','#','',NULL,'',NULL,''),(7102,'任务报价维护',7100,2,'',NULL,NULL,'',1,0,'F','0','0','biz:statistics:price','#','',NULL,'',NULL,'');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob COMMENT '公告内容',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

LOCK TABLES `sys_notice` WRITE;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice_read`
--

DROP TABLE IF EXISTS `sys_notice_read`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice_read` (
  `read_id` bigint NOT NULL AUTO_INCREMENT COMMENT '已读主键',
  `notice_id` int NOT NULL COMMENT '公告id',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `read_time` datetime NOT NULL COMMENT '阅读时间',
  PRIMARY KEY (`read_id`),
  UNIQUE KEY `uk_user_notice` (`user_id`,`notice_id`) COMMENT '同一用户同一公告只记录一次'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公告已读记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice_read`
--

LOCK TABLES `sys_notice_read` WRITE;
/*!40000 ALTER TABLE `sys_notice_read` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_notice_read` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_oper_log`
--

DROP TABLE IF EXISTS `sys_oper_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oper_log` (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '模块标题',
  `business_type` int DEFAULT '0' COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '请求方式',
  `operator_type` int DEFAULT '0' COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '返回参数',
  `status` int DEFAULT '0' COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint DEFAULT '0' COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`),
  KEY `idx_sys_oper_log_bt` (`business_type`),
  KEY `idx_sys_oper_log_s` (`status`),
  KEY `idx_sys_oper_log_ot` (`oper_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_oper_log`
--

LOCK TABLES `sys_oper_log` WRITE;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_oper_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_post`
--

DROP TABLE IF EXISTS `sys_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_post` (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='岗位信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_post`
--

LOCK TABLES `sys_post` WRITE;
/*!40000 ALTER TABLE `sys_post` DISABLE KEYS */;
INSERT INTO `sys_post` VALUES (1,'ceo','董事长',1,'0','admin','2026-10-26 16:58:16','',NULL,''),(2,'se','项目经理',2,'0','admin','2026-10-26 16:58:16','',NULL,''),(3,'hr','人力资源',3,'0','admin','2026-10-26 16:58:16','',NULL,''),(4,'user','普通员工',4,'0','admin','2026-10-26 16:58:16','',NULL,'');
/*!40000 ALTER TABLE `sys_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) DEFAULT '1' COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) DEFAULT '1' COMMENT '部门树选择项是否关联显示',
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'超级管理员','admin',1,'1',1,1,'0','0','admin','2026-10-26 16:58:16','',NULL,'超级管理员'),(2,'普通角色','common',2,'2',1,1,'0','0','admin','2026-10-26 16:58:16','',NULL,'普通角色'),(200,'平台管理员','platform_admin',200,'5',1,1,'0','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(201,'企业管理员','company_admin',201,'5',1,1,'0','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(202,'企业人事专岗','company_hr',202,'5',1,1,'0','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(203,'企业业务岗','company_business',203,'5',1,1,'0','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(204,'企业财务岗','company_finance',204,'5',1,1,'0','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(205,'普通员工','employee',205,'5',1,1,'0','0','stage02','2026-10-26 16:58:20','',NULL,NULL),(206,'入驻申请人','company_applicant',206,'5',1,1,'0','0','',NULL,'',NULL,NULL);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_dept`
--

DROP TABLE IF EXISTS `sys_role_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色和部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_dept`
--

LOCK TABLES `sys_role_dept` WRITE;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
INSERT INTO `sys_role_dept` VALUES (2,100),(2,101),(2,105);
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色和菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (2,1),(2,2),(2,3),(2,4),(2,100),(2,101),(2,102),(2,103),(2,104),(2,105),(2,106),(2,107),(2,108),(2,109),(2,110),(2,111),(2,112),(2,113),(2,114),(2,115),(2,116),(2,117),(2,500),(2,501),(2,1000),(2,1001),(2,1002),(2,1003),(2,1004),(2,1005),(2,1006),(2,1007),(2,1008),(2,1009),(2,1010),(2,1011),(2,1012),(2,1013),(2,1014),(2,1015),(2,1016),(2,1017),(2,1018),(2,1019),(2,1020),(2,1021),(2,1022),(2,1023),(2,1024),(2,1025),(2,1026),(2,1027),(2,1028),(2,1029),(2,1030),(2,1031),(2,1032),(2,1033),(2,1034),(2,1035),(2,1036),(2,1037),(2,1038),(2,1039),(2,1040),(2,1041),(2,1042),(2,1043),(2,1044),(2,1045),(2,1046),(2,1047),(2,1048),(2,1049),(2,1050),(2,1051),(2,1052),(2,1053),(2,1054),(2,1055),(2,1056),(2,1057),(2,1058),(2,1059),(2,1060),(200,6000),(200,6100),(200,6110),(200,6120),(200,6130),(200,6140),(200,6150),(200,6151),(200,6152),(200,6160),(200,6170),(200,6180),(200,6190),(200,6200),(200,6210),(200,6500),(200,6501),(200,6502),(200,6600),(200,6603),(200,6800),(200,6810),(200,6811),(200,6812),(200,6900),(200,6901),(200,6903),(200,7000),(200,7100),(200,7101),(200,7102),(201,6000),(201,6100),(201,6110),(201,6120),(201,6130),(201,6140),(201,6150),(201,6151),(201,6152),(201,6160),(201,6170),(201,6180),(201,6190),(201,6200),(201,6210),(201,6500),(201,6502),(201,6600),(201,6601),(201,6602),(201,6603),(201,6604),(201,6700),(201,6701),(201,6702),(201,6703),(201,6710),(201,6711),(201,6810),(201,6811),(201,6900),(201,6901),(201,6902),(201,7000),(201,7001),(201,7002),(201,7100),(201,7101),(201,7102),(202,6000),(202,6120),(202,6130),(202,6140),(202,6500),(202,6600),(202,6601),(202,6602),(202,6603),(202,6700),(202,6701),(202,6702),(202,6703),(202,6710),(202,6711),(202,7001),(202,7100),(202,7101),(203,6000),(203,6100),(203,6150),(203,6151),(203,6152),(203,6160),(203,6170),(203,6180),(203,6190),(203,6200),(203,6500),(203,6600),(203,6603),(203,6810),(203,6811),(203,6900),(203,6901),(203,6902),(203,7000),(203,7001),(203,7002),(203,7100),(203,7101),(203,7102),(204,6000),(204,6100),(204,6150),(204,6160),(204,6200),(204,6500),(204,6600),(204,6603),(204,6810),(204,7000),(204,7001),(204,7100),(204,7101),(205,6000),(205,6120),(205,6130),(205,6170),(205,6190),(205,6200),(205,6500),(205,6600),(205,6603),(205,7001),(206,6000),(206,6500),(206,6600),(206,6603);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '手机号码',
  `sex` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '密码',
  `status` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,103,'admin','若依','00','','','1','','!BOOTSTRAP_REQUIRED','1','0','127.0.0.1','2026-10-26 16:58:16','2026-10-26 16:58:16','admin','2026-10-26 16:58:16','',NULL,'管理员');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_post`
--

DROP TABLE IF EXISTS `sys_user_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_post` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户与岗位关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_post`
--

LOCK TABLES `sys_user_post` WRITE;
/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户和角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES (1,1);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
