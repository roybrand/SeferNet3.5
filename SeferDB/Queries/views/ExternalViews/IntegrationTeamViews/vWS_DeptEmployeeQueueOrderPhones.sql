/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptEmployeeQueueOrderPhones]'))
	DROP VIEW [dbo].[vWS_DeptEmployeeQueueOrderPhones]
GO

CREATE VIEW [dbo].[vWS_DeptEmployeeQueueOrderPhones]
AS SELECT  
        QueueOrderMethodID ,
        phoneType ,
        prePrefix ,
        prefix ,
        phone ,
        extension 
  FROM DeptEmployeeQueueOrderPhones

GO


GRANT SELECT ON [dbo].[vWS_DeptEmployeeQueueOrderPhones] TO [public] AS [dbo]
GO
