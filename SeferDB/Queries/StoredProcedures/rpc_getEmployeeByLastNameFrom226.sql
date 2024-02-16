IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeByLastNameFrom226')
	BEGIN
		DROP  Procedure  rpc_getEmployeeByLastNameFrom226
	END

GO

CREATE Procedure dbo.rpc_getEmployeeByLastNameFrom226
(
	@LastName varchar(50)=null,
	@FirstName varchar(50)=null
)

AS

SELECT DISTINCT LastName FROM
(SELECT
	FamilyName as LastName,
	FirstName,
	EmployeeID = CAST( CAST(PersonID as varchar(10)) + CAST(IDControlDigit as varchar(1)) as bigint),
	CASE WHEN DocLicenseNumber <> 0 THEN DocLicenseNumber
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN DentalLicenseNumber
		 ELSE 0 END as licenseNumber

	FROM TR_DoctorsInfo226 WHERE delFlag = 0 AND DeadDate is null
) as T226
WHERE T226.EmployeeID NOT IN (SELECT EmployeeID FROM Employee)
AND T226.licenseNumber NOT IN (SELECT IsNull(licenseNumber,0) FROM Employee)
AND (@FirstName is null OR T226.firstName LIKE @FirstName + '%')
AND (@LastName is null OR T226.lastName LIKE @LastName + '%')
ORDER BY LastName


GO

GRANT EXEC ON rpc_getEmployeeByLastNameFrom226 TO PUBLIC

GO

