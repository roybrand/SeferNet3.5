IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessionForUpdate')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessionForUpdate
	END

GO

CREATE Procedure dbo.rpc_getEmployeeProfessionForUpdate
	(
		@EmployeeID int,
		@ProfessionCode int
	)

AS

SELECT
EmployeeServices.EmployeeID,
EmployeeServices.serviceCode as professionCode,
[Services].ServiceDescription as professionDescription,
EmployeeServices.mainProfession,
'expProfession' = CAST( isNull(EmployeeServices.expProfession, 0) as bit) 

FROM EmployeeServices
INNER JOIN [Services] ON EmployeeServices.serviceCode = [Services].ServiceCode
WHERE EmployeeID = @EmployeeID
	AND EmployeeServices.serviceCode = @ProfessionCode

GO

GRANT EXEC ON rpc_getEmployeeProfessionForUpdate TO PUBLIC

GO

