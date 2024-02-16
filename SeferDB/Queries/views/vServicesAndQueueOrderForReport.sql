IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vServicesAndQueueOrderForReport]'))
DROP VIEW [dbo].[vServicesAndQueueOrderForReport]
GO


CREATE VIEW [dbo].[vServicesAndQueueOrderForReport]
AS
SELECT  xDE.deptCode, xDES.serviceCode, dbo.[Services].ServiceDescription,
	 dbo.rfn_GetDeptServiceQueueOrderDescriptionsHTML(xDE.deptCode,
	  xDES.serviceCode, xDE.employeeID) AS QueueOrder,
	  Employee.IsMedicalTeam
FROM x_Dept_Employee_Service AS xDES 
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	AND xDES.Status = 1 AND xDE.active = 1
JOIN [Services] ON xDES.serviceCode = dbo.[Services].ServiceCode
join Employee on Employee.employeeID = xDE.employeeID

GO

grant select on vServicesAndQueueOrderForReport to public 
go
