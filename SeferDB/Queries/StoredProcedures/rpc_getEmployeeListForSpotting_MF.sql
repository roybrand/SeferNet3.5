IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeListForSpotting_MF')
	BEGIN
		DROP  Procedure  rpc_getEmployeeListForSpotting_MF
	END

GO

CREATE Procedure dbo.rpc_getEmployeeListForSpotting_MF
	(
	@FirstName varchar(50)=null,
	@LastName varchar(50)=null,
	@LicenseNumber int = null,
	@EmployeeID int=null
	)

AS

SELECT DISTINCT T226.* FROM
(SELECT
	FirstName,
	FamilyName as lastName,
	Gender,
	EmployeeID = CAST( CAST(PersonID as varchar(10)) + CAST(IDControlDigit as varchar(1)) as bigint),
	CASE WHEN DocLicenseNumber <> 0 THEN DocLicenseNumber
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN DentalLicenseNumber
		 ELSE 0 END as licenseNumber,
	CASE WHEN DocLicenseNumber <> 0 THEN ''
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN '(שיניים)'
		 ELSE '' END as IsDental,
	CASE WHEN DocLicenseNumber <> 0 THEN 0
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN 1
		 ELSE 0 END as IsDentalBit

	FROM TR_DoctorsInfo226 WHERE delFlag = 0 AND DeadDate is null
) as T226
LEFT JOIN Employee E ON T226.licenseNumber = E.licenseNumber
	AND T226.IsDentalBit = E.IsDental

WHERE T226.EmployeeID NOT IN (SELECT EmployeeID FROM Employee WHERE IsInCommunity = 1)
AND (@EmployeeID is null OR T226.employeeID = @EmployeeID)
AND (@LicenseNumber is null OR T226.licenseNumber = @LicenseNumber)
AND (@FirstName is null OR T226.firstName LIKE @FirstName + '%')
AND (@LastName is null OR T226.lastName LIKE @LastName + '%')
 
 
GO

GRANT EXEC ON rpc_getEmployeeListForSpotting_MF TO PUBLIC

GO

