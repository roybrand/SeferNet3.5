/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptQueueOrderPhones]'))
	DROP VIEW [dbo].[vWS_DeptQueueOrderPhones]
GO

CREATE VIEW [dbo].[vWS_DeptQueueOrderPhones]
AS SELECT  
       queueOrderMethodID ,
        phoneType ,
        prePrefix ,
        prefix ,
        phone ,
        extension 
     FROM DeptQueueOrderPhones

GO

GRANT SELECT ON [dbo].[vWS_DeptQueueOrderPhones] TO [public] AS [dbo]
GO
