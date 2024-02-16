IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptEmployeeQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptEmployeeQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptEmployeeQueueOrderMethods
(
	@deptEmployeeID INT	
)

AS




DELETE DeptEmployeeQueueOrderPhones
WHERE QueueOrderMethodID IN 
							(SELECT QueueOrderMethodID
								FROM EmployeeQueueOrderMethod  
								WHERE DeptEmployeeID = @deptEmployeeID)


DELETE EmployeeQueueOrderHours
WHERE QueueOrderMethodID IN 
							(SELECT QueueOrderMethodID
								FROM EmployeeQueueOrderMethod  
								WHERE DeptEmployeeID = @deptEmployeeID)
							
					

DELETE EmployeeQueueOrderMethod
WHERE DeptEmployeeID = @deptEmployeeID

	
	
UPDATE x_dept_Employee
SET QueueOrder = -1
WHERE DeptEmployeeID = @deptEmployeeID



GO

GRANT EXEC ON rpc_DeleteDeptEmployeeQueueOrderMethods TO PUBLIC

GO


