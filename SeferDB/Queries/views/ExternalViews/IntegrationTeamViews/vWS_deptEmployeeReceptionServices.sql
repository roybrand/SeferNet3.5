/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_deptEmployeeReceptionServices]'))
	DROP VIEW [dbo].[vWS_deptEmployeeReceptionServices]
GO

CREATE VIEW [dbo].[vWS_deptEmployeeReceptionServices]
AS SELECT 
 deptEmployeeReceptionServicesID ,
        receptionID ,
        serviceCode
  FROM deptEmployeeReceptionServices

GO


GRANT SELECT ON [dbo].[vWS_deptEmployeeReceptionServices] TO [public] AS [dbo]
GO
