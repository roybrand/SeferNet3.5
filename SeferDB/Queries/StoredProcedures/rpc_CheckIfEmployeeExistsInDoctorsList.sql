IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CheckIfEmployeeExistsInDoctorsList')
	BEGIN
		DROP  Procedure  rpc_CheckIfEmployeeExistsInDoctorsList
	END

GO

CREATE Procedure dbo.rpc_CheckIfEmployeeExistsInDoctorsList
(
		@employeeID BIGINT,
		@licenseNumber INT,
		@retVal BIT OUTPUT
)

AS

SET @retVal = 0


IF @licenseNumber IS NOT NULL
BEGIN
	IF EXISTS
	(
		SELECT * 
		FROM TR_DoctorsInfo226
		WHERE DocLicenseNumber = @licenseNumber
	)
	SET @retVal = 1
END
ELSE
	IF EXISTS
	(
		SELECT * 
		FROM TR_DoctorsInfo226
		WHERE @employeeID = PersonID OR CAST(PersonID as varchar) + cast(IDcontrolDigit as varchar) = cast(@employeeID as varchar)
	)
	SET @retVal = 1
	
	




GO


GRANT EXEC ON rpc_CheckIfEmployeeExistsInDoctorsList TO PUBLIC

GO


