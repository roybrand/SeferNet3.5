/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DIC_QueueOrderMethod]'))
	DROP VIEW [dbo].[vWS_DIC_QueueOrderMethod]
GO

CREATE VIEW [dbo].[vWS_DIC_QueueOrderMethod]
AS SELECT  QueueOrderMethod ,
        QueueOrderMethodDescription 
FROM DIC_QueueOrderMethod

GO

GRANT SELECT ON [dbo].[vWS_DIC_QueueOrderMethod] TO [public] AS [dbo]
GO
