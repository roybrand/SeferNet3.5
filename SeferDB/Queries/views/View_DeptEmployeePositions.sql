IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeePositions')
	BEGIN
		DROP  View View_DeptEmployeePositions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeePositions
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId, x_Dept_Employee.AgreementType
			,STUFF( 
				(
					SELECT  '; ' + cast(PositionDescription as varchar(max))
					from x_Dept_Employee_Position as xDEP
					INNER JOIN Employee
						on  xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and x_Dept_Employee.employeeID = Employee.employeeID
					INNER JOIN Position 
						on xDEP.PositionCode = Position.PositionCode
						and Employee.sex = Position.gender
					order by Position.PositionDescription
					FOR XML PATH('') 
				)
				,1,2,'') as PositionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(xDEP.PositionCode as varchar(max))
					from x_Dept_Employee_Position as xDEP
					INNER JOIN Employee 
						on  xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and x_Dept_Employee.employeeID = Employee.employeeID
					join Position 
						on xDEP.PositionCode = Position.PositionCode
						and Employee.sex = Position.gender
					order by Position.PositionDescription
					FOR XML PATH('') 
				)
				,1,2,'') as PositionCodes
	from x_Dept_Employee 
GO

grant select on View_DeptEmployeePositions to public 
GO

