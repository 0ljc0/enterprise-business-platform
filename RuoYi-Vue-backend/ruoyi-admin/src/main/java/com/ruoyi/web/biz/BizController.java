package com.ruoyi.web.biz;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController
@RequestMapping("/biz")
public class BizController {
 private final BizService service;
 public BizController(BizService service){this.service=service;}
 @GetMapping("/{module}/list") public AjaxResult list(@PathVariable String module,@RequestParam(required=false) Long companyId,@RequestParam(defaultValue="1") int pageNum,@RequestParam(defaultValue="20") int pageSize){return AjaxResult.success(service.list(module,companyId,pageNum,pageSize));}
 @GetMapping("/{module}/{id}") public AjaxResult detail(@PathVariable String module,@PathVariable long id){return AjaxResult.success(service.detail(module,id));}
 @Log(title="企业业务填报",businessType=BusinessType.INSERT)
 @PostMapping("/daily_output") public AjaxResult add(@RequestBody BizService.OutputInput input){service.add(input);return AjaxResult.success();}
 @Log(title="企业业务填报",businessType=BusinessType.UPDATE)
 @PutMapping("/daily_output/{id}") public AjaxResult edit(@PathVariable long id,@RequestBody BizService.OutputInput input){service.edit(id,input);return AjaxResult.success();}
}
