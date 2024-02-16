/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_Dept_Employee_Service_Ext]'))
	DROP VIEW [dbo].[vWS_Dept_Employee_Service_Ext]
GO

CREATE VIEW [dbo].[vWS_Dept_Employee_Service_Ext]
AS SELECT           
	xDE.deptCode         
	,xDE.employeeID         
	,xDES.serviceCode
	,xDE.DeptEmployeeID
	,xDES.x_Dept_Employee_ServiceID
	,s.ServiceDescription
	,s.IsProfession 
	,s.IsService
FROM   dbo.x_Dept_Employee_Service xDES 
JOIN x_Dept_Employee xDE ON  xDE.DeptEmployeeID=xDES.DeptEmployeeID       
JOIN dbo.services s ON s.ServiceCode=xDES.serviceCode
where xDE.active = 1

GO


GRANT SELECT ON [dbo].[vWS_Dept_Employee_Service_Ext] TO [clalit\webuser] AS [dbo]
GO
