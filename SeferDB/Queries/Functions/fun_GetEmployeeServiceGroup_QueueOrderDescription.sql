IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceGroup_QueueOrderDescription')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceGroup_QueueOrderDescription
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceGroup_QueueOrderDescription] (@DeptEmployeeID int, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @QueueOrderDescription varchar(50) SET @QueueOrderDescription = ''
		
	IF(@ServiceCode <> 0)
	BEGIN
		SELECT @QueueOrderDescription = DIC_QueueOrder.QueueOrderDescription
		FROM x_Dept_Employee_Service xdes 
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode
	END
	ELSE
	BEGIN
		SET @QueueOrderDescription = ''
	END
	
	-- if there's no queue order via employee service
	-- try to get queue order via employee
	IF(@QueueOrderDescription = '') 
	BEGIN
		SELECT @QueueOrderDescription = DIC_QueueOrder.QueueOrderDescription
		FROM x_Dept_Employee x_D_E
		INNER JOIN DIC_QueueOrder ON x_D_E.QueueOrder = DIC_QueueOrder.QueueOrder
		WHERE x_D_E.DeptEmployeeID = @DeptEmployeeID
		
		IF( @QueueOrderDescription is null)
			SET @QueueOrderDescription = ''
	END

	RETURN @QueueOrderDescription

END
GO

grant exec on fun_GetEmployeeServiceGroup_QueueOrderDescription to public 
go 
