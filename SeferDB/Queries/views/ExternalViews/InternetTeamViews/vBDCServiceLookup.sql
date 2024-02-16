-- =============================================
--	Select services
--	Owner : Internet Team
-- =============================================

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vBDCServiceLookup]'))
	DROP VIEW [dbo].[vBDCServiceLookup]
GO

CREATE VIEW [dbo].[vBDCServiceLookup]
AS
	SELECT    TOP (100) PERCENT ServiceCode, ServiceDescription
	FROM         dbo.Services
	WHERE     (IsService = 1)
	order by ServiceCode

GO



GRANT SELECT ON [dbo].[vBDCServiceLookup] TO [public] AS [dbo]
GO
