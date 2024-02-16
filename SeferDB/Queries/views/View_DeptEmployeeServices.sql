IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeServices')
	BEGIN
		DROP  View View_DeptEmployeeServices
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeServices
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId, x_Dept_Employee.AgreementType
			,STUFF( 
				(
					SELECT  '; ' + serviceDescription
					FROM x_Dept_Employee_Service AS xDEP
					inner join Services  
						ON xDEP.serviceCode = Services.serviceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and Services.IsService = 1
					order by serviceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as serviceDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.ServiceCode as varchar(max))
					FROM x_Dept_Employee_Service AS xDEP
					inner join Services 
						ON xDEP.serviceCode = Services.serviceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and Services.IsService = 1
					order by serviceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ServiceCodes
	from x_Dept_Employee 
GO

