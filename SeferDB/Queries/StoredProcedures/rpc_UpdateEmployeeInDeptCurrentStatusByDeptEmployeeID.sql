IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID
	END
GO

CREATE Procedure dbo.rpc_UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID
(
	@DeptEmployeeID int,
	@Status int,
	@UpdateUser varchar(100)
)	
AS

	DECLARE @CurrentDate datetime SET @CurrentDate = GETDATE()
	DECLARE @MaxNONfutureStatusID bigint
	
	SET @MaxNONfutureStatusID = (SELECT MAX(StatusID) 
								FROM EmployeeStatusInDept 
								WHERE DeptEmployeeID = @DeptEmployeeID								
								AND FromDate <= @CurrentDate)
		
	UPDATE EmployeeStatusInDept
	SET Status = @Status
	WHERE DeptEmployeeID = @DeptEmployeeID	
	AND (FromDate >= @CurrentDate
		OR
		(FromDate <= @CurrentDate AND StatusID = @MaxNONfutureStatusID)	)
			
	UPDATE x_Dept_Employee 
	SET Active = @Status, updateDate = @CurrentDate, UpdateUserName = @UpdateUser
	WHERE DeptEmployeeID = @DeptEmployeeID

	DELETE FROM deptEmployeeReception
	WHERE DeptEmployeeID = @DeptEmployeeID

GO

GRANT EXEC ON rpc_UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID TO PUBLIC
GO
