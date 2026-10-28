package com.ruoyi.web.biz;
import com.ruoyi.common.exception.ServiceException;
public enum BizModule {
    COMPANY("company"),
    COMPANY_APPLY("company_apply"),
    EMPLOYEE_APPLY("employee_apply"),
    EMPLOYEE_INFO("employee_info"),
    ACCESS_PERMISSION("access_permission"),
    DAILY_OUTPUT("daily_output"),
    PROJECT("project"),
    TASK("task"),
    TASK_SIGNUP("task_signup"),
    TASK_ASSIGNMENT("task_assignment"),
    WORK_RECORD("work_record"),
    AUDIT_RECORD("audit_record");
 public final String key;
 BizModule(String key){this.key=key;}
 public String table(){return "biz_"+key;}
 public static BizModule parse(String key){for(BizModule m:values())if(m.key.equals(key))return m;throw new ServiceException("未知业务模块",400);}
}
