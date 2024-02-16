IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeExpertProfessions')
	BEGIN
		DROP  View View_EmployeeExpertProfessions
	END
GO

CREATE VIEW [dbo].View_EmployeeExpertProfessions
AS
SELECT Employee.employeeID
			,STUFF( 
				(
					SELECT  '; ' + [Services].ServiceDescription
					from EmployeeServices as ES
					inner join [Services] 
						on ES.employeeID = Employee.employeeID
						and ES.serviceCode = [Services].ServiceCode
						and ES.expProfession = 1
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(ES.serviceCode as varchar(max))
					from EmployeeServices as ES
					inner join [Services] 
						on ES.employeeID = Employee.employeeID
						and ES.serviceCode = [Services].ServiceCode
						and ES.expProfession = 1
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionCodes
	from Employee 
GO

