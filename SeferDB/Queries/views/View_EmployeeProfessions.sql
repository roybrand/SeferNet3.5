IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeProfessions')
	BEGIN
		DROP  View View_EmployeeProfessions
	END
GO

CREATE VIEW [dbo].View_EmployeeProfessions
AS
SELECT  Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + [Services].ServiceDescription
					from EmployeeServices as ES
					inner join [Services] 
						on ES.ServiceCode = [Services].ServiceCode
						and ES.employeeID = Employee.employeeID
						and [Services].IsProfession = 1
					order by ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceCode as varchar(max))
					from EmployeeServices as ES
					inner join [Services] 
						on ES.ServiceCode = [Services].ServiceCode
						and ES.employeeID = Employee.employeeID
						and [Services].IsProfession = 1
					order by ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionCodes
	from Employee 
GO

