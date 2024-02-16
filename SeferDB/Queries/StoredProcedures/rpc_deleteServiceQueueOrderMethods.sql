IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_deleteServiceQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_deleteServiceQueueOrderMethods
	(
		@DeptCode int,
		@ServiceCode int,
		@ErrCode int OUTPUT
	)

AS

		DELETE FROM EmployeeServiceQueueOrderHours
		WHERE EmployeeServiceQueueOrderMethodID IN (SELECT ESQOM.EmployeeServiceQueueOrderMethodID
									FROM EmployeeServiceQueueOrderMethod ESQOM
									join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
										join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
										WHERE xDE.deptCode  = @DeptCode
										AND xDES.serviceCode = @ServiceCode)
									
		DELETE FROM EmployeeServiceQueueOrderPhones
		WHERE EmployeeServiceQueueOrderMethodID IN (SELECT ESQOM.EmployeeServiceQueueOrderMethodID
									FROM EmployeeServiceQueueOrderMethod ESQOM
									join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
										join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
										WHERE xDE.deptCode  = @DeptCode
										AND xDES.serviceCode = @ServiceCode)
									
		DELETE FROM EmployeeServiceQueueOrderMethod
		WHERE EmployeeServiceQueueOrderMethodID in
		(
			SELECT ESQOM.EmployeeServiceQueueOrderMethodID
				FROM EmployeeServiceQueueOrderMethod ESQOM
				join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
					join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
					WHERE xDE.deptCode  = @DeptCode
					AND xDES.serviceCode = @ServiceCode
		)

		SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_deleteServiceQueueOrderMethods TO PUBLIC

GO

