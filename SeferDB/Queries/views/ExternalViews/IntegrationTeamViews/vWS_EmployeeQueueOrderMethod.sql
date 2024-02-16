/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_EmployeeQueueOrderMethod]'))
	DROP VIEW [dbo].[vWS_EmployeeQueueOrderMethod]
GO

CREATE VIEW [dbo].[vWS_EmployeeQueueOrderMethod]
AS SELECT  
QueueOrderMethodID ,
        QueueOrderMethod ,
         DeptEmployeeID 
FROM EmployeeQueueOrderMethod

GO

GRANT SELECT ON [dbo].[vWS_EmployeeQueueOrderMethod] TO [public] AS [dbo]
GO
