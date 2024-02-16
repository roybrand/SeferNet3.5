SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetEmployeeInDeptPositions]
(
	@EmployeeID int,
	@DeptCode int,
	@Sex int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SET @Sex = IsNull(@Sex, 1)
    IF @Sex = 0
		BEGIN
			SET @Sex = 1
		END

    SELECT @p_str = @p_str + position.positionDescription + ','

	FROM x_Dept_Employee_Position
	INNER JOIN position ON x_Dept_Employee_Position.positionCode = position.positionCode
	INNER JOIN x_dept_employee xd ON x_Dept_Employee_Position.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.employeeID = @EmployeeID
	AND xd.deptCode = @DeptCode
	AND position.gender = @Sex
	
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END

    RETURN @p_str

END
GO

