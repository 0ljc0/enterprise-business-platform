package com.ruoyi.web.biz;
import java.util.*;
import javax.sql.DataSource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
@Repository
public class BizMapper {
 final JdbcTemplate db;
 public BizMapper(DataSource source){db=new JdbcTemplate(source);}
 public Long company(long user){List<Long> rows=db.queryForList("SELECT r.company_id FROM biz_company_user r JOIN biz_company c ON c.id=r.company_id WHERE r.user_id=? AND r.status='ACTIVE' AND c.status='ACTIVE'",Long.class,user);return rows.isEmpty()?null:rows.get(0);}
 public boolean platform(long user){return user==1 || !db.queryForList("SELECT 1 FROM sys_user_role ur JOIN sys_role r ON r.role_id=ur.role_id WHERE ur.user_id=? AND r.role_key='platform_admin' AND r.status='0' AND r.del_flag='0'",Integer.class,user).isEmpty();}
 public boolean manager(long user){return !db.queryForList("SELECT 1 FROM sys_user_role ur JOIN sys_role r ON r.role_id=ur.role_id WHERE ur.user_id=? AND r.role_key IN ('company_admin','company_hr','company_business','company_finance') AND r.status='0' AND r.del_flag='0'",Integer.class,user).isEmpty();}
 public List<Map<String,Object>> list(String sql,List<Object> args){return db.queryForList(sql,args.toArray());}
 public long count(String sql,List<Object> args){return db.queryForObject(sql,Long.class,args.toArray());}
 public int change(String sql,Object...args){return db.update(sql,args);}
}
