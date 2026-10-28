package com.ruoyi.web.biz;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.*;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.enums.BusinessType;
@RestController @RequestMapping("/onboarding")
public class CompanyOnboardingController {
 final CompanyOnboardingService service;
 public CompanyOnboardingController(CompanyOnboardingService s){service=s;}
 @GetMapping("/applications") public AjaxResult list(@RequestParam(defaultValue="false") boolean review){return AjaxResult.success(service.list(review));}
 @GetMapping("/applications/{id}") public AjaxResult detail(@PathVariable long id){return AjaxResult.success(service.detail(id));}
 @Log(title="企业申请",businessType=BusinessType.INSERT) @PostMapping("/applications") public AjaxResult add(@RequestBody CompanyApplication a){return AjaxResult.success((Object)service.save(null,a));}
 @Log(title="企业申请修改",businessType=BusinessType.UPDATE) @PutMapping("/applications/{id}") public AjaxResult update(@PathVariable long id,@RequestBody CompanyApplication a){return AjaxResult.success((Object)service.save(id,a));}
 @Log(title="提交入驻",businessType=BusinessType.UPDATE) @PostMapping("/applications/{id}/submit") public AjaxResult submit(@PathVariable long id){service.submit(id);return AjaxResult.success();}
 public record Decision(boolean approve,String opinion){}
 @Log(title="入驻审核",businessType=BusinessType.UPDATE) @PostMapping("/applications/{id}/review") public AjaxResult review(@PathVariable long id,@RequestBody Decision d){service.review(id,d.approve(),d.opinion());return AjaxResult.success();}
 @GetMapping("/companies") public AjaxResult companies(){return AjaxResult.success(service.companies());}
 @Log(title="企业资料维护",businessType=BusinessType.UPDATE) @PutMapping("/companies/{id}") public AjaxResult company(@PathVariable long id,@RequestBody CompanyApplication a){service.updateCompany(id,a);return AjaxResult.success();}
 @PostMapping("/licenses") public AjaxResult upload(@RequestParam MultipartFile file) throws java.io.IOException{return AjaxResult.success((Object)service.license(file.getBytes(),file.getContentType()));}
 @GetMapping("/licenses/{id}") public ResponseEntity<byte[]> download(@PathVariable long id){var file=service.download(id);return ResponseEntity.ok().contentType(MediaType.APPLICATION_OCTET_STREAM).header("X-Content-Type-Options","nosniff").header("Content-Disposition","attachment; filename=license").body((byte[])file.get("file_data"));}
}
