package com.ruoyi.web.biz;
import java.util.List;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/employees")
public class EmployeeController {
 final EmployeeService s; public EmployeeController(EmployeeService s){this.s=s;}
 @GetMapping("/companies") public AjaxResult companies(){return AjaxResult.success(s.companies());}
 @GetMapping("/applications") public AjaxResult list(@RequestParam(defaultValue="false") boolean review){return AjaxResult.success(s.applications(review));}
 @GetMapping("/applications/{id}") public AjaxResult detail(@PathVariable long id){return AjaxResult.success(s.detail(id));}
 @Log(title="员工申请",businessType=BusinessType.INSERT) @PostMapping("/applications") public AjaxResult add(@RequestBody EmployeeInput a){return AjaxResult.success((Object)s.save(null,a));}
 @Log(title="员工申请修改",businessType=BusinessType.UPDATE) @PutMapping("/applications/{id}") public AjaxResult edit(@PathVariable long id,@RequestBody EmployeeInput a){return AjaxResult.success((Object)s.save(id,a));}
 @Log(title="提交员工申请",businessType=BusinessType.UPDATE) @PostMapping("/applications/{id}/submit") public AjaxResult submit(@PathVariable long id){s.submit(id);return AjaxResult.success();}
 public record Decision(boolean approve,String opinion){}
 @Log(title="员工审核",businessType=BusinessType.UPDATE) @PostMapping("/applications/{id}/review") public AjaxResult review(@PathVariable long id,@RequestBody Decision d){s.review(id,d.approve(),d.opinion());return AjaxResult.success();}
 @GetMapping("/staff") public AjaxResult staff(){return AjaxResult.success(s.staff());}
 @GetMapping("/staff/{id}") public AjaxResult staffDetail(@PathVariable long id){return AjaxResult.success(s.staffDetail(id));}
 @GetMapping("/me") public AjaxResult me(){return AjaxResult.success(s.me());}
 @Log(title="员工档案修改",businessType=BusinessType.UPDATE) @PutMapping("/staff/{id}") public AjaxResult update(@PathVariable long id,@RequestBody EmployeeInput a){s.update(id,a,false);return AjaxResult.success();}
 @Log(title="员工个人资料修改",businessType=BusinessType.UPDATE) @PutMapping("/me/{id}") public AjaxResult personal(@PathVariable long id,@RequestBody EmployeeInput a){s.update(id,a,true);return AjaxResult.success();}
 @Log(title="企业业务角色分配",businessType=BusinessType.GRANT) @PutMapping("/staff/{id}/roles") public AjaxResult roles(@PathVariable long id,@RequestBody List<String> roles){s.roles(id,roles);return AjaxResult.success();}
}
