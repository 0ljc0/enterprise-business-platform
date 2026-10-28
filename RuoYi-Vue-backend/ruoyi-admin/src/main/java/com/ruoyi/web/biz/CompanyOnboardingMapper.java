package com.ruoyi.web.biz;
import javax.sql.DataSource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
@Repository
public class CompanyOnboardingMapper {
 final JdbcTemplate db;
 public JdbcTemplate database(){return db;}
 public CompanyOnboardingMapper(DataSource ds){db=new JdbcTemplate(ds);}
}
