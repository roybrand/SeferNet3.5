IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeePhones')
	BEGIN
		DROP  function  fun_GetDeptEmployeePhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeePhones]
(
	@EmployeeID int,
	@DeptCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
    FROM x_dept_employee xd
    INNER JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
    WHERE xd.DeptCode = @deptCode AND xd.EmployeeID = @employeeID
    AND CascadeUpdateDeptEmployeePhonesFromClinic = 1
    ORDER BY dp.phoneType, dp.phoneOrder
    

	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
	FROM x_dept_employee xd 
	INNER JOIN DeptEmployeePhones dep ON xd.deptEmployeeID = dep.DeptEmployeeID
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	ORDER BY dep.phoneType, dep.phoneOrder

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END

GO

grant exec on fun_GetDeptEmployeePhones to public 
GO    
