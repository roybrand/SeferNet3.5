/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_Streets]'))
	DROP VIEW [dbo].[vWS_Streets]
GO

CREATE VIEW [dbo].[vWS_Streets]
AS SELECT  CityCode ,
        StreetCode ,
        Name
  FROM Streets

GO

GRANT SELECT ON [dbo].[vWS_Streets] TO [public] AS [dbo]
GO
