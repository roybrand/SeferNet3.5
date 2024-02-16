IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeeServicePhones')
	BEGIN
		DROP  function  fun_GetDeptEmployeeServicePhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeeServicePhones]
(
	@DeptEmployeeID int,
	@ServiceCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
	-- employee service phones
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(esp.prePrefix, esp.prefix, esp.phone, esp.extension ) + ','
	FROM x_Dept_Employee_Service xdes 
	INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID  
	INNER JOIN EmployeeServicePhones esp on xdes.x_Dept_Employee_ServiceID = esp.x_Dept_Employee_ServiceID
	WHERE xdes.DeptEmployeeID = @DeptEmployeeID
	AND xdes.ServiceCode = @serviceCode
	AND esp.PhoneType = 1


	-- employee dept phones
	IF (@p_str = '')
	BEGIN
		SELECT @p_str = @p_str + CASE WHEN dep.phone is not null THEN
										dbo.fun_ParsePhoneNumberWithExtension(dep.prePrefix, dep.prefix, dep.phone, dep.extension )
									  END + ','				
		FROM DeptEmployeePhones dep 
		INNER JOIN x_dept_employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND dep.PhoneType = 1
	END


	-- dept phones
	IF (@p_str = '')
	BEGIN
		SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension ) + ','				
		FROM x_dept_employee xd
		INNER JOIN DeptPhones dp ON xd.deptCode = dp.deptCode AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1	
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND dp.PhoneType = 1
	END


	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END

GO

grant exec on fun_GetDeptEmployeeServicePhones to public 
GO    
