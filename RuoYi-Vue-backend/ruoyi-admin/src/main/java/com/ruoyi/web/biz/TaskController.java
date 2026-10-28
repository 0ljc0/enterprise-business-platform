package com.ruoyi.web.biz;
import java.math.BigDecimal;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/tasks")
public class TaskController {
 final TaskService s;public TaskController(TaskService s){this.s=s;}
 @GetMapping public AjaxResult list(@RequestParam(defaultValue="false") boolean mine,@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize,@RequestParam(required=false) String keyword){return AjaxResult.success(s.list(mine,pageNum,pageSize,keyword));}
 @GetMapping("/{id}") public AjaxResult detail(@PathVariable long id){return AjaxResult.success(s.detail(id));}
 @Log(title="任务草稿创建",businessType=BusinessType.INSERT) @PostMapping public AjaxResult create(@RequestBody TaskInput in){return AjaxResult.success((Object)s.save(null,in));}
 @Log(title="任务草稿编辑",businessType=BusinessType.UPDATE) @PutMapping("/{id}") public AjaxResult edit(@PathVariable long id,@RequestBody TaskInput in){return AjaxResult.success((Object)s.save(id,in));}
 public record Action(Integer version,String reason){}
 @Log(title="任务发布",businessType=BusinessType.UPDATE) @PostMapping("/{id}/publish") public AjaxResult publish(@PathVariable long id,@RequestBody Action in){s.publish(id,in.version());return AjaxResult.success();}
 @Log(title="任务关闭招募",businessType=BusinessType.UPDATE) @PostMapping("/{id}/close") public AjaxResult close(@PathVariable long id,@RequestBody Action in){s.close(id,in.version(),in.reason());return AjaxResult.success();}
 public record Signup(BigDecimal quantity){}
 @Log(title="企业报名",businessType=BusinessType.INSERT) @PostMapping("/{id}/signups") public AjaxResult signup(@PathVariable long id,@RequestBody Signup in){return AjaxResult.success((Object)s.apply(id,in.quantity()));}
 @GetMapping("/signups") public AjaxResult signups(@RequestParam(defaultValue="false") boolean review,@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize){return AjaxResult.success(s.signups(review,pageNum,pageSize));}
 @GetMapping("/signups/{id}") public AjaxResult signup(@PathVariable long id){return AjaxResult.success(s.signupDetail(id));}
 @Log(title="企业报名取消",businessType=BusinessType.UPDATE) @PostMapping("/signups/{id}/withdraw") public AjaxResult withdraw(@PathVariable long id,@RequestBody Action in){s.withdraw(id,in.version());return AjaxResult.success();}
 public record Review(boolean approve,String opinion,Integer version){}
 @Log(title="企业报名审核",businessType=BusinessType.UPDATE) @PostMapping("/signups/{id}/review") public AjaxResult review(@PathVariable long id,@RequestBody Review in){s.review(id,in.approve(),in.opinion(),in.version());return AjaxResult.success();}
}
