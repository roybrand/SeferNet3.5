IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DIC_GeneralRemarks]') 
         AND name = 'UpdateDate'
)
	ALTER table DIC_GeneralRemarks
	ADD UpdateDate datetime null
GO


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DIC_GeneralRemarks]') 
         AND name = 'UpdateUser'
)
	ALTER table DIC_GeneralRemarks
	ADD UpdateUser varchar(50) null
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[DIC_GeneralRemarks]') 
         AND name = 'Factor'
)
	ALTER table DIC_GeneralRemarks
	ADD Factor float null
GO

-- NEW TABLE
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = 'WeeklyHoursFactors')
	BEGIN
		DROP TABLE  WeeklyHoursFactors
	END

GO

CREATE TABLE [dbo].[WeeklyHoursFactors](
	[FactorValue] [float] NOT NULL,
	[FactorDescription] [varchar](50) NOT NULL
) ON [PRIMARY]
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Dept]') 
         AND name = 'ParentClinic'
)
	ALTER table Dept
	ADD ParentClinic int null
GO