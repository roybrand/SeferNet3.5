IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetX_EmployeeSubSector_ProfLicenseType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_GetX_EmployeeSubSector_ProfLicenseType]
GO

CREATE Procedure [dbo].[rpc_GetX_EmployeeSubSector_ProfLicenseType]

AS

SELECT SubSectorCode, SubSectorDescription, ProfLicenceType
FROM x_EmployeeSubSector_ProfLicenceType
GO


GRANT EXEC ON dbo.rpc_GetX_EmployeeSubSector_ProfLicenseType TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetX_EmployeeSubSector_ProfLicenseType TO [clalit\IntranetDev]
GO