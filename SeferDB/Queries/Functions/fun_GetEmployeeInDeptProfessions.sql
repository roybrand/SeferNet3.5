IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeInDeptProfessions')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeInDeptProfessions
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeInDeptProfessions]
(
	@EmployeeID int,
	@DeptCode int,
	@isOrderASC bit
)
-- gets professions for employee in clinic as list of comma separated values

RETURNS varchar(500)
AS
BEGIN
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''   	
    	
	declare @tempTable table
	(
		professionDescription VARCHAR(100)
	)

	INSERT INTO @tempTable        
    SELECT [Services].serviceDescription    
    FROM x_Dept_Employee_Service
    INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
    INNER JOIN x_dept_employee xd ON x_Dept_Employee_Service.DeptEmployeeID = xd.DeptEmployeeID
    WHERE xd.employeeID = @EmployeeID
    AND xd.deptCode = @DeptCode
    AND x_Dept_Employee_Service.Status = 1
	AND [Services].IsService = 0
    ORDER BY 
	CASE @isOrderASC
		WHEN 1 THEN [Services].serviceDescription 
		END,
	CASE WHEN @isOrderASC <> 1 OR @isOrderASC IS NULL THEN [Services].serviceDescription 
		END DESC  
	
	
	SELECT @p_str = @p_str + professionDescription + ','
	FROM @tempTable    
    	
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetEmployeeInDeptProfessions to public 
GO
