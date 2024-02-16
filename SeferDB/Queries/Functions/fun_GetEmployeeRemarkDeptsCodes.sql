IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeRemarkDeptsCodes')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeRemarkDeptsCodes						
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeRemarkDeptsCodes](@RemarkID int,@EmployeeID int) 
RETURNS varchar(2000)
AS
BEGIN
	declare @DeptsCodes varchar(2000) 
	 
	set @DeptsCodes = '' 

	SELECT @DeptsCodes = @DeptsCodes + cast(DeptCode as varchar(10)) + ','
	FROM (
		SELECT DISTINCT xd.DeptCode as DeptCode
		FROM x_Dept_Employee_EmployeeRemarks as xder
		INNER JOIN x_dept_employee as xd ON xder.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Dept as d ON xd.DeptCode = d.DeptCode 
		WHERE xder.EmployeeRemarkID = @RemarkID
		AND xd.EmployeeID = @EmployeeID) as tblDepts
	where DeptCode is not null 


		IF len(@DeptsCodes) > 1
		-- remove last comma
		BEGIN
			SET @DeptsCodes = SUBSTRING(@DeptsCodes, 0, len(@DeptsCodes))
		END
		
		RETURN @DeptsCodes

	return @DeptsCodes 
end
