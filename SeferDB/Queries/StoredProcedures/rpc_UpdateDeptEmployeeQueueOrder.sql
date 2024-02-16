IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptEmployeeQueueOrder')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptEmployeeQueueOrder
	END

GO

CREATE Procedure dbo.rpc_UpdateDeptEmployeeQueueOrder
(
	@deptEmployeeID INT,	
	@queueOrder INT
)

AS


UPDATE x_Dept_Employee
SET QueueOrder = @queueOrder
WHERE DeptEmployeeID = @deptEmployeeID


GO


GRANT EXEC ON rpc_UpdateDeptEmployeeQueueOrder TO PUBLIC

GO


