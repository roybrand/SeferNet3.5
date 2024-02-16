IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeProfessions')
	BEGIN
		DROP  View View_DeptEmployeeProfessions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeProfessions
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId, x_Dept_Employee.AgreementType
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.ServiceDescription as varchar(max))
					from x_Dept_Employee_Service as xDEP
					inner join Services 
						on xDEP.serviceCode = Services.ServiceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						and Services.IsProfession = 1
					order by Services.ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.ServiceCode as varchar(max))
					from x_Dept_Employee_Service as xDEP
					inner join Services 
						on xDEP.serviceCode = Services.ServiceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						and Services.IsProfession = 1
					order by Services.ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionCodes
	from x_Dept_Employee 
GO

