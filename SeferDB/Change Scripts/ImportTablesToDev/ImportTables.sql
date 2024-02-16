 -----------------import statement  - run after schema changes!

 --PART 1
 ------------------ structure of tables that should be only in DEV

  ------------------------------EnumGenerate------------------
 
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EnumGenerate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EnumGenerate](
	[EnumGenerateId] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[CodeColumnName] [varchar](50) NOT NULL,
	[EnumColumnName] [varchar](50) NOT NULL,
	[ColumnNameToFilterBy] [varchar](50) NULL,
	[ValueToFilterBy] [int] NULL,
	[ExpressionToFilter] [varchar](20) NULL,
	[EnumGeneratedName] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EnumGenerateId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO


-------------------------------------EnumTableColumnGenerate

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EnumTableColumnGenerate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EnumTableColumnGenerate](
	[EnumTableColumnGenerateId] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](200) NOT NULL,
 CONSTRAINT [PK_EnumColumnGenerate] PRIMARY KEY CLUSTERED 
(
	[EnumTableColumnGenerateId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[EnumTableColumnGenerate]') AND name = N'ix_EnumTableColumnGenerate__TableName  ')
CREATE UNIQUE NONCLUSTERED INDEX [ix_EnumTableColumnGenerate__TableName  ] ON [dbo].[EnumTableColumnGenerate] 
(
	[TableName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

------------------------------ import their data!!!


 --PART 2
 ------------------------------------WHOLE TABLE list
 --this script is for transferring data and possibly columns back to the dev after the dev DB is replaced in the production DB
 -- because some data exist only in the DEV and not in PROD so we have to recreate it in these scenario 

 --DIC_MessageCategory
 --DIC_MessageInfo

 --MessageInfoApplicationLanguage
 --ApplicationLanguage
  --TemplateFieldsMapping
 --TemplateFieldsContainer


 --CachedTables
 --CacheTablesRefreshingSP

 --ApplicationLanguage	
 --DIC_DeptTypes	
 --UnitType	
 --EmployeeSector	
 --DIC_ReceptionDays	



declare @dbSrc varchar(128) = 'SNDevOld'
declare @dbDest varchar(128) = 'SeferNet'
declare @sql nvarchar(max)
-----UnitType

set @sql = '
update dst set dst.EnumName = src.EnumName
  from ' + @dbDest+ '.dbo.UnitType dst inner join
' + @dbSrc+ '.dbo.UnitType src on dst.UnitTypeCode = src.UnitTypeCode

------CachedTables

update dst set dst.TableName = src.TableName
  from ' + @dbDest+ '.dbo.CachedTables dst inner join
' + @dbSrc+ '.dbo.CachedTables src on dst.TableCode = src.TableCode

------ApplicationLanguage

update dst set dst.EnumName = src.EnumName
  from ' + @dbDest+ '.dbo.ApplicationLanguage dst inner join
' + @dbSrc+ '.dbo.ApplicationLanguage src on dst.ApplicationLanguageId = src.ApplicationLanguageId

------DIC_DeptTypes

update dst set dst.EnumName = src.EnumName
  from ' + @dbDest+ '.dbo.DIC_DeptTypes dst inner join
' + @dbSrc+ '.dbo.DIC_DeptTypes src on dst.deptType = src.deptType

-------EmployeeSector

update dst set dst.EnumName = src.EnumName
  from ' + @dbDest+ '.dbo.EmployeeSector dst inner join
' + @dbSrc+ '.dbo.EmployeeSector src on dst.EmployeeSectorCode = src.EmployeeSectorCode

------TemplateFieldsContainer

update dst set dst.TemplateFieldsContainerName = src.TemplateFieldsContainerName
  from ' + @dbDest+ '.dbo.TemplateFieldsContainer dst inner join
' + @dbSrc+ '.dbo.TemplateFieldsContainer src on dst.TemplateFieldsContainerId = src.TemplateFieldsContainerId

--------DIC_ReceptionDays

update dst set dst.EnumName = src.EnumName
  from ' + @dbDest+ '.dbo.DIC_ReceptionDays dst inner join
' + @dbSrc+ '.dbo.DIC_ReceptionDays src on dst.ReceptionDayCode = src.ReceptionDayCode

 ------------------------------------specific columns in table list
 '
 
 --print @sql
exec sp_executesql @sql