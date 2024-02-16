IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeRemarks')
	BEGIN
		DROP  View View_DeptEmployeeRemarks
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeRemarks
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId, x_Dept_Employee.AgreementType
			,STUFF( 
				(
					SELECT  '; ' + [dbo].[rfn_GetFotmatedRemark](EmployeeRemarks.RemarkText)
					from x_Dept_Employee_EmployeeRemarks as xDEP
					inner join EmployeeRemarks 
						on xDEP.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and EmployeeRemarks.ValidFrom  < dateadd(day,1,convert(Date, GETDATE()))
						and EmployeeRemarks.ValidTo  >= convert(Date, GETDATE())
					order by EmployeeRemarks.RemarkText
					FOR XML PATH('') 
				)
				,1,2,'') as RemarkDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(xDEP.EmployeeRemarkID as varchar(max))
					from x_Dept_Employee_EmployeeRemarks as xDEP
					inner join EmployeeRemarks 
						on xDEP.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						and EmployeeRemarks.ValidFrom  < dateadd(day,1,convert(Date, GETDATE()))
						and EmployeeRemarks.ValidTo  >= convert(Date, GETDATE())
					order by EmployeeRemarks.RemarkText
					FOR XML PATH('') 
				)
				,1,2,'') as RemarkCodes
	from x_Dept_Employee 
GO

