/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_Cities]'))
	DROP VIEW [dbo].[vWS_Cities]
GO

CREATE VIEW [dbo].[vWS_Cities]
AS SELECT  cityCode ,
        cityName 
FROM Cities

GO

GRANT SELECT ON [dbo].[vWS_Cities] TO [public] AS [dbo]
GO
