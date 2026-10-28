package com.ruoyi.web.biz;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/execution")
public class ExecutionController {
 final ExecutionService s;public ExecutionController(ExecutionService s){this.s=s;}
 @GetMapping("/companies") public AjaxResult companies(){return AjaxResult.success(s.companies());}
 @GetMapping("/approved") public AjaxResult approved(){return AjaxResult.success(s.approved());}
 @GetMapping("/staff") public AjaxResult staff(){return AjaxResult.success(s.staff());}
 @GetMapping("/projects") public AjaxResult projects(@RequestParam(required=false) Long companyId){return AjaxResult.success(s.projects(companyId));}
 @GetMapping("/projects/{id}") public AjaxResult project(@PathVariable long id,@RequestParam(required=false) Long companyId){return AjaxResult.success(s.progress(companyId,id));}
 public record Link(long signupId,Long projectId,String projectName){}
 public record Action(Integer version,String opinion){}
 @Log(title="项目任务关联",businessType=BusinessType.INSERT) @PostMapping("/projects") public AjaxResult link(@RequestBody Link in){return AjaxResult.success((Object)s.link(in.signupId(),in.projectId(),in.projectName()));}
 @Log(title="员工任务分配",businessType=BusinessType.INSERT) @PostMapping("/projects/{id}/assignments") public AjaxResult assign(@PathVariable long id,@RequestBody ExecutionService.Assign in){return AjaxResult.success((Object)s.assign(id,in));}
 @Log(title="任务分配取消",businessType=BusinessType.UPDATE) @PostMapping("/assignments/{id}/cancel") public AjaxResult cancel(@PathVariable long id,@RequestBody Action in){s.cancel(id,in.version(),in.opinion());return AjaxResult.success();}
 @GetMapping("/mine") public AjaxResult mine(){return AjaxResult.success(s.mine());}
 @GetMapping("/mine/{id}") public AjaxResult personal(@PathVariable long id){return AjaxResult.success(s.personal(id));}
 @Log(title="员工任务领取",businessType=BusinessType.UPDATE) @PostMapping("/assignments/{id}/claim") public AjaxResult claim(@PathVariable long id,@RequestBody Action in){s.claim(id,in.version());return AjaxResult.success();}
 @Log(title="员工任务完成",businessType=BusinessType.UPDATE) @PostMapping("/assignments/{id}/finish") public AjaxResult finish(@PathVariable long id,@RequestBody Action in){s.finish(id,in.version());return AjaxResult.success();}
 @Log(title="工作量保存",businessType=BusinessType.INSERT) @PostMapping("/assignments/{id}/records") public AjaxResult save(@PathVariable long id,@RequestBody ExecutionService.Work in){return AjaxResult.success((Object)s.save(id,null,in));}
 @Log(title="工作量修改",businessType=BusinessType.UPDATE) @PutMapping("/assignments/{aid}/records/{id}") public AjaxResult edit(@PathVariable long aid,@PathVariable long id,@RequestBody ExecutionService.Work in){return AjaxResult.success((Object)s.save(aid,id,in));}
 @Log(title="工作量提交",businessType=BusinessType.UPDATE) @PostMapping("/records/{id}/submit") public AjaxResult submit(@PathVariable long id,@RequestBody Action in){s.submit(id,in.version());return AjaxResult.success();}
 public record Review(Integer version,boolean approve,String opinion){}
 @Log(title="工作量审核",businessType=BusinessType.UPDATE) @PostMapping("/records/{id}/review") public AjaxResult review(@PathVariable long id,@RequestBody Review in){s.review(id,in.version(),in.approve(),in.opinion());return AjaxResult.success();}
 @Log(title="工作量更正退回",businessType=BusinessType.UPDATE) @PostMapping("/records/{id}/reopen") public AjaxResult reopen(@PathVariable long id,@RequestBody Action in){s.reopen(id,in.version(),in.opinion());return AjaxResult.success();}
 @Log(title="工作量作废",businessType=BusinessType.UPDATE) @PostMapping("/records/{id}/void") public AjaxResult voidWork(@PathVariable long id,@RequestBody Action in){s.voidWork(id,in.version(),in.opinion());return AjaxResult.success();}
 @Log(title="项目完成确认",businessType=BusinessType.UPDATE) @PostMapping("/projects/{id}/complete") public AjaxResult complete(@PathVariable long id,@RequestBody Action in){s.complete(id,in.version(),in.opinion(),false);return AjaxResult.success();}
 @Log(title="项目归档",businessType=BusinessType.UPDATE) @PostMapping("/projects/{id}/archive") public AjaxResult archive(@PathVariable long id,@RequestBody Action in){s.complete(id,in.version(),in.opinion(),true);return AjaxResult.success();}
 @Log(title="任务完成确认",businessType=BusinessType.UPDATE) @PostMapping("/tasks/{id}/complete") public AjaxResult completeTask(@PathVariable long id,@RequestBody Action in){s.completeTask(id,in.version(),in.opinion());return AjaxResult.success();}
}
