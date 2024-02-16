IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_findDoctorByFirstNameAndSector')
	BEGIN
		DROP  Procedure  rpc_findDoctorByFirstNameAndSector
	END

GO

CREATE Procedure dbo.rpc_findDoctorByFirstNameAndSector
(
	@searchText			VARCHAR(30)
	,@prefixLastName	VARCHAR(30)
	,@onlyDoctorConnectedToClinic INT
	,@sector	INT
	,@IsInCommunity bit
	,@IsInMushlam bit
	,@IsInHospitals bit
	
)

AS


SELECT FirstName 
FROM
(
SELECT distinct Employee.FirstName, showOrder = 0  
FROM employee 
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
WHERE FirstName LIKE @searchText + '%'
AND (@prefixLastName is null OR LastName LIKE @prefixLastName + '%')
AND Employee.active = 1
AND (@sector <= 0 OR EmployeeSectorCode = @sector)
AND(@onlyDoctorConnectedToClinic = 0 OR (x_Dept_Employee.deptCode is NOT null) )
and(@IsInCommunity = 1 and employee.IsInCommunity = 1
	or @IsInMushlam = 1 and  employee.IsInMushlam = 1
	or @IsInHospitals = 1 and employee.IsInHospitals = 1)
UNION

SELECT distinct Employee.FirstName, showOrder = 1  
FROM employee 
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
WHERE FirstName LIKE '%' + @searchText + '%' AND FirstName NOT LIKE @searchText + '%'
AND (@prefixLastName is null OR LastName LIKE @prefixLastName + '%')
AND Employee.active = 1
AND (@sector <= 0 OR EmployeeSectorCode = @sector)
AND(@onlyDoctorConnectedToClinic = 0 OR (x_Dept_Employee.deptCode is NOT null) )
and(@IsInCommunity = 1 and employee.IsInCommunity = 1
	or @IsInMushlam = 1 and  employee.IsInMushlam = 1
	or @IsInHospitals = 1 and employee.IsInHospitals = 1)
) as T1

ORDER BY showOrder, FirstName

GO

GRANT EXEC ON rpc_findDoctorByFirstNameAndSector TO PUBLIC

GO


