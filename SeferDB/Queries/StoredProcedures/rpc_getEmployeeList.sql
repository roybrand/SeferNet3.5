IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeList')
	BEGIN
		DROP  Procedure  rpc_getEmployeeList
	END

GO

CREATE Procedure rpc_getEmployeeList
(
	@FirstName varchar(50)=null,
	@LastName varchar(50)=null,
	@LicenseNumber int = null,
	@EmployeeID bigint=null
)

AS

DECLARE @IsCommunity int 
DECLARE @IsMushlam int 
DECLARE @IsHospital int 


SELECT 
EmployeeSectorDescription,
DegreeName,
firstName,
lastName,
Employee.employeeID,
licenseNumber
	
FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
WHERE (@EmployeeID is null OR Employee.employeeID = @EmployeeID)
AND (@LicenseNumber is null OR Employee.licenseNumber = @LicenseNumber)
AND (@FirstName is null OR firstName LIKE @FirstName + '%')
AND (@LastName is null OR lastName LIKE @LastName + '%')


GO


GRANT EXEC ON rpc_getEmployeeList TO [clalit\webuser]
GO

GRANT EXEC ON rpc_getEmployeeList TO [clalit\IntranetDev]
GO


