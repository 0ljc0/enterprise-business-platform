package com.ruoyi.web.biz;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/personnel")
public class PersonnelController {
 final PersonnelService s;public PersonnelController(PersonnelService s){this.s=s;}
 @GetMapping public AjaxResult list(@RequestParam(required=false) String keyword,@RequestParam(required=false) String status,@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize){return AjaxResult.success(s.list(keyword,status,pageNum,pageSize));}
 @GetMapping("/stats") public AjaxResult stats(){return AjaxResult.success(s.stats());}
 @GetMapping("/candidates") public AjaxResult candidates(){return AjaxResult.success(s.candidates());}
 @GetMapping("/{id}") public AjaxResult detail(@PathVariable long id){return AjaxResult.success(s.detail(id));}
 public record StaffInput(Long userId,EmployeeInput data,String reason){}
 public record Change(Integer version,String reason){}
 @Log(title="人员补录",businessType=BusinessType.INSERT) @PostMapping public AjaxResult add(@RequestBody StaffInput in){if(in.userId()==null||in.data()==null)throw new com.ruoyi.common.exception.ServiceException("账号和资料必填",400);s.create(in.userId(),in.data());return AjaxResult.success();}
 @Log(title="人员档案维护",businessType=BusinessType.UPDATE) @PutMapping("/{id}") public AjaxResult update(@PathVariable long id,@RequestBody StaffInput in){if(in.data()==null)throw new com.ruoyi.common.exception.ServiceException("资料必填",400);s.update(id,in.data(),in.reason());return AjaxResult.success();}
 @Log(title="员工离职",businessType=BusinessType.UPDATE) @PostMapping("/{id}/leave") public AjaxResult leave(@PathVariable long id,@RequestBody Change in){s.leave(id,in.version(),in.reason());return AjaxResult.success();}
 @Log(title="人员导出",businessType=BusinessType.EXPORT) @GetMapping("/export") public ResponseEntity<byte[]> export(@RequestParam(required=false) String keyword,@RequestParam(required=false) String status){return ResponseEntity.ok().header("Content-Disposition","attachment; filename=personnel.csv").contentType(MediaType.parseMediaType("text/csv;charset=UTF-8")).body(s.export(keyword,status));}
 @GetMapping("/history/{type}/{id}") public AjaxResult history(@PathVariable String type,@PathVariable long id){return AjaxResult.success(s.history(type,id));}
 @GetMapping("/access") public AjaxResult grants(@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize){return AjaxResult.success(s.grants(pageNum,pageSize));}
 @Log(title="门禁记录创建",businessType=BusinessType.INSERT) @PostMapping("/access") public AjaxResult grant(@RequestBody PersonnelService.GrantInput in){return AjaxResult.success((Object)s.grant(null,in));}
 @Log(title="门禁记录修改",businessType=BusinessType.UPDATE) @PutMapping("/access/{id}") public AjaxResult editGrant(@PathVariable long id,@RequestBody PersonnelService.GrantInput in){return AjaxResult.success((Object)s.grant(id,in));}
 @Log(title="门禁记录撤销",businessType=BusinessType.UPDATE) @PostMapping("/access/{id}/revoke") public AjaxResult revoke(@PathVariable long id,@RequestBody Change in){s.revoke(id,in.version(),in.reason());return AjaxResult.success();}
}
