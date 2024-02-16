-- DIC_GeneralRemarks
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DIC_GeneralRemarks]') 
         AND name = 'OpenNow'
)
BEGIN
	ALTER TABLE DIC_GeneralRemarks
	ADD OpenNow bit NULL
	CONSTRAINT [DF_DIC_GeneralRemarks_OpenNow]  DEFAULT  ((1)) 
		WITH VALUES;
	END
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DIC_GeneralRemarks]') 
         AND name = 'ShowForPreviousDays'
)
BEGIN
	ALTER TABLE DIC_GeneralRemarks
	ADD ShowForPreviousDays int NULL
	CONSTRAINT [DF_DIC_GeneralRemarks_ShowForPreviousDays]  DEFAULT  ((10)) 
		WITH VALUES;
END
GO

-- Add "ActiveFrom" field to all remark tables

-- DeptRemarks
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DeptRemarks]') 
         AND name = 'ActiveFrom'
)
BEGIN
	ALTER TABLE DeptRemarks
	ADD ActiveFrom DATETIME null
END

GO

-- EmployeeRemarks
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[EmployeeRemarks]') 
         AND name = 'ActiveFrom'
)
BEGIN
	ALTER TABLE EmployeeRemarks
	ADD ActiveFrom DATETIME null
END

GO

-- DeptEmployeeServiceRemarks
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceRemarks]') 
         AND name = 'ActiveFrom'
)
BEGIN
	ALTER TABLE DeptEmployeeServiceRemarks
	ADD ActiveFrom DATETIME null
END

GO

-- DeptReceptionRemarks
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DeptReceptionRemarks]') 
         AND name = 'ActiveFrom'
)
BEGIN
	ALTER TABLE DeptReceptionRemarks
	ADD ActiveFrom DATETIME null
END

GO