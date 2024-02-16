IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDoctorByFirstName')
	BEGIN
		DROP  Procedure  rpc_GetDoctorByFirstName
	END

GO

CREATE Procedure dbo.rpc_GetDoctorByFirstName
(
	@firstName VARCHAR(30),
	@SearchExtended BIT
)


AS

SELECT DegreeName, LastName, FirstName
FROM Employee
INNER JOIN Dic_EmployeeDegree ON Employee.DegreeCode = Dic_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
WHERE ((FirstName LIKE @firstName + '%') OR (FirstName LIKE '%' + @firstName + '%' AND @searchExtended = 1))
AND IsDoctor = 1

ORDER BY FirstName



GO


GRANT EXEC ON rpc_GetDoctorByFirstName TO PUBLIC

GO






