IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeProfessionLicences')
    BEGIN
	    DROP  Procedure  rpc_UpdateEmployeeProfessionLicences
    END
GO

CREATE Procedure [dbo].[rpc_UpdateEmployeeProfessionLicences]
(
	@EmployeeProfessionLicences as EmployeeProfessionLicences READONLY,
	@numOfRowsAffected INT OUTPUT	
)

AS


UPDATE Employee
SET ProfessionalLicenseNumber = E.ProfessionalLicenseNumber
FROM Employee
JOIN @EmployeeProfessionLicences E ON Employee.employeeID = E.employeeID

SET @numOfRowsAffected = @@ROWCOUNT

GO


GRANT EXEC ON dbo.rpc_UpdateEmployeeProfessionLicences TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_UpdateEmployeeProfessionLicences TO [clalit\IntranetDev]
GO