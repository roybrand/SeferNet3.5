IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_getEmployeeOrderByProfessionInDept]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_getEmployeeOrderByProfessionInDept]
GO

CREATE FUNCTION [dbo].[fun_getEmployeeOrderByProfessionInDept] 
(
	@DeptCode int,
	@EmployeeID bigint
)
RETURNS int

AS
BEGIN
	DECLARE @order int
	SET @order = 4
	
	SET @order =
		(SELECT TOP 1 opder FROM
			(SELECT opder = CASE xDES.serviceCode WHEN 2 THEN 1 WHEN 40 THEN 2 ELSE 3 END
			FROM x_Dept_Employee_Service xdes
			INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
			WHERE xd.employeeID = @EmployeeID 
			AND xd.deptCode = @DeptCode
			) as T
		ORDER BY opder)
	IF (@order is null)
		SET @order = 4
	
	RETURN( @order )		
END

GO


