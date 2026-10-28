package com.ruoyi.web.biz;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.*;
import java.time.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/statistics")
public class StatisticsController {
 final StatisticsService s;public StatisticsController(StatisticsService s){this.s=s;}
 @GetMapping("/options") public AjaxResult options(){return AjaxResult.success(s.options());}
 @GetMapping("/report") public AjaxResult report(@RequestParam String kind,@RequestParam(required=false) Long companyId,@RequestParam(required=false) LocalDate from,@RequestParam(required=false) LocalDate to,@RequestParam(defaultValue="DAY") String group,@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize){return AjaxResult.success(s.safe(s.report(kind,companyId,from,to,group,pageNum,pageSize)));}
 @Log(title="统计Excel导出",businessType=BusinessType.EXPORT,isSaveResponseData=false) @GetMapping("/export") public ResponseEntity<byte[]> export(@RequestParam String kind,@RequestParam(required=false) Long companyId,@RequestParam(required=false) LocalDate from,@RequestParam(required=false) LocalDate to,@RequestParam(defaultValue="DAY") String group) throws java.io.IOException{var data=s.exportData(kind,companyId,from,to,group);var f=s.filter(companyId,from,to,group);return ResponseEntity.ok().contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")).header("Content-Disposition","attachment; filename=statistics-"+kind+".xlsx").body(StatisticsExcel.create(kind,data,f.company()==null?"平台全部企业":"企业编号"+f.company(),f.from().toString(),f.to().toString()));}
 public record Snapshot(String opinion){}
 @Log(title="项目报价快照补录",businessType=BusinessType.UPDATE) @PostMapping("/projects/{id}/price-snapshot") public AjaxResult snapshot(@PathVariable long id,@RequestBody Snapshot in){return AjaxResult.success((Object)s.snapshot(id,in.opinion()));}
 @GetMapping("/price-tasks") public AjaxResult priceTasks(){return AjaxResult.success(s.safe(s.priceTasks()));}
 @Log(title="任务单位报价",businessType=BusinessType.UPDATE) @PutMapping("/prices/{id}") public AjaxResult price(@PathVariable long id,@RequestBody StatisticsService.Price in){s.price(id,in);return AjaxResult.success();}
}
