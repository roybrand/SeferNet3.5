IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertServiceQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_insertServiceQueueOrderMethod
	END

GO

CREATE Procedure dbo.rpc_insertServiceQueueOrderMethod
	(
		@DeptCode int,
		@ServiceCode int,
		@QueueOrderMethod int,
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT,
		@QueueOrderMethodID int = 0 OUTPUT
	)

AS

	declare @xDeptEmployeeServiceID int

	set @xDeptEmployeeServiceID = (select xDES.x_Dept_Employee_ServiceID from x_Dept_Employee_Service xDES
			join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID 
			WHERE deptCode  = @DeptCode
				AND serviceCode = @ServiceCode)
	INSERT INTO EmployeeServiceQueueOrderMethod
	(QueueOrderMethod, updateDate, UpdateUser, x_dept_employee_serviceID)
	VALUES
	(@QueueOrderMethod, getdate(), @UpdateUser, @xDeptEmployeeServiceID)
	
	SET @ErrCode = @@Error
	SET @QueueOrderMethodID = @@IDENTITY
	
	IF(@QueueOrderMethodID is null)
	BEGIN
		SET @QueueOrderMethodID = 0
	END

GO

GRANT EXEC ON rpc_insertServiceQueueOrderMethod TO PUBLIC

GO

