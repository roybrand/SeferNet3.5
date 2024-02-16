IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeePhonesOnly')
	BEGIN
		DROP  function  fun_GetDeptEmployeePhonesOnly
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeePhonesOnly]
(
	@EmployeeID int,
	@DeptCode int
) 
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) + ', '
	FROM x_dept_employee xd
	INNER JOIN DeptPhones dp on xd.DeptCode = dp.DeptCode
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	AND dp.phoneType <> 2 -- fax
	AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	ORDER BY dp.phoneType, phoneOrder
    
    
	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '
	FROM x_dept_Employee xd
	INNER JOIN DeptEmployeePhones dep on xd.DeptEmployeeID = dep.DeptEmployeeID	
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	AND dep.phoneType <> 2 -- fax
	AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 0
	ORDER BY dep.phoneType, phoneOrder
	

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetDeptEmployeePhonesOnly to public 
GO    
 