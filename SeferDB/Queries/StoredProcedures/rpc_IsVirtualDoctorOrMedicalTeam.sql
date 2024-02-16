
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_IsVirtualDoctorOrMedicalTeam')
	BEGIN
		DROP  Procedure  rpc_IsVirtualDoctorOrMedicalTeam
	END

GO


create Procedure [dbo].[rpc_IsVirtualDoctorOrMedicalTeam]
(
	@employeeID BIGINT
)

AS


SELECT EmployeeID, IsNull(IsVirtualDoctor, 0) AS IsVirtualDoctor  , IsNull(IsMedicalTeam,0) AS IsMedicalTeam
FROM Employee
WHERE EmployeeID = @employeeID
 
 GO

GRANT EXEC ON rpc_IsVirtualDoctorOrMedicalTeam TO PUBLIC

GO
