 --fun_GetEmployeeCurrentStatus
 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter FUNCTION [dbo].[fun_GetEmployeeCurrentStatus] 
(
	@employeeID bigint
)
RETURNS int

AS
BEGIN
	DECLARE  @EmployeeCurrentStatus bigint
	
	 set @EmployeeCurrentStatus = (SELECT TOP 1 Status FROM EmployeeStatus
				WHERE EmployeeID = @employeeID
				AND fromDate < getdate()
				ORDER BY fromDate desc)
	
	IF @EmployeeCurrentStatus is null
	BEGIN
		SET @EmployeeCurrentStatus = (SELECT active FROM employee WHERE EmployeeID = @employeeID)
	END
	
	RETURN( @EmployeeCurrentStatus )
	
END
