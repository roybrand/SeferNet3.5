-- =============================================
-- Schema Changes
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '[Services]' AND COLUMN_NAME = 'SectorToShowWith')
	BEGIN
		ALTER table [Services]
		ADD SectorToShowWith int
	END
GO

UPDATE [Services]
SET SectorToShowWith = 
	(SELECT TOP 1 x_Services_EmployeeSector.EmployeeSectorCode 
	FROM x_Services_EmployeeSector
	JOIN EmployeeSector ON x_Services_EmployeeSector.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
	WHERE x_Services_EmployeeSector.ServiceCode = [Services].ServiceCode
	ORDER BY EmployeeSector.IsDoctor DESC)
-- =============================================

IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'TempOldRecptionID' AND TABLE_NAME = 'deptEmployeeReceptionServices')
BEGIN
	ALTER TABLE deptEmployeeReceptionServices ADD TempOldRecptionID int
END
GO
ALTER TABLE x_Dept_Employee_Service
ADD UNIQUE (x_Dept_Employee_ServiceID)
GO

IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IsCommunity' AND TABLE_NAME = 'DIC_SubUnitTypes')
BEGIN
alter table DIC_SubUnitTypes add  [IsCommunity] [int] NULL
alter table DIC_SubUnitTypes add  [IsMushlam] [int] NULL
alter table DIC_SubUnitTypes add  [IsHospitals] [int] NULL
END
GO

update DIC_SubUnitTypes set IsCommunity=1,IsMushlam=0, IsHospitals=0 where subUnitTypeCode=0
update DIC_SubUnitTypes set IsCommunity=1,IsMushlam=0, IsHospitals=0 where subUnitTypeCode=1
update DIC_SubUnitTypes set IsCommunity=1,IsMushlam=0, IsHospitals=0 where subUnitTypeCode=2
update DIC_SubUnitTypes set IsCommunity=1,IsMushlam=0, IsHospitals=0 where subUnitTypeCode=3
update DIC_SubUnitTypes set IsCommunity=0,IsMushlam=1, IsHospitals=0 where subUnitTypeCode=4

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeServiceQueueOrderMethod]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[EmployeeServiceQueueOrderMethod](
	[EmployeeServiceQueueOrderMethodID] [int] IDENTITY(1,1) NOT NULL,
	[QueueOrderMethod] [int] NOT NULL,
	[deptCode] [int] NOT NULL,
	[serviceCode] [int] NOT NULL,
	[employeeID] [bigint] NOT NULL,
	[updateDate] [smalldatetime] NOT NULL,
	[updateUser] [varchar](50) NOT NULL,
	[QueueOrderMethodID_v] [int] NULL,
 CONSTRAINT [PK_EmployeeServiceQueueOrderMethod] PRIMARY KEY CLUSTERED 
(
	[EmployeeServiceQueueOrderMethodID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_DIC_QueueOrderMethod] FOREIGN KEY([QueueOrderMethod])
REFERENCES [dbo].[DIC_QueueOrderMethod] ([QueueOrderMethod])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_DIC_QueueOrderMethod]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service] FOREIGN KEY([deptCode], [employeeID], [serviceCode])
REFERENCES [dbo].[x_Dept_Employee_Service] ([deptCode], [employeeID], [serviceCode])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] ADD  CONSTRAINT [DF_EmployeeServiceQueueOrderMethod_updateDate]  DEFAULT (getdate()) FOR [updateDate]
END
GO

--*******************************************************************************

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeServiceQueueOrderHours]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[EmployeeServiceQueueOrderHours](
	[EmployeeServiceQueueOrderHoursID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeServiceQueueOrderMethodID] [int] NOT NULL,
	[ReceptionDay] [int] NOT NULL,
	[FromHour] [varchar](5) NOT NULL,
	[ToHour] [varchar](5) NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateUser] [varchar](50) NOT NULL,
 CONSTRAINT [PK_EmployeeServiceQueueOrderHours] PRIMARY KEY CLUSTERED 
(
	[EmployeeServiceQueueOrderHoursID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderHours]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderHours_DIC_ReceptionDays] FOREIGN KEY([ReceptionDay])
REFERENCES [dbo].[DIC_ReceptionDays] ([ReceptionDayCode])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServiceQueueOrderHours] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderHours_DIC_ReceptionDays]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderHours]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderHours_EmployeeServiceQueueOrderMethod] FOREIGN KEY([EmployeeServiceQueueOrderMethodID])
REFERENCES [dbo].[EmployeeServiceQueueOrderMethod] ([EmployeeServiceQueueOrderMethodID])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServiceQueueOrderHours] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderHours_EmployeeServiceQueueOrderMethod]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderHours] ADD  CONSTRAINT [DF_EmployeeServiceQueueOrderHours_UpdateDate]  DEFAULT (getdate()) FOR [UpdateDate]
END
GO
--***************************************************************************************************

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeServiceQueueOrderPhones]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[EmployeeServiceQueueOrderPhones](
	[EmployeeServiceQueueOrderPhonesID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeServiceQueueOrderMethodID] [int] NOT NULL,
	[phoneType] [int] NOT NULL,
	[phoneOrder] [int] NOT NULL,
	[prePrefix] [tinyint] NULL,
	[prefix] [int] NULL,
	[phone] [int] NOT NULL,
	[extension] [int] NULL,
	[updateDate] [smalldatetime] NOT NULL,
	[updateUser] [varchar](50) NOT NULL,
 CONSTRAINT [PK_EmployeeServiceQueueOrderPhones] PRIMARY KEY CLUSTERED 
(
	[EmployeeServiceQueueOrderMethodID] ASC,
	[phoneType] ASC,
	[phoneOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderPhones]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderPhones_DIC_PhonePrefix] FOREIGN KEY([prefix])
REFERENCES [dbo].[DIC_PhonePrefix] ([prefixCode])

ALTER TABLE [dbo].[EmployeeServiceQueueOrderPhones] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderPhones_DIC_PhonePrefix]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderPhones]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderPhones_EmployeeServiceQueueOrderMethod] FOREIGN KEY([EmployeeServiceQueueOrderMethodID])
REFERENCES [dbo].[EmployeeServiceQueueOrderMethod] ([EmployeeServiceQueueOrderMethodID])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServiceQueueOrderPhones] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderPhones_EmployeeServiceQueueOrderMethod]

ALTER TABLE [dbo].[EmployeeServiceQueueOrderPhones] ADD  CONSTRAINT [DF_EmployeeServiceQueueOrderPhones_updateDate]  DEFAULT (getdate()) FOR [updateDate]
END
GO
--**********************************************************************************************************************

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeServicePhones]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[EmployeeServicePhones](
	[EmployeeServicePhonesID] [int] IDENTITY(1,1) NOT NULL,
	[x_Dept_Employee_ServiceID] [int] NOT NULL,
	[phoneType] [int] NOT NULL,
	[phoneOrder] [int] NOT NULL,
	[prePrefix] [tinyint] NULL,
	[prefix] [int] NULL,
	[phone] [int] NULL,
	[extension] [int] NULL,
	[updateDate] [smalldatetime] NOT NULL,
	[updateUser] [varchar](50) NOT NULL,
 CONSTRAINT [PK_EmployeeServicePhones] PRIMARY KEY CLUSTERED 
(
	[x_Dept_Employee_ServiceID] ASC,
	[phoneType] ASC,
	[phoneOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EmployeeServicePhones]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServicePhones_DIC_PhonePrefix] FOREIGN KEY([prefix])
REFERENCES [dbo].[DIC_PhonePrefix] ([prefixCode])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServicePhones] CHECK CONSTRAINT [FK_EmployeeServicePhones_DIC_PhonePrefix]

ALTER TABLE [dbo].[EmployeeServicePhones]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServicePhones_x_Dept_Employee_Service] FOREIGN KEY([x_Dept_Employee_ServiceID])
REFERENCES [dbo].[x_Dept_Employee_Service] ([x_Dept_Employee_ServiceID])
ON DELETE CASCADE

ALTER TABLE [dbo].[EmployeeServicePhones] CHECK CONSTRAINT [FK_EmployeeServicePhones_x_Dept_Employee_Service]

ALTER TABLE [dbo].[EmployeeServicePhones] ADD  CONSTRAINT [DF_EmployeeServicePhones_updateDate]  DEFAULT (getdate()) FOR [updateDate]
END
GO


IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = 'DIC_OrganizationSector')
	BEGIN
		
		CREATE TABLE [dbo].[DIC_OrganizationSector](
			[OrganizationSectorID] [tinyint] NOT NULL,
			[OrganizationDescription] [varchar](50) NOT NULL,
		 CONSTRAINT [PK_DIC_OrganizationSector] PRIMARY KEY CLUSTERED 
		(
			[OrganizationSectorID] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
		) ON [PRIMARY]
		
	END

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'OrganizationSectorID' AND TABLE_NAME = 'DIC_AgreementTypes')
BEGIN
alter table DIC_AgreementTypes add  [OrganizationSectorID] [tinyint] NULL
alter table DIC_AgreementTypes add  [IsDefault] [bit] NULL

END
GO

-- **** AND *******************************************************************************

if not exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnumName' AND TABLE_NAME = 'DIC_DeptTypes')
begin 
alter table DIC_DeptTypes add EnumName varchar(100)
end


if not exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnumName' AND TABLE_NAME = 'UnitType')
begin 
alter table UnitType add EnumName varchar(100)
end


if not exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnumName' AND TABLE_NAME = 'EmployeeSector')
begin 
alter table EmployeeSector add EnumName varchar(100)
end

if not exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnumName' AND TABLE_NAME = 'DIC_ReceptionDays')
begin 
alter table DIC_ReceptionDays add EnumName varchar(100)
end

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
---*********************************

--******* YANIV - NEW VIEW ********************

--****** YANIV *******************
-- Add new column to DIC_ReceptionDays

IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Display' AND TABLE_NAME = 'DIC_ReceptionDays')
BEGIN
alter table DIC_ReceptionDays add  [Display] [tinyint] NULL
ALTER TABLE [dbo].[DIC_ReceptionDays] ADD  CONSTRAINT [DF_DIC_ReceptionDays_Display]  DEFAULT ((1)) FOR [Display]
END
GO
--*******************************************

--***** YANIV - NEW VIEW ****************************

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vReceptionDaysForDisplay')
	BEGIN
		DROP  view  vReceptionDaysForDisplay
	END

GO

CREATE VIEW [dbo].[vReceptionDaysForDisplay]
AS
SELECT     ReceptionDayCode, ReceptionDayName, UseInSearch, Display
FROM         dbo.DIC_ReceptionDays
WHERE     (Display = 1)


GO

grant select on vReceptionDaysForDisplay to public 
go


-- **** AND YANIV NEW VIEW *******************************************************************************

--********* YANIV - Add new column to DIC_ActivityStatus and values *********************

IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnumName' AND TABLE_NAME = 'DIC_ActivityStatus')
BEGIN
alter table DIC_ActivityStatus add  [EnumName] varchar(50) NULL

END
GO
update DIC_ActivityStatus set EnumName = 'NotActive' where [status] = 0
update DIC_ActivityStatus set EnumName = 'Active' where [status] = 1
update DIC_ActivityStatus set EnumName = 'TemporaryNotActive' where [status] = 2


--*****************************************************************************************

-- New columns for "DIC_SubUnitTypes"
IF NOT Exists(select * from sys.columns where Name = N'IsCommunity'  
            and Object_ID = Object_ID(N'DIC_SubUnitTypes'))
BEGIN
	ALTER table DIC_SubUnitTypes
	ADD IsCommunity int 
END

IF NOT Exists(select * from sys.columns where Name = N'IsMushlam'  
            and Object_ID = Object_ID(N'DIC_SubUnitTypes'))
BEGIN
	ALTER table DIC_SubUnitTypes
	ADD IsMushlam int 
END

IF NOT Exists(select * from sys.columns where Name = N'IsHospitals'  
            and Object_ID = Object_ID(N'DIC_SubUnitTypes'))
BEGIN
	ALTER table DIC_SubUnitTypes
	ADD IsHospitals int 
END

UPDATE DIC_SubUnitTypes
SET IsCommunity = 1, IsMushlam = 0, IsHospitals = 0
WHERE subUnitTypeCode IN (0,1,2,3)

UPDATE DIC_SubUnitTypes
SET IsCommunity = 0, IsMushlam = 1, IsHospitals = 0
WHERE subUnitTypeCode IN (4)



--************** [View_SubUnitTypes]   **************************************
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_SubUnitTypes]'))
DROP VIEW [dbo].[View_SubUnitTypes]
GO

CREATE VIEW [dbo].[View_SubUnitTypes]
AS
SELECT  TOP (100) PERCENT dbo.subUnitType.subUnitTypeCode, dbo.subUnitType.UnitTypeCode, dbo.DIC_SubUnitTypes.subUnitTypeName,
			dbo.DIC_SubUnitTypes.IsCommunity, dbo.DIC_SubUnitTypes.IsMushlam, dbo.DIC_SubUnitTypes.IsHospitals
FROM    dbo.subUnitType 
INNER JOIN dbo.DIC_SubUnitTypes ON dbo.subUnitType.subUnitTypeCode = dbo.DIC_SubUnitTypes.subUnitTypeCode
ORDER BY dbo.subUnitType.UnitTypeCode, dbo.DIC_SubUnitTypes.subUnitTypeName

GO

grant select on View_SubUnitTypes to public 
GO

--************** YANIV - New function rfn_GetFotmatedRemark **********************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_GetFotmatedRemark]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_GetFotmatedRemark]
GO



CREATE function [dbo].[rfn_GetFotmatedRemark](@s varchar(max))
returns varchar(max)
AS
BEGIN

declare @d varchar(max)
set @d = '' 

	Select 
	@d = @d + ' ' + c.t
	from 
	(
	select CHARINDEX('~', b.itemid, 1) as pod , LEN(b.itemid) as l, 
	case 
				when CHARINDEX('~', b.itemid, 1) > 0  then Substring(b.itemid, 1, CHARINDEX('~', b.itemid, 1)-1)
				else b.itemid
		  end  as t 
	from(
	SELECT   a.*
	FROM dbo.rfn_SplitStringByDelimiterValuesToStr(@s, '#') as a
	)  as b 
	) as c  
	
	return @d 
end 


GO


GRANT EXEC ON rfn_GetFotmatedRemark TO PUBLIC
GO


--************* END rfn_GetFotmatedRemark *********************----------------
--******** YANIV -  Chenges at View_DeptEmployee_EmployeeRemarks ********************


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployee_EmployeeRemarks]'))
DROP VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
GO



CREATE VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
AS
 
SELECT 
x_D_E_ER.DeptCode as DeptCode,
x_D_E_ER.EmployeeID,
x_D_E_ER.DeptCode as EmpRemarkDeptCode,
EmployeeRemarks.EmployeeRemarkID,
EmployeeRemarks.DicRemarkID,
EmployeeRemarks.AttributedToAllClinicsInCommunity,
EmployeeRemarks.AttributedToAllClinicsInMushlam,
EmployeeRemarks.AttributedToAllClinicsInHospitals,
EmployeeRemarks.RemarkText as RemarkText,
dbo.rfn_GetFotmatedRemark(EmployeeRemarks.RemarkText) as RemarkTextFormated,
EmployeeRemarks.displayInInternet,
EmployeeRemarks.ValidFrom,
EmployeeRemarks.ValidTo


FROM x_Dept_Employee_EmployeeRemarks as x_D_E_ER
INNER JOIN EmployeeRemarks ON x_D_E_ER.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
--WHERE x_D_E_ER.DeptCode = @DeptCode




UNION

SELECT
Dept.deptCode as DeptCode,
EmployeeRemarks.EmployeeID,
0 as EmpRemarkDeptCode,
EmployeeRemarks.EmployeeRemarkID,
EmployeeRemarks.DicRemarkID,
EmployeeRemarks.AttributedToAllClinicsInCommunity,
EmployeeRemarks.AttributedToAllClinicsInMushlam,
EmployeeRemarks.AttributedToAllClinicsInHospitals,
EmployeeRemarks.RemarkText as RemarkText,
dbo.rfn_GetFotmatedRemark(EmployeeRemarks.RemarkText)  as RemarkTextFormated,
EmployeeRemarks.displayInInternet,
EmployeeRemarks.ValidFrom,
EmployeeRemarks.ValidTo

FROM EmployeeRemarks 
join x_Dept_Employee as x_D_E on EmployeeRemarks.EmployeeID = x_D_E.employeeID
join Dept on Dept.deptCode = x_D_E.DeptCode
	and (
		(EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 and Dept.IsCommunity = 1)  
	or (EmployeeRemarks.AttributedToAllClinicsInMushlam = 1 and Dept.IsMushlam = 1)
	or (EmployeeRemarks.AttributedToAllClinicsInHospitals = 1 and Dept.IsHospital = 1)
	)
--WHERE Dept.DeptCode = @DeptCode




GO

grant select on View_DeptEmployee_EmployeeRemarks to public 
go


--**************** END View_DeptEmployee_EmployeeRemarks **************************




--************* YANIV - New function rfn_SplitStringByDelimiterValuesToStr *******************



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_SplitStringByDelimiterValuesToStr]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_SplitStringByDelimiterValuesToStr]
GO


--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION [dbo].[rfn_SplitStringByDelimiterValuesToStr]
(
	@ItemList varchar(max), 
	@Delimiter varchar(10)
)
RETURNS 
@ParsedList table
(
	ItemID varchar(4000)
)
AS
BEGIN
	DECLARE @ItemID varchar(4000), @Pos int

	SET @ItemList = LTRIM(RTRIM(@ItemList))+ @Delimiter
	SET @Pos = CHARINDEX(@Delimiter, @ItemList, 1)

	IF REPLACE(@ItemList, @Delimiter, '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @ItemID = LTRIM(RTRIM(LEFT(@ItemList, @Pos-1)))
			IF @ItemID <> ''
			BEGIN
				INSERT INTO @ParsedList (ItemID) 
				VALUES (@ItemID ) --Use Appropriate conversion
			END
			SET @ItemList = RIGHT(@ItemList, LEN(@ItemList) - @Pos)
			SET @Pos = CHARINDEX(@Delimiter, @ItemList, 1)

		END
	END	
	RETURN
END


GO

grant select on rfn_SplitStringByDelimiterValuesToStr to public 
go

--****************** END rfn_SplitStringByDelimiterValuesToStr ************************



-- ********************************************************************************************************************

ALTER TABLE x_dept_employee
ALTER COLUMN updateUserName VARCHAR(100)

-- ********************************************************************************************************************

IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = 'ServiceSynonym')
BEGIN

	CREATE TABLE [dbo].[ServiceSynonym](
		[SynonymID] [int] IDENTITY(1,1) NOT NULL,
		[ServiceCode] [int] NOT NULL,
		[ServiceSynonym] [varchar](100) NOT NULL,
		[UpdateDate] [datetime] NULL,
		[UpdateUser] [varchar](100) NULL,
	 CONSTRAINT [PK_ServiceSynonym] PRIMARY KEY CLUSTERED 
	(
		[SynonymID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]



	ALTER TABLE [dbo].[ServiceSynonym]  WITH CHECK ADD  CONSTRAINT [FK_ServiceSynonym_Services] FOREIGN KEY([ServiceCode])
	REFERENCES [dbo].[Services] ([ServiceCode])
	ON DELETE CASCADE

	ALTER TABLE [dbo].[ServiceSynonym] CHECK CONSTRAINT [FK_ServiceSynonym_Services]

END

GO

-- ********************************************************************************************************************

-- New permissions handling
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = 'MainMenuItemsPermissions')
BEGIN

CREATE TABLE [dbo].[MainMenuItemsPermissions](
[MenuPermissionID] [int] IDENTITY(1,1) NOT NULL,
[MenuItemID] [int] NOT NULL,
[RoleID] [int] NOT NULL,
CONSTRAINT [PK_MenuItemsPermissions] PRIMARY KEY CLUSTERED 
(
[MenuPermissionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

	ALTER TABLE [dbo].[MainMenuItemsPermissions]  WITH CHECK ADD  CONSTRAINT [FK_MenuItemsPermissions_MainMenuItems] FOREIGN KEY([MenuItemID])
	REFERENCES [dbo].[MainMenuItems] ([ItemID])


	ALTER TABLE [dbo].[MainMenuItemsPermissions] CHECK CONSTRAINT [FK_MenuItemsPermissions_MainMenuItems]

	ALTER TABLE [dbo].[MainMenuItemsPermissions]  WITH CHECK ADD  CONSTRAINT [FK_MenuItemsPermissions_PermissionTypes] FOREIGN KEY([RoleID])
	REFERENCES [dbo].[PermissionTypes] ([permissionCode])
	ON DELETE CASCADE

	ALTER TABLE [dbo].[MainMenuItemsPermissions] CHECK CONSTRAINT [FK_MenuItemsPermissions_PermissionTypes]

END
GO
-- *******************************************************************************************************************

ALTER TABLE PermissionTypes
ALTER COLUMN permissionDescription VARCHAR(50)
go
-- *********************

IF NOT EXISTS (SELECT * FROM PermissionTypes WHERE permissionCode = 0 AND permissionDescription = 'פתוח לכולם')
	INSERT INTO PermissionTypes
	VALUES (0,'פתוח לכולם',null,null)
go

IF NOT EXISTS (SELECT * FROM PermissionTypes WHERE permissionCode = 6 AND permissionDescription = 'הפקת דוחות')
	INSERT INTO PermissionTypes
	VALUES (6,'הפקת דוחות',null,null)
go

if exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Roles' AND TABLE_NAME = 'MainMenuItems')
BEGIN 
	INSERT INTO MainMenuItemsPermissions
	SELECT ItemID,Roles 
	FROM MainMenuItems

	-- apply all other permission's items to be administrator's items as well
	INSERT INTO MainMenuItemsPermissions
	SELECT MenuItemID, 5
	FROM MainMenuItemsPermissions
	WHERE RoleID <> 5 AND RoleID <> 0

	-- apply reports to the new "Reports Execution" permission
	INSERT INTO MainMenuItemsPermissions
	SELECT ItemID, 6 
	FROM MainMenuItems
	WHERE Url LIKE '%/Reports%'
END
go

if exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Roles' AND TABLE_NAME = 'MainMenuItems')
begin 
	ALTER TABLE MainMenuItems
	DROP COLUMN Roles
end

go

 
--********************************************************************************************************************
--**** YANIV - New function rfn_AddInputTypeToRemark ******************************


--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_AddInputTypeToRemark]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_AddInputTypeToRemark]
GO


CREATE function [dbo].[rfn_AddInputTypeToRemark]
(
	@ItemList varchar(max)

)
returns varchar(max) 

AS
BEGIN
	
	declare @res varchar(max)
	declare @length int
	declare @lastChar varchar(1)
	
	
	set @res = replace(@ItemList,'# ','~10# ')
	
	
	set @length = len(@res)
	set @lastChar = substring(@res,@length,1)
	if @lastChar = '#'
	begin
		set @res = substring(@res,0,@length ) + '~10#'
	end
	
	
	RETURN @res
END

GO

GRANT EXEC ON rfn_AddInputTypeToRemark TO PUBLIC
GO






--**** AND rfn_AddInputTypeToRemark ***********************************************


--**** YANIV - New table - DIC_DeptCategory ***********************************

IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = 'DIC_DeptCategory')
	BEGIN
	CREATE TABLE [dbo].[DIC_DeptCategory](
		[CategoryID] [tinyint] NOT NULL,
		[CategoryName] [varchar](50) NOT NULL
	) ON [PRIMARY]

	
END

GO


grant select on DIC_DeptCategory to public 
go

--**** END - DIC_DeptCategory ***********************************

--**** YANIV - Add new column to UnitType ***************

if NOT exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'CategoryID' AND TABLE_NAME = 'UnitType')
BEGIN 
	alter table dbo.UnitType add [CategoryID] [tinyint] NOT NULL DEFAULT(1)
END
--**** END **********************************************


-- ************************************************************************************************ 
-- add mushlam services information table


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = 'MushlamServicesInformation')
BEGIN
	DROP TABLE MushlamServicesInformation
END

GO

CREATE TABLE [dbo].[MushlamServicesInformation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServiceCode] [int] NOT NULL,
	[MushlamServiceName] VARCHAR(200) NOT NULL,
	[ServiceSiteName] [varchar](5) NULL,
	[GroupCode] INT NULL,
	[SubGroupCode] INT NULL,
	[HasModels] [bit] NOT NULL,
	[ServiceType] INT, 
	[GivenByDoctor] [bit] NOT NULL,
	[GivenBySupplier] [bit] NOT NULL,
	[ClalitRefund] [varchar](200) NULL,
	[SelfParticipation] [varchar](200) NULL,
	[PrivateRemark] [varchar](1200) NULL,
	[AgreementRemark] [varchar](1200) NULL,
	[EligibilityRemark] [varchar](1200) NULL,
	[GeneralRemark] [varchar](1200) NULL,
	[FaxRemarkAgreement] [varchar](1200) NULL,
	[FaxRemarkPrivate] [varchar](1200) NULL,
	[FaxRemarkProvider] [varchar](1200) NULL,
	[HowServiceIsProvided] [varchar](1200) NULL,
	[TargetPopulation] [varchar](500) NULL,
	[RequiredDocuments] [varchar](500) NULL,
	[AdditionalDetails] [varchar](500) NULL,
	CONSTRAINT [PK_MushlamServicesInformation_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]



GO



ALTER TABLE [dbo].[MushlamServicesInformation]  WITH CHECK ADD  CONSTRAINT [FK_MushlamServicesInformation_Services] FOREIGN KEY([ServiceCode])
REFERENCES [dbo].[Services] ([ServiceCode])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[MushlamServicesInformation] CHECK CONSTRAINT [FK_MushlamServicesInformation_Services]
GO




-- ************************************************************************************************ 




--**** YANIV - Changes at table languages ********************
ALTER TABLE [dbo].[languages]
ALTER COLUMN updateUsername VARCHAR(50) NULL

--**** END - Changes at table languages ********************

-- SubUnitTypeSubstituteName *************************************************************************************************
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SubUnitTypeSubstituteName]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[SubUnitTypeSubstituteName](
		[SubUnitTypeCode] [int] NOT NULL,
		[UnitTypeCode] [int] NOT NULL,
		[SubstituteName] [varchar](100) NOT NULL,
		[UpdateDate] [smalldatetime] NOT NULL,
		[UpdateUser] [varchar](50) NOT NULL
	) ON [PRIMARY]

	ALTER TABLE [dbo].[SubUnitTypeSubstituteName] ADD  CONSTRAINT [DF_SubUnitTypeSubstituteName_UpdateDate]  DEFAULT (getdate()) FOR [UpdateDate]


	ALTER TABLE [dbo].[SubUnitTypeSubstituteName] ADD  CONSTRAINT [DF_SubUnitTypeSubstituteName_UpdateUser]  DEFAULT ('By script') FOR [UpdateUser]
END

GO

-- END SubUnitTypeSubstituteName *************************************************************************************************
 

 --  ****************************************************************************************

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamTreatmentTypesForService]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[MushlamTreatmentTypesForService](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServiceCode] [int] NOT NULL,
	[TreatmentTypeCode] [int] NOT NULL,
 CONSTRAINT [PK_MushlamTreatmentTypesForService] PRIMARY KEY CLUSTERED 
(
	[ServiceCode] ASC,
	[TreatmentTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]



ALTER TABLE [dbo].[MushlamTreatmentTypesForService]  WITH CHECK ADD  CONSTRAINT [FK_MushlamTreatmentTypesForService_MushlamTreatmentTypesToSefer] FOREIGN KEY([TreatmentTypeCode])
REFERENCES [dbo].[Services] ([ServiceCode])
ON DELETE CASCADE


ALTER TABLE [dbo].[MushlamTreatmentTypesForService] CHECK CONSTRAINT [FK_MushlamTreatmentTypesForService_MushlamTreatmentTypesToSefer]


END

 
 --  ****************************************************************************************

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ImportedFromMushlam' AND TABLE_NAME = 'x_dept_employee_service')
BEGIN 
ALTER TABLE x_dept_employee_service 
ADD ImportedFromMushlam BIT NOT NULL default(0)
END  

  
 --  ****************************************************************************************
 -- to enable mushlam different agreement types, add AgreementType as key also
 /*

SELECT * INTO #tempX
FROM x_dept_employee

GO

DROP TABLE x_dept_employee

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[x_Dept_Employee](
	[deptCode] [int] NOT NULL,
	[employeeID] [bigint] NOT NULL,
	[AgreementType] [tinyint] NOT NULL,
	[updateDate] [smalldatetime] NULL,
	[updateUserName] [varchar](50) NULL,
	[active] [tinyint] NULL,
	[CascadeUpdateDeptEmployeePhonesFromClinic] [tinyint] NULL,
	[QueueOrder] [int] NULL,
	[OldRecID] [int] NULL,
 CONSTRAINT [PK_x_Dept_Employee_1] PRIMARY KEY CLUSTERED 
(
	[deptCode] ASC,
	[employeeID] ASC,
	[AgreementType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[x_Dept_Employee]  WITH NOCHECK ADD  CONSTRAINT [FK_x_Dept_Employee_Dept] FOREIGN KEY([deptCode])
REFERENCES [dbo].[Dept] ([deptCode])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[x_Dept_Employee] CHECK CONSTRAINT [FK_x_Dept_Employee_Dept]
GO

ALTER TABLE [dbo].[x_Dept_Employee]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_Employee_DIC_AgreementTypes] FOREIGN KEY([AgreementType])
REFERENCES [dbo].[DIC_AgreementTypes] ([AgreementTypeID])
GO

ALTER TABLE [dbo].[x_Dept_Employee] CHECK CONSTRAINT [FK_x_Dept_Employee_DIC_AgreementTypes]
GO

ALTER TABLE [dbo].[x_Dept_Employee]  WITH NOCHECK ADD  CONSTRAINT [FK_x_Dept_Employee_Employee] FOREIGN KEY([employeeID])
REFERENCES [dbo].[Employee] ([employeeID])
GO

ALTER TABLE [dbo].[x_Dept_Employee] CHECK CONSTRAINT [FK_x_Dept_Employee_Employee]
GO

ALTER TABLE [dbo].[x_Dept_Employee] ADD  CONSTRAINT [DF_x_Dept_Employee_independent]  DEFAULT ((0)) FOR [AgreementType]
GO

ALTER TABLE [dbo].[x_Dept_Employee] ADD  CONSTRAINT [DF_x_Dept_Employee_updateDate]  DEFAULT (getdate()) FOR [updateDate]
GO

ALTER TABLE [dbo].[x_Dept_Employee] ADD  CONSTRAINT [DF_x_Dept_Employee_CascadeUpdateDeptEmployeePhonesFromClinic]  DEFAULT ((1)) FOR [CascadeUpdateDeptEmployeePhonesFromClinic]
GO


INSERT INTO x_Dept_Employee
SELECT * FROM #tempx


DROP TABLE #tempX

*/

-- ********************************************************************************************

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'deptEmployeeReception' AND COLUMN_NAME = 'receptionID_v')
	BEGIN
		ALTER table deptEmployeeReception
		ADD receptionID_v int
	END
GO

UPDATE deptEmployeeReception 
SET receptionID_v = 0
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EmployeeServiceQueueOrderMethod' AND COLUMN_NAME = 'QueueOrderMethodID_v')
	BEGIN
		ALTER table EmployeeServiceQueueOrderMethod
		ADD QueueOrderMethodID_v int
	END
GO

UPDATE EmployeeServiceQueueOrderMethod 
SET QueueOrderMethodID_v = 0
GO


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'x_Dept_Employee_Service' AND COLUMN_NAME = 'QueueOrder')
BEGIN
	ALTER TABLE x_Dept_Employee_Service
	ADD QueueOrder int
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'x_Dept_Employee_Service' AND COLUMN_NAME = 'CascadeUpdateEmployeeServicePhones')
BEGIN
	ALTER TABLE x_Dept_Employee_Service
	ADD CascadeUpdateEmployeeServicePhones tinyint
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EmployeeServices' AND COLUMN_NAME = 'mainProfession')
BEGIN
	ALTER TABLE EmployeeServices
	ADD mainProfession int
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EmployeeServices' AND COLUMN_NAME = 'expProfession')
BEGIN
	ALTER TABLE EmployeeServices
	ADD expProfession int
END
GO

UPDATE EmployeeServices SET mainProfession = 0, expProfession = 0

ALTER TABLE EmployeeServices
ALTER COLUMN expProfession int not null

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_EmployeeServices_expProfession]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeServices]'))
ALTER TABLE [dbo].[EmployeeServices] ADD  CONSTRAINT [DF_EmployeeServices_expProfession]  DEFAULT (0) FOR [expProfession]
GO

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_EmployeeServices_mainProfession]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeServices]'))
ALTER TABLE [dbo].[EmployeeServices] ADD  CONSTRAINT [DF_EmployeeServices_mainProfession]  DEFAULT (0) FOR [mainProfession]
GO
	
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_DeptEmployeeServiceStatus_UpdateDate]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
ALTER TABLE [dbo].[DeptEmployeeServiceStatus] ADD  CONSTRAINT [DF_DeptEmployeeServiceStatus_UpdateDate]  DEFAULT (getdate()) FOR [UpdateDate]
GO


--**** Yaniv - vEmployeeReceptionHours ***************************************

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmployeeReceptionHours]'))
DROP VIEW [dbo].[vEmployeeReceptionHours]
GO

create VIEW [dbo].[vEmployeeReceptionHours]
AS
SELECT     dER.deptCode, dER.receptionID, dER.EmployeeID, dER.receptionDay, dER.openingHour, dER.closingHour, 
                      dbo.DIC_ReceptionDays.ReceptionDayName, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                       ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_GetEmployeeRemarksForReception(dER.receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_GetEmployeeRemarksForReception(dER.receptionID) END AS OpeningHourText, 
                      dbo.Employee.EmployeeSectorCode,
                      S.ServiceDescription
FROM         dbo.deptEmployeeReception AS dER 
INNER JOIN dbo.DIC_ReceptionDays ON dER.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode 
INNER JOIN dbo.Employee ON dER.EmployeeID = dbo.Employee.employeeID
INNER JOIN x_Dept_Employee ON dER.employeeID = x_Dept_Employee.employeeID
			AND dER.deptCode = x_Dept_Employee.deptCode
			AND x_Dept_Employee.active <> 0
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
                      

GO


grant select on vEmployeeReceptionHours to public 
go

--**** End - vEmployeeReceptionHours ***************************************
/****** Object:  Table [dbo].[MushlamServicesToSefer] ******/
IF not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamServicesToSefer]') AND type in (N'U'))
begin

CREATE TABLE [dbo].[MushlamServicesToSefer](
	[GroupCode] [int] NULL,
	[SubGroupCode] [int] NULL,
	[ServiceName] [nvarchar](255) NULL,
	[SeferCode] [int] NULL
) ON [PRIMARY]
end

GO
---------------------------------------------------------------------
