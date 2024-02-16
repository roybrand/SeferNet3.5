IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeePositionsExtended')
	BEGIN
		DROP  Procedure  rpc_getEmployeePositionsExtended
	END

GO

CREATE Procedure dbo.rpc_getEmployeePositionsExtended
(
	@deptEmployeeID INT
)

AS

DECLARE @employeeSector INT
DECLARE @employeeGender INT
DECLARE @employeeID INT

SET @employeeID = (	SELECT EmployeeID
					FROM x_dept_employee
					WHERE DeptEmployeeID = @deptEmployeeID
				   )

SET @employeeSector  =	(SELECT EmployeeSectorCode
						FROM Employee
						WHERE employeeID = @employeeID)
						
SET @employeeGender  =	(SELECT Sex
						FROM Employee
						WHERE employeeID = @employeeID)						


SELECT p.PositionCode, p.Gender, p.PositionDescription, 0 as linkedToEmpInDept
FROM Position as p
WHERE ((@employeeGender = 0 AND p.gender = 1) OR ( @employeeGender <> 0 AND @employeeGender = p.gender)) 
AND p.relevantSector = @employeeSector
AND p.positionCode NOT IN
(
	SELECT positionCode
	FROM x_Dept_Employee_Position dep	
	WHERE DeptEmployeeID = @deptEmployeeID
)

UNION

SELECT p.PositionCode, p.Gender, p.PositionDescription, 1 as linkedToEmpInDept
FROM Position as p 
INNER JOIN x_Dept_Employee_Position dep ON p.positionCode = dep.positionCode
WHERE DeptEmployeeID = @deptEmployeeID
AND ((@employeeGender = 0 AND p.gender = 1) OR ( @employeeGender <> 0 AND @employeeGender = p.gender)) 
AND p.relevantSector = @employeeSector


ORDER BY p.PositionDescription



GO

GRANT EXEC ON rpc_getEmployeePositionsExtended TO PUBLIC

GO

