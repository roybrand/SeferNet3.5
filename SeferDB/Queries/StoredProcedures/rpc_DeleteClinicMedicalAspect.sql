IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteClinicMedicalAspect')
	BEGIN
		DROP  Procedure  rpc_DeleteClinicMedicalAspect
	END
GO

CREATE Procedure dbo.rpc_DeleteClinicMedicalAspect
(
	@DeptCode int,
	@MedicalAspectCode int
)	
AS
	DELETE FROM x_dept_medicalAspect 
	WHERE NewDeptCode = @DeptCode
	AND MedicalAspectCode = @MedicalAspectCode

	DELETE FROM x_Dept_Employee_Service
	WHERE x_Dept_Employee_ServiceID NOT IN 
		(SELECT x_Dept_Employee_ServiceID
		FROM x_Dept_Employee_Service
		JOIN x_Dept_Employee ON x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
			AND Employee.IsMedicalTeam = 1
			AND x_Dept_Employee.AgreementType = 5 -- hospitals  
			AND x_Dept_Employee.deptCode = @DeptCode
		JOIN MedicalAspectsToSefer ON x_Dept_Employee_Service.serviceCode = MedicalAspectsToSefer.SeferCode
		JOIN x_dept_medicalAspect ON MedicalAspectsToSefer.MedicalAspectCode = x_dept_medicalAspect.MedicalAspectCode
			AND x_dept_medicalAspect.NewDeptCode = @DeptCode
		)
	AND x_Dept_Employee_ServiceID IN 
		(SELECT x_Dept_Employee_ServiceID
		FROM x_Dept_Employee_Service
		JOIN x_Dept_Employee ON x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
			AND Employee.IsMedicalTeam = 1
			AND x_Dept_Employee.AgreementType = 5 -- hospitals 
			AND x_Dept_Employee.deptCode = @DeptCode
		)

DECLARE @deptEmployeeID int
SET @deptEmployeeID =
		(SELECT DeptEmployeeID
		FROM x_Dept_Employee
		JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
		WHERE x_Dept_Employee.deptCode = @DeptCode
		AND x_Dept_Employee.AgreementType = 5
		AND Employee.IsMedicalTeam = 1)

IF (SELECT COUNT(*) 
	FROM x_Dept_Employee_Service xDES
	WHERE xDES.DeptEmployeeID = @deptEmployeeID) = 0

BEGIN
	DECLARE @CurrentDate datetime SET @CurrentDate = GETDATE()
	DECLARE @MaxNONfutureStatusID bigint
	
	SET @MaxNONfutureStatusID = (SELECT MAX(StatusID) 
								FROM EmployeeStatusInDept 
								WHERE DeptEmployeeID = @deptEmployeeID								
								AND FromDate <=  @CurrentDate)
		
	UPDATE EmployeeStatusInDept
	SET Status = 0
	WHERE DeptEmployeeID = @deptEmployeeID	
	AND (FromDate >= @CurrentDate
		OR
		(FromDate <= @CurrentDate AND StatusID = @MaxNONfutureStatusID)	)
			
	UPDATE x_Dept_Employee 
	SET Active = 0, updateDate = @CurrentDate,  UpdateUserName = 'AutoApdate: remove MedicalAspect and last service'
	WHERE DeptEmployeeID = @deptEmployeeID

	DELETE FROM deptEmployeeReception
	WHERE DeptEmployeeID = @deptEmployeeID

END

GO

GRANT EXEC ON rpc_DeleteClinicMedicalAspect TO PUBLIC
GO
