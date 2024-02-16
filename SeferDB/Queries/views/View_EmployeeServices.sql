IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeServices')
	BEGIN
		DROP  View View_EmployeeServices
	END
GO

CREATE VIEW [dbo].View_EmployeeServices
AS
SELECT  Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + Services.serviceDescription
					FROM EmployeeServices AS ES
					inner join Services 
						ON ES.employeeID = Employee.employeeID
						and ES.serviceCode = Services.serviceCode
						and Services.IsService = 1
					order by Services.serviceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as serviceDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.serviceCode as varchar(max))
					FROM EmployeeServices AS ES
					inner join Services 
						ON ES.employeeID = Employee.employeeID
						and ES.serviceCode = Services.serviceCode
						and Services.IsService = 1
					order by Services.serviceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ServiceCodes
	from Employee 
GO

