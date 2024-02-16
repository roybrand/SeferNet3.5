IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeListForSpotting')
	BEGIN
		DROP  Procedure  rpc_getEmployeeListForSpotting
	END

GO

CREATE Procedure rpc_getEmployeeListForSpotting
(
	@FirstName varchar(50)=null,
	@LastName varchar(50)=null,
	@LicenseNumber int = null,
	@EmployeeID int=null,
	@DeptCode int=null
)

AS

DECLARE @IsCommunity int 
DECLARE @IsMushlam int 
DECLARE @IsHospital int 

DECLARE @Status int SET @Status = 1 -- פעיל

SELECT @IsCommunity = IsCommunity, @IsMushlam = IsMushlam, @IsHospital = IsHospital
FROM Dept WHERE deptCode = @DeptCode

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
AND Employee.employeeID NOT IN (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode)
AND @Status = active
AND (IsInCommunity = @IsCommunity OR IsInHospitals = @IsHospital OR IsInMushlam = @IsMushlam)

GO

GRANT EXEC ON rpc_getEmployeeListForSpotting TO PUBLIC

GO

