IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeePositionDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeePositionDescriptions
	END

GO

create function [dbo].rfn_GetDeptEmployeePositionDescriptions(@DeptCode int, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN
	declare @PositionsStr varchar(500) 
	set @PositionsStr = ''
	
	SELECT @PositionsStr = @PositionsStr + PositionDescription + ' ; ' 
	FROM
		(select distinct Position.PositionDescription, Position.PositionCode
		from x_Dept_Employee_Position as xDEP
		INNER JOIN x_dept_employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Employee ON xd.employeeID = Employee.employeeID			
		INNER JOIN Position on xDEP.PositionCode = Position.PositionCode and Employee.sex = Position.gender
		WHERE xd.DeptCode = @deptCode
		AND xd.EmployeeID = @employeeID
		)
		as d 
	order by d.PositionDescription
	
	IF(LEN(@PositionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @PositionsStr = Left( @PositionsStr, LEN(@PositionsStr) -1 )
		END
	
	return (@PositionsStr);
end 

go 
grant exec on rfn_GetDeptEmployeePositionDescriptions to public 
go
