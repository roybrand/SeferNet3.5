IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeSpecialityByName')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeSpecialityByName
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeSpecialityByName
(
	@prefixText VARCHAR(20),
	@employeeID BIGINT
)

AS


SELECT 
S.serviceCode as ProfessionCode, 
S.ServiceDescription as ProfessionDescription

FROM EmployeeServices
INNER JOIN [Services] S ON EmployeeServices.serviceCode = S.serviceCode

WHERE EmployeeID = @employeeID 
AND S.ServiceDescription LIKE '%' + @prefixText + '%'
ORDER BY S.ServiceDescription

GO


GRANT EXEC ON rpc_GetEmployeeSpecialityByName TO PUBLIC

GO


