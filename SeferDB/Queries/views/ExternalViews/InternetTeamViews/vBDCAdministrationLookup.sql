-- =============================================
--	Select administrations
--	Owner : Internet Team
-- =============================================

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vBDCAdministrationLookup]'))
	DROP VIEW [dbo].[vBDCAdministrationLookup]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vBDCAdministrationLookup]
AS
	SELECT    TOP (100) PERCENT deptCode as AdministrationCode, deptName as AdministrationName
	FROM         dbo.Dept
	where typeUnitCode = 802
	ORDER BY AdministrationCode

GO


GRANT SELECT ON [dbo].[vBDCAdministrationLookup] TO [public] AS [dbo]
GO
