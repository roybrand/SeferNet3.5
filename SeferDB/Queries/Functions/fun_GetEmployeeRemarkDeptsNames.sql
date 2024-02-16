IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeRemarkDeptsNames')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeRemarkDeptsNames						
	END
GO


CREATE FUNCTION [dbo].[fun_GetEmployeeRemarkDeptsNames](@RemarkID int,@EmployeeID int) 
RETURNS varchar(2000)
AS
BEGIN
	declare @DeptsNames varchar(2000) 
	 
	set @DeptsNames = '' 

	SELECT @DeptsNames = @DeptsNames + DeptName + ','
	FROM (
		SELECT DISTINCT deptName as DeptName 
		FROM x_Dept_Employee_EmployeeRemarks as xder
		INNER JOIN x_dept_employee xd ON xder.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Dept as d ON xd.DeptCode = d.DeptCode 
		WHERE xder.EmployeeRemarkID = @RemarkID
		AND xd.EmployeeID = @EmployeeID) as tblDepts
	WHERE DeptName is not null 
	
	IF len(@DeptsNames) > 1
	-- remove last comma
	BEGIN
		SET @DeptsNames = SUBSTRING(@DeptsNames, 0, len(@DeptsNames))
	END
	
	RETURN @DeptsNames	

end 