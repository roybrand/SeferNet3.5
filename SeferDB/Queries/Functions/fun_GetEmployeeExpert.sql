IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeExpert')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeExpert
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeExpert]
(
	@EmployeeID bigint
)

RETURNS varchar(500)
AS
BEGIN
    DECLARE @p_str VARCHAR(500)
    DECLARE @p_strTitle VARCHAR(50)
    SET @p_str = ''
    SET @p_strTitle = ''

    SELECT @p_strTitle = @p_strTitle +
		CASE isNull(employee.sex, 0) WHEN 1 THEN 'מומחה ב' WHEN 2 THEN 'מומחית ב' ELSE 'מומחה ב' END 	
    FROM employee WHERE employeeID = @EmployeeID
    
    SELECT @p_str = @p_str +
		RTRIM(LTRIM([Services].ShowExpert)) + ' וב'
		
	FROM [Services]
	INNER JOIN EmployeeServices ON [Services].ServiceCode = EmployeeServices.ServiceCode
	WHERE EmployeeServices.employeeID = @EmployeeID
	AND EmployeeServices.expProfession = 1
	AND [Services].EnableExpert = 1

	IF len(@p_str) > 1
	-- remove last comma OR 'וב'
	BEGIN
		SET @p_str = @p_strTitle + @p_str
		
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str)-2)
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetEmployeeExpert to public 
go 