IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeeServiceQueueOrderDescription')
	BEGIN
		DROP  function  fun_GetDeptEmployeeServiceQueueOrderDescription
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeeServiceQueueOrderDescription]
(
	@deptEmployeeID int,
	@serviceCode int
)
RETURNS varchar(100)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(100)
    SET @p_str = ''

	SELECT @p_str = IsNull(dic.QueueOrderDescription,'')
					FROM x_dept_employee_service xdes
					LEFT JOIN DIC_QueueOrder dic ON xdes.QueueOrder = dic.QueueOrder
					WHERE xdes.DeptEmployeeID = @deptEmployeeID
					AND xdes.ServiceCode = @serviceCode
					AND PermitOrderMethods = 0

	IF @p_str = ''
		SELECT @p_str = IsNull(dic.QueueOrderDescription,'')
					FROM x_dept_employee xd
					LEFT JOIN DIC_QueueOrder dic ON xd.QueueOrder = dic.QueueOrder
					WHERE xd.DeptEmployeeID = @deptEmployeeID					
					AND PermitOrderMethods = 0


    RETURN @p_str

END
GO

grant exec on fun_GetDeptEmployeeServiceQueueOrderDescription to public 
GO    
 