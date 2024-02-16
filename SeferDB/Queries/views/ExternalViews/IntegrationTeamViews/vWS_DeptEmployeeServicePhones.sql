/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptEmployeeServicePhones]'))
	DROP VIEW [dbo].[vWS_DeptEmployeeServicePhones]
GO

CREATE VIEW [dbo].[vWS_DeptEmployeeServicePhones]
AS SELECT  
	phoneType ,
	prePrefix ,
	prefix ,
	phone ,
	extension ,
	x_Dept_Employee_ServiceID
FROM EmployeeServicePhones

GO

GRANT SELECT ON [dbo].[vWS_DeptEmployeeServicePhones] TO [public] AS [dbo]
GO
