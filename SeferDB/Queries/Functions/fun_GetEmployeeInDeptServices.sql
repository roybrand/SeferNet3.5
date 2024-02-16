  
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_GetEmployeeInDeptServices]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_GetEmployeeInDeptServices]
GO

create FUNCTION [dbo].[fun_GetEmployeeInDeptServices] 
(
	@EmployeeID int, 
	@DeptCode int,
	@isOrderASC bit
)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN 

    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
	DECLARE @ExcludedService int SET @ExcludedService = 180300
    	
	declare @tempTable table
	(
		serviceDescription VARCHAR(100)
	)


	INSERT INTO @tempTable        
    SELECT [Services].serviceDescription    
    FROM x_Dept_Employee_Service
    INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
	INNER JOIN x_Dept_Employee xd ON x_Dept_Employee_service.DeptEmployeeID = xd.DeptEmployeeID
    WHERE xd.employeeID = @EmployeeID
    AND xd.deptCode = @DeptCode
    AND x_Dept_Employee_Service.Status = 1
	AND [Services].IsService = 1
	and x_Dept_Employee_Service.serviceCode <> @ExcludedService
    ORDER BY 
	CASE @isOrderASC
		WHEN 1 THEN [Services].serviceDescription 
		END,
	CASE WHEN @isOrderASC <> 1 OR @isOrderASC IS NULL THEN [Services].serviceDescription 
		END DESC    
    
    SELECT @p_str = @p_str + serviceDescription + ','
	FROM @tempTable    
    
    
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str
	
END

go 

grant exec on dbo.fun_GetEmployeeInDeptServices to public 

go 
