IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeProfessionLicence')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeProfessionLicence
	END

GO

CREATE Procedure [dbo].[rpc_UpdateEmployeeProfessionLicence]
	(
		@employeeID bigint,
		@ProfessionalLicenseNumber int,
		@updateUser varchar(50)
	)

AS

	
UPDATE Employee
SET ProfessionalLicenseNumber = @ProfessionalLicenseNumber,
	updateUser = @updateUser,
	updateDate = getdate()
WHERE employeeID = @employeeID

EXEC rpc_Update_EmployeeInClinic_preselected @employeeID, null, null

GO

GRANT EXEC ON dbo.rpc_UpdateEmployeeProfessionLicence TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_UpdateEmployeeProfessionLicence TO [clalit\IntranetDev]
GO