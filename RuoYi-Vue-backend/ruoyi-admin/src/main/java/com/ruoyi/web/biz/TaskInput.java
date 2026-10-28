package com.ruoyi.web.biz;
import java.math.BigDecimal;
import java.time.*;
public record TaskInput(String title,String description,BigDecimal targetQuantity,String unit,LocalDateTime signupDeadline,LocalDate startDate,LocalDate endDate,Integer maxCompanies,String audience,Integer version){}
