
/****** Object:  View [dbo].[View_UnitType]    Script Date: 11/15/2010 16:33:04 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_UnitType]'))
DROP VIEW [dbo].[View_UnitType]
GO

/****** Object:  View [dbo].[View_UnitType]    Script Date: 11/15/2010 16:33:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_UnitType]
AS
SELECT     UnitTypeCode, UnitTypeName
FROM         dbo.UnitType
WHERE     (IsActive <> 0)

GO

