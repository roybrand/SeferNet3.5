IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_Employee_License_from_TR_DoctorsInfo226')
	BEGIN
		DROP  Procedure  rpc_Update_Employee_License_from_TR_DoctorsInfo226
	END

GO

CREATE Procedure dbo.rpc_Update_Employee_License_from_TR_DoctorsInfo226

AS

UPDATE employee
SET licenseNumber = CASE 
									WHEN CAST(TR226.DocLicenseNumber as int) <> 0 THEN TR226.DocLicenseNumber
									WHEN CAST(TR226.DocLicenseNumber as int) = 0 AND CAST(TR226.DentalLicenseNumber as int) <> 0 THEN TR226.DentalLicenseNumber 
									ELSE 0 END ,
IsDental = CASE
									WHEN CAST(TR226.DocLicenseNumber as int) <> 0 THEN 0 -- NOT IsDental
									WHEN CAST(TR226.DocLicenseNumber as int) = 0 AND CAST(TR226.DentalLicenseNumber as int) <> 0 THEN 1 /* IsDental */ 
									ELSE 0 END  
FROM employee E
INNER JOIN TR_DoctorsInfo226 TR226 ON E.employeeID = CAST( (CAST(TR226.PersonID as varchar(10)) + CAST(TR226.IDControlDigit as varchar(1)) ) as bigint)
WHERE      
( CAST(TR226.DocLicenseNumber as int) <> 0 OR CAST(TR226.DentalLicenseNumber as int) <> 0) AND ((ISNULL( E.licenseNumber, 0) <> CAST(TR226.DocLicenseNumber as int) OR E.licenseNumber = 0) AND (ISNULL(E.licenseNumber, 0) <> CAST(TR226.DentalLicenseNumber as int) OR CAST(TR226.DentalLicenseNumber as int) = 0) )

OR 
(E.licenseNumber = CAST(TR226.DocLicenseNumber as int) AND CAST(TR226.DocLicenseNumber as int) <> 0 AND IsDental = 1)
OR
(E.licenseNumber = CAST(TR226.DentalLicenseNumber as int) AND CAST(TR226.DocLicenseNumber as int) = 0 AND CAST(TR226.DentalLicenseNumber as int) <> 0 AND IsDental = 0 )


GO

GRANT EXEC ON rpc_Update_Employee_License_from_TR_DoctorsInfo226 TO PUBLIC

GO

