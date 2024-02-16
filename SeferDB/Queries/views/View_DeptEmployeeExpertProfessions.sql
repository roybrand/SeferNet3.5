IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeExpertProfessions')
	BEGIN
		DROP  View View_DeptEmployeeExpertProfessions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeExpertProfessions
AS
SELECT  xd.deptCode, xd.EmployeeId, xd.AgreementType
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceDescription as varchar(max))
					from x_Dept_Employee_Service as xDES
					inner join EmployeeServices 
						on  xDES.DeptEmployeeID = xd.DeptEmployeeID						
						and xd.employeeID = EmployeeServices.employeeID 
						and xDES.serviceCode = EmployeeServices.serviceCode
						and EmployeeServices.expProfession = 1
					inner join [Services] 
						on xDES.serviceCode = [Services].ServiceCode
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceCode as varchar(max))
					from x_Dept_Employee_Service as xDES
					inner join EmployeeServices 
						on  xDES.DeptEmployeeID = xd.DeptEmployeeID						
						and xd.employeeID = EmployeeServices.employeeID 
						and xdes.serviceCode = EmployeeServices.serviceCode
						and EmployeeServices.expProfession = 1
					inner join [Services]
						on xDES.ServiceCode = [Services].ServiceCode
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionCodes
FROM x_Dept_Employee  xd

GO

