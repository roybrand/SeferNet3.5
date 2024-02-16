IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDoctorByLastName')
	BEGIN
		DROP  Procedure  rpc_GetDoctorByLastName
	END

GO

CREATE Procedure dbo.rpc_GetDoctorByLastName
(
	@lastName VARCHAR(30),
	@SearchExtended BIT
)


AS

SELECT DegreeName, LastName, FirstName
FROM Employee
INNER JOIN Dic_EmployeeDegree ON Employee.DegreeCode = Dic_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
WHERE ((LastName LIKE @lastName + '%') OR (LastName LIKE '%' + @lastName + '%' AND @searchExtended = 1))
AND IsDoctor = 1

ORDER BY LastName



GO


GRANT EXEC ON rpc_GetDoctorByLastName TO PUBLIC

GO






