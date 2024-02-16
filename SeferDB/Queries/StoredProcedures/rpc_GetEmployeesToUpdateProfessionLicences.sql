IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeesToUpdateProfessionLicences')
	BEGIN
		DROP  Procedure  dbo.rpc_GetEmployeesToUpdateProfessionLicences
	END

GO

CREATE Procedure [dbo].[rpc_GetEmployeesToUpdateProfessionLicences]


AS

SELECT DISTINCT Employee.employeeID, ProfessionalLicenseNumber
FROM Employee
JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
JOIN x_Dept_Employee xde ON Employee.employeeID = xde.employeeID
WHERE Employee.active = 1
AND Employee.IsMedicalTeam = 0
AND Employee.IsVirtualDoctor = 0
AND EmployeeSector.IsDoctor = 0
AND ProfessionalLicenseNumber is null
AND xde.active = 1
ORDER BY Employee.employeeID


GO

GRANT EXEC ON dbo.rpc_GetEmployeesToUpdateProfessionLicences TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetEmployeesToUpdateProfessionLicences TO [clalit\IntranetDev]
GO
