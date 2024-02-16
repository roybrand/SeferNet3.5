/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptQueueOrderMethod]'))
	DROP VIEW [dbo].[vWS_DeptQueueOrderMethod]
GO

CREATE VIEW [dbo].[vWS_DeptQueueOrderMethod]
AS SELECT  
queueOrderMethodID ,
        queueOrderMethod ,
        deptCode 
 FROM DeptQueueOrderMethod

GO

GRANT SELECT ON [dbo].[vWS_DeptQueueOrderMethod] TO [public] AS [dbo]
GO
