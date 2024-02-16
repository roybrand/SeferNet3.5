/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptEmployeeServiceQueueOrderMethod]'))
	DROP VIEW [dbo].[vWS_DeptEmployeeServiceQueueOrderMethod]
GO

CREATE VIEW [dbo].[vWS_DeptEmployeeServiceQueueOrderMethod]
AS SELECT  
	EmployeeServiceQueueOrderMethodID ,
	QueueOrderMethod ,
	x_dept_employee_serviceID
FROM EmployeeServiceQueueOrderMethod

GO

GRANT SELECT ON [dbo].[vWS_DeptEmployeeServiceQueueOrderMethod] TO [public] AS [dbo]
GO
