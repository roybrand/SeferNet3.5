IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CascadeEmployeeServiceQueueOrderFromDept')
    BEGIN
	    DROP  Procedure  rpc_CascadeEmployeeServiceQueueOrderFromDept
    END

GO
 
CREATE Procedure dbo.rpc_CascadeEmployeeServiceQueueOrderFromDept
(
	@x_dept_employee_serviceID INT,
	@updateUser VARCHAR(100)
)

AS


DELETE EmployeeServiceQueueOrderMethod
WHERE x_dept_employee_serviceID = @x_dept_employee_serviceID


UPDATE x_dept_employee_service
SET QueueOrder = null, UpdateDate = GETDATE(), UpdateUser = @updateUser
WHERE x_dept_employee_serviceID = @x_dept_employee_serviceID

                
GO


GRANT EXEC ON rpc_CascadeEmployeeServiceQueueOrderFromDept TO PUBLIC

GO            
