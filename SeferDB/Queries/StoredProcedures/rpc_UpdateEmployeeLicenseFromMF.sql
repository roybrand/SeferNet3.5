IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeLicenseFromMF')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeLicenseFromMF
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeeLicenseFromMF

AS

UPDATE employee
SET licenseNumber = CASE 
					WHEN TR226.DocLicenseNumber <> 0 THEN TR226.DocLicenseNumber
					WHEN TR226.DocLicenseNumber = 0 AND TR226.DentalLicenseNumber <> 0 THEN TR226.DentalLicenseNumber 
					ELSE null END,
	IsDental =	CASE
					WHEN TR226.DocLicenseNumber <> 0 THEN 0 -- NOT IsDental
					WHEN TR226.DocLicenseNumber = 0 AND TR226.DentalLicenseNumber <> 0 THEN 1 /* IsDental */ 
					ELSE 0 END
						
FROM employee E
INNER JOIN TR_DoctorsInfo226 TR226 ON E.employeeID = CAST( (CAST(TR226.PersonID as varchar(10)) + CAST(TR226.IDControlDigit as varchar(1)) ) as bigint)
WHERE	( E.licenseNumber <> TR226.DocLicenseNumber AND E.licenseNumber <> TR226.DentalLicenseNumber  )
	OR 
		(E.licenseNumber = TR226.DocLicenseNumber AND TR226.DocLicenseNumber <> 0 AND IsDental = 1)
	OR
		(E.licenseNumber = TR226.DentalLicenseNumber AND TR226.DocLicenseNumber = 0  AND IsDental = 0 )	


GO

GRANT EXEC ON rpc_UpdateEmployeeLicenseFromMF TO PUBLIC

GO

