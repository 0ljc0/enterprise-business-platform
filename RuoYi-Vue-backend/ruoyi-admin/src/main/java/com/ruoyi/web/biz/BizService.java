package com.ruoyi.web.biz;
import java.util.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.access.AccessDeniedException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.framework.web.service.PermissionService;
@Service
public class BizService {
 private final BizMapper mapper; private final PermissionService permission; private final DailyReportService reports;
 public BizService(BizMapper mapper,PermissionService permission,DailyReportService reports){this.mapper=mapper;this.permission=permission;this.reports=reports;}
 private void require(BizModule m,String op){if(!permission.hasPermi("biz:"+m.key+":"+op))throw new AccessDeniedException("没有业务操作权限");}
 private record Scope(String where,List<Object> args){}
 private Scope scope(BizModule m,Long requested){
  long user=SecurityUtils.getUserId(); List<Object> args=new ArrayList<>();
  if(mapper.platform(user)){
   if(requested==null)return new Scope("1=1",args);
   args.add(requested);return new Scope(m==BizModule.COMPANY?"b.id=?":"b.company_id=?",args);
  }
  Long company=mapper.company(user);
  if(company==null)throw new AccessDeniedException("账号尚未归属有效企业");
  if(requested!=null&&!requested.equals(company))throw new AccessDeniedException("不能访问其他企业");
  args.add(company);
  String where=m==BizModule.COMPANY?"b.id=?":"b.company_id=?";
  if(m==BizModule.TASK){where="(b.company_id=? OR (b.company_id IS NULL AND b.publisher_type='PLATFORM' AND b.status IN ('PUBLISHED','EXECUTING')))";}
  if(!mapper.manager(user)){
   if(m==BizModule.TASK){where="EXISTS(SELECT 1 FROM biz_task_assignment a WHERE a.task_id=b.id AND a.company_id=? AND a.user_id=?)";args.add(user);}
   else if(Set.of(BizModule.EMPLOYEE_APPLY,BizModule.EMPLOYEE_INFO,BizModule.TASK_ASSIGNMENT,BizModule.WORK_RECORD).contains(m)){where+=" AND b.user_id=?";args.add(user);}
   else throw new AccessDeniedException("员工仅能查看本人业务记录");
  }
  return new Scope(where,args);
 }
 public Map<String,Object> list(String module,Long company,int page,int size){
  BizModule m=BizModule.parse(module);require(m,"list");if(page<1||page>100000||size<1||size>100)throw new ServiceException("分页参数无效",400);
  Scope s=scope(m,company);long total=mapper.count("SELECT COUNT(*) FROM "+m.table()+" b WHERE "+s.where,s.args);
  List<Object> args=new ArrayList<>(s.args);args.add(size);args.add((page-1)*size);
  return Map.of("rows",mapper.list("SELECT b.* FROM "+m.table()+" b WHERE "+s.where+" ORDER BY b.id DESC LIMIT ? OFFSET ?",args),"total",total);
 }
 public Map<String,Object> detail(String module,long id){
  BizModule m=BizModule.parse(module);require(m,"list");Scope s=scope(m,null);List<Object> args=new ArrayList<>(s.args);args.add(id);
  List<Map<String,Object>> rows=mapper.list("SELECT b.* FROM "+m.table()+" b WHERE "+s.where+" AND b.id=?",args);
  if(rows.isEmpty())throw new ServiceException("记录不存在或无权访问",404);return rows.get(0);
 }
 public record OutputInput(Long companyId,LocalDate outputDate,BigDecimal outputValue,String unit,String remark,Integer version){}
 private Long outputCompany(Long requested){
  long user=SecurityUtils.getUserId();Long own=mapper.company(user);
  if(mapper.platform(user)){if(requested==null)throw new ServiceException("请选择企业",400);if(mapper.count("SELECT COUNT(*) FROM biz_company WHERE id=? AND status='ACTIVE'",List.of(requested))!=1)throw new ServiceException("企业无效",400);return requested;}
  if(own==null || (requested!=null&&!own.equals(requested)))throw new AccessDeniedException("不能操作其他企业");return own;
 }
 private void valid(OutputInput in){if(in.outputDate()==null||in.outputValue()==null||in.outputValue().signum()<0||in.outputValue().scale()>2||in.outputValue().compareTo(new BigDecimal("9999999999999999.99"))>0||in.unit()==null||in.unit().isBlank()||in.unit().length()>20||in.remark()!=null&&in.remark().length()>500)throw new ServiceException("日期、金额、单位或备注无效",400);}
 @Transactional
 public void add(OutputInput in){reports.save(null,new DailyReportService.Input(in.companyId(),in.outputDate(),in.outputValue(),in.unit(),in.remark(),in.version()));}
 @Transactional
 public void edit(long id,OutputInput in){reports.save(id,new DailyReportService.Input(in.companyId(),in.outputDate(),in.outputValue(),in.unit(),in.remark(),in.version()));}
}
