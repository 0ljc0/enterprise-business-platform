package com.ruoyi.web.biz;
import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
@Component @EnableScheduling
public class DailyReportScheduler {
 final DailyReportService reports;public DailyReportScheduler(DailyReportService r){reports=r;}
 @Scheduled(fixedDelayString="${business.reporting.check-delay-ms:600000}",initialDelayString="${business.reporting.initial-delay-ms:15000}")
 public void check(){reports.checkAll();}
}
