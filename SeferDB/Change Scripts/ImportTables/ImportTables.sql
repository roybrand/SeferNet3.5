 -----------------import statement  - run after schema changes!
 ------------------------------------WHOLE TABLE list
--delete DIC_MessageInfo
--delete DIC_MessageCategory
--delete MessageInfoApplicationLanguage
--delete ApplicationLanguage
--delete TemplateFieldsMapping
--delete TemplateFieldsContainer
--delete CacheTablesRefreshingSP
--delete CachedTables
--delete DIC_ReceptionDays

 --EnumGenerate
 --EnumTableColumnGenerate

-- סדר יבוא
select * from EnumGenerate
select * from EnumTableColumnGenerate
select * from CachedTables
select * from DIC_MessageCategory
select * from DIC_ReceptionDays
select * from ApplicationLanguage
select * from TemplateFieldsMapping 
select * from TemplateFieldsContainer
---------------------------
select * from DIC_MessageInfo
select * from CacheTablesRefreshingSP
---------------------------
select * from MessageInfoApplicationLanguage

--UnitType -- we just need to import the column -> EnumName



 ------------------------------------specific columns in table list

 -- languages להעתיק את טבלת 
 