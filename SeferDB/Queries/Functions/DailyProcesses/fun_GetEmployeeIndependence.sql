IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetEmployeeIndependence')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeIndependence
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeIndependence] 
(
	@EmployeeID int
)
RETURNS varchar(50)

AS
	
BEGIN
	DECLARE @Independence varchar(50) SET @Independence = ''
	DECLARE @Count int SET @Count = 0
	
	SELECT @Count = @Count + AgreementType
	FROM
		(SELECT DISTINCT AgreementType
		FROM x_Dept_Employee 
		WHERE x_Dept_Employee.employeeID = @EmployeeID
		AND x_Dept_Employee.AgreementType in (1,2)
		) as T
	
	SET @Independence = CASE CAST(@Count as varchar(1)) 
						WHEN '1' THEN 'קהילה'
						WHEN '2' THEN 'עצמאי'
						WHEN '3' THEN 'עצמאי וקהילה'
						ELSE '' END
						
	RETURN( @Independence )		
END

GO
