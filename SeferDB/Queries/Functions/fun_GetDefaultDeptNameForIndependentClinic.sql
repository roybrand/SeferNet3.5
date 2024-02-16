IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDefaultDeptNameForIndependentClinic')
	BEGIN
		DROP  function  fun_GetDefaultDeptNameForIndependentClinic
	END
GO

CREATE FUNCTION [dbo].[fun_GetDefaultDeptNameForIndependentClinic]
(
	@DeptCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    DECLARE @Count int
    SET @p_str = ''

	SELECT @Count = count(*) FROM x_Dept_Employee
	JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
	where x_Dept_Employee.active = 1
	AND Employee.IsMedicalTeam = 0
	AND x_Dept_Employee.deptCode = @DeptCode
	
	IF(@Count = 0)
		BEGIN
			SELECT @p_str = deptNameFreePart FROM Dept WHERE deptCode = @DeptCode
		END
	ELSE
		BEGIN
			SELECT TOP 2 @p_str = @p_str + EmployeeName + ' / ' FROM(
				SELECT 
					LTRIM(RTRIM(Employee.lastName + ' ' + Employee.firstName)) as EmployeeNameNoTitle,
					LTRIM(RTRIM(DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' + Employee.firstName)) as EmployeeName,
					ES.OrderToShow
					FROM x_Dept_Employee
					JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
					JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
					JOIN EmployeeSector ES ON Employee.EmployeeSectorCode = ES.EmployeeSectorCode
					where x_Dept_Employee.active = 1
					AND Employee.IsMedicalTeam = 0
					AND x_Dept_Employee.deptCode = @DeptCode
					) T
			ORDER BY OrderToShow, EmployeeNameNoTitle 
			
			IF len(@p_str) > 1 
			BEGIN
				SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
			END
		END	
	
    RETURN @p_str

END
GO

GRANT EXEC ON dbo.fun_GetDefaultDeptNameForIndependentClinic TO [clalit\webuser]
GO

GRANT EXEC ON dbo.fun_GetDefaultDeptNameForIndependentClinic TO [clalit\IntranetDev]
GO