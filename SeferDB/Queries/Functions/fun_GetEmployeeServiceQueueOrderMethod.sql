IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderMethod')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderMethod
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderMethod] (@DeptEmployeeID int, @ServiceCode int)
RETURNS VARCHAR(100)
WITH EXECUTE AS CALLER
AS
BEGIN

DECLARE @queueMethod VARCHAR(100)

SET @queueMethod = ''

SELECT @queueMethod =   @queueMethod + CONVERT(VARCHAR,esqom.QueueOrderMethod) + ',' 
						FROM x_dept_employee_service xdes
						INNER JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_dept_employee_ServiceID = esqom.x_dept_employee_ServiceID
						LEFT JOIN EmployeeQueueOrderMethod eqom ON xdes.DeptEmployeeID = eqom.DeptEmployeeID
						LEFT JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

						WHERE xdes.DeptEmployeeID = @DeptEmployeeID
						AND xdes.serviceCode = @ServiceCode
						ORDER BY esqom.QueueOrderMethod

IF LEN(@queueMethod) > 1
-- remove last comma
BEGIN
	SET @queueMethod = SUBSTRING(@queueMethod, 0, len(@queueMethod))
END
		

RETURN @queueMethod


END

GO

grant exec on fun_GetEmployeeServiceQueueOrderMethod to public 
go 
