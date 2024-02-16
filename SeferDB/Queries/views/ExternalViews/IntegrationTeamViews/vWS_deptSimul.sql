/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_deptSimul]'))
	DROP VIEW [dbo].[vWS_deptSimul]
GO

CREATE VIEW [dbo].[vWS_deptSimul]
AS SELECT  deptCode ,
         Simul228
  FROM deptSimul

GO

GRANT SELECT ON [dbo].[vWS_deptSimul] TO [public] AS [dbo]
GO
