IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_findDoctorByLastNameAndSector')
	BEGIN
		DROP  Procedure  rpc_findDoctorByLastNameAndSector
	END

GO

CREATE Procedure dbo.rpc_findDoctorByLastNameAndSector
(
	@searchText VARCHAR(30),
	@prefixFirstName VARCHAR(30),
	@onlyDoctorConnectedToClinic INT,
	@sector INT
	,@IsInCommunity bit
	,@IsInMushlam bit
	,@IsInHospitals bit
)

AS

SELECT lastName FROM
(
SELECT distinct Employee.lastName, showOrder = 0  
FROM employee 
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
WHERE lastName LIKE @searchText + '%'
AND (@prefixFirstName is null OR firstName LIKE @prefixFirstName + '%')
AND Employee.active = 1
AND (@sector <= 0 OR EmployeeSectorCode = @sector)
AND(@onlyDoctorConnectedToClinic = 0 OR (x_Dept_Employee.deptCode is NOT null) )
and(@IsInCommunity = 1 and employee.IsInCommunity = 1
	or @IsInMushlam = 1 and  employee.IsInMushlam = 1
	or @IsInHospitals = 1 and employee.IsInHospitals = 1)
UNION

SELECT distinct Employee.lastName, showOrder = 1  
FROM employee 
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
WHERE lastName LIKE '%' + @searchText + '%' AND lastName NOT LIKE @searchText + '%'
AND (@prefixFirstName is null OR firstName LIKE @prefixFirstName + '%')
AND Employee.active = 1
AND (@sector <= 0 OR EmployeeSectorCode = @sector)
AND(@onlyDoctorConnectedToClinic = 0 OR (x_Dept_Employee.deptCode is NOT null) )
and(@IsInCommunity = 1 and employee.IsInCommunity = 1
	or @IsInMushlam = 1 and  employee.IsInMushlam = 1
	or @IsInHospitals = 1 and employee.IsInHospitals = 1)
) as T1

ORDER BY showOrder, lastName


GO


GRANT EXEC ON rpc_findDoctorByLastNameAndSector TO PUBLIC

GO


