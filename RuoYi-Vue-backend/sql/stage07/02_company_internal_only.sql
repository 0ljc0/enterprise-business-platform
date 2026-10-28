-- Apply after confirming no cross-company company-origin signup records.
UPDATE biz_task SET audience='INTERNAL',max_companies=1,version=version+1 WHERE publisher_type='COMPANY' AND (audience<>'INTERNAL' OR max_companies<>1);
ALTER TABLE biz_task ADD CONSTRAINT ck_company_internal_only CHECK(publisher_type<>'COMPANY' OR (audience='INTERNAL' AND max_companies=1));
