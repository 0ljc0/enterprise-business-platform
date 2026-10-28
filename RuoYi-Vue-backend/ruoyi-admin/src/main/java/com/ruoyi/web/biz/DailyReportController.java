package com.ruoyi.web.biz;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/reports")
public class DailyReportController {
 final DailyReportService s;public DailyReportController(DailyReportService s){this.s=s;}
 @GetMapping("/companies") public AjaxResult companies(){return AjaxResult.success(s.companies());}
 @GetMapping public AjaxResult list(@RequestParam(required=false) Long companyId,@RequestParam(required=false) String from,@RequestParam(required=false) String to,@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize){return AjaxResult.success(s.list(companyId,from,to,pageNum,pageSize));}
 @GetMapping("/{id}") public AjaxResult detail(@PathVariable long id,@RequestParam(required=false) Long companyId){return AjaxResult.success(s.detail(companyId,id));}
 @Log(title="每日填报保存",businessType=BusinessType.INSERT) @PostMapping public AjaxResult add(@RequestBody DailyReportService.Input in){return AjaxResult.success((Object)s.save(null,in));}
 @Log(title="每日填报修改",businessType=BusinessType.UPDATE) @PutMapping("/{id}") public AjaxResult edit(@PathVariable long id,@RequestBody DailyReportService.Input in){return AjaxResult.success((Object)s.save(id,in));}
 public record Submit(Long companyId,Integer version){}
 @Log(title="每日填报提交",businessType=BusinessType.UPDATE) @PostMapping("/{id}/submit") public AjaxResult submit(@PathVariable long id,@RequestBody Submit in){s.submit(in.companyId(),id,in.version());return AjaxResult.success();}
 @GetMapping("/compliance") public AjaxResult compliance(@RequestParam(required=false) Long companyId){return AjaxResult.success(s.compliance(companyId));}
 @GetMapping("/reminders") public AjaxResult reminders(@RequestParam(required=false) Long companyId){return AjaxResult.success(s.reminders(companyId));}
 @GetMapping("/month") public AjaxResult month(@RequestParam(required=false) Long companyId,@RequestParam String month){return AjaxResult.success(s.summary(companyId,month));}
 public record Review(Long companyId,String month,boolean confirm,Integer version,String opinion){}
 @Log(title="月度核对",businessType=BusinessType.UPDATE) @PostMapping("/month/review") public AjaxResult review(@RequestBody Review in){s.review(in.companyId(),in.month(),in.confirm(),in.version(),in.opinion());return AjaxResult.success();}
 @GetMapping("/config") public AjaxResult config(){return AjaxResult.success(s.configuration());}
 @Log(title="填报规则配置",businessType=BusinessType.UPDATE) @PutMapping("/config") public AjaxResult config(@RequestBody DailyReportService.RuleInput in){s.configure(in);return AjaxResult.success();}
 public record Calendar(LocalDate date,boolean required,String remark){}
 @Log(title="填报日历配置",businessType=BusinessType.UPDATE) @PutMapping("/calendar") public AjaxResult calendar(@RequestBody Calendar in){s.calendar(in.date(),in.required(),in.remark());return AjaxResult.success();}
 public record Start(Long companyId,LocalDate date){}
 @Log(title="企业计报起点",businessType=BusinessType.UPDATE) @PutMapping("/start-date") public AjaxResult start(@RequestBody Start in){s.startDate(in.companyId(),in.date());return AjaxResult.success();}
 @Log(title="填报提醒检查",businessType=BusinessType.OTHER) @PostMapping("/check") public AjaxResult check(){return AjaxResult.success((Object)s.runChecks());}
}
