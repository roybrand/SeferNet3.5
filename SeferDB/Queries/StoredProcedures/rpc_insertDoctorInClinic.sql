IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDoctorInClinic')
	BEGIN
		DROP  Procedure  rpc_InsertDoctorInClinic
	END
GO

CREATE PROCEDURE dbo.rpc_InsertDoctorInClinic
(
		@DeptCode int,
		@employeeID int,
		@agreementType int,
		@updateUserName varchar(50),
		@active int,
		@ErrorStatus int output,
		@deptEmployeeID int output
)

AS

IF(NOT EXISTS (SELECT EmployeeID FROM Employee WHERE EmployeeID = @employeeID))
BEGIN
	RETURN
END

DECLARE @IsCommunity bit
DECLARE @IsMushlam bit
DECLARE @IsHospital bit
DECLARE @ReceiveGuests bit
 

SELECT	@IsCommunity = Isnull(IsCommunity,0), 
		@IsMushlam = IsNull(isMushlam,0), 
		@IsHospital = IsNull(IsHospital,0)
FROM Dept 
WHERE deptCode = @DeptCode

IF (@agreementType = -1)
BEGIN
	IF (@IsCommunity = 1)
		-- קהילה
		BEGIN
			IF(	SELECT isNull(Dept.subUnitTypeCode, 0) FROM Dept WHERE deptCode = @DeptCode ) = 0 
				BEGIN
					SET @agreementType = 1
					SET @ReceiveGuests = 1;
				END
			ELSE
				BEGIN
					SET @agreementType = 2
					SET @ReceiveGuests = 0;
				END
		END
	
	ELSE IF (@IsMushlam = 1)
		-- מושלם ברשת רופאים
		BEGIN
			SET @agreementType = (	SELECT TOP 1 AgreementTypeID 
									FROM DIC_AgreementTypes
									WHERE OrganizationSectorID = 2
									AND IsDefault = 1)
			SET @ReceiveGuests = 0;
		END
							
	ELSE IF (@IsHospital = 1)
		-- בתי חולים
		BEGIN
			SET @agreementType = (	SELECT TOP 1 AgreementTypeID 
									FROM DIC_AgreementTypes
									WHERE OrganizationSectorID = 3
									AND IsDefault = 1)
			SET @ReceiveGuests = 0;
		END
END

UPDATE Employee 
SET Employee.IsInCommunity = CASE WHEN @IsCommunity = 1 THEN 1 ELSE Employee.IsInCommunity END,
    Employee.IsInMushlam = CASE WHEN @IsMushlam = 1 THEN 1 ELSE Employee.IsInMushlam END
WHERE Employee.employeeID = @employeeID
	
INSERT INTO x_Dept_Employee
(
	DeptCode,
	employeeID,
	AgreementType,
	updateUserName,
	active,
	ReceiveGuests
)
VALUES
(
	@DeptCode,
	@employeeID,
	@agreementType,
	@updateUserName,
	cast (@active as tinyint),
	@ReceiveGuests
)
		
SET @deptEmployeeID = @@IDENTITY		
		
	/* After Employee was added to Dept  
		we have to add all his remarks marked as "AttributedToAllClinics" */
				
		INSERT INTO x_Dept_Employee_EmployeeRemarks
		(EmployeeRemarkID, updateUser, updateDate, DeptEmployeeID)
		SELECT
		EmployeeRemarkID, @updateUserName, getdate(), @deptEmployeeID
		FROM EmployeeRemarks 		
		WHERE AttributedToAllClinicsInCommunity  = 1
		AND EmployeeID = @employeeID


		INSERT INTO EmployeeStatusInDept 
		(Status, UpdateUser, FromDate, DeptEmployeeID)
		VALUES
		(@active, @updateUserName, getdate(), @deptEmployeeID)
					
		SET @ErrorStatus = @@Error
	
GO


GRANT EXEC ON rpc_InsertDoctorInClinic TO PUBLIC

GO


