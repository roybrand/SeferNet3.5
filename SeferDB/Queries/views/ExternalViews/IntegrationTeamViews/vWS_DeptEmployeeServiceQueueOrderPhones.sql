/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptEmployeeServiceQueueOrderPhones]'))
	DROP VIEW [dbo].[vWS_DeptEmployeeServiceQueueOrderPhones]
GO

CREATE VIEW [dbo].[vWS_DeptEmployeeServiceQueueOrderPhones]
AS SELECT  
	EmployeeServiceQueueOrderMethodID ,
    phoneType ,
    prePrefix ,
    prefix ,
    phone ,
    extension 
FROM EmployeeServiceQueueOrderPhones

GO

GRANT SELECT ON [dbo].[vWS_DeptEmployeeServiceQueueOrderPhones] TO [public] AS [dbo]
GO
