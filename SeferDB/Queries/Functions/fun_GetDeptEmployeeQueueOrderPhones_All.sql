 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetDeptEmployeeQueueOrderPhones_All]
(
	@DeptCode int,
	@EmployeeID int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + dbo.ParsePhoneNumber(prePrefix, prefix, phone) + '<br>'
	FROM DeptEmployeeQueueOrderPhones
	INNER JOIN EmployeeQueueOrderMethod ON DeptEmployeeQueueOrderPhones.QueueOrderMethodID = EmployeeQueueOrderMethod.QueueOrderMethodID
	--INNER JOIN DIC_QueueOrderMethod ON EmployeeQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE EmployeeQueueOrderMethod.deptCode = @DeptCode
	AND EmployeeQueueOrderMethod.employeeID = @EmployeeID
	ORDER BY phoneType, phoneOrder

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO
 