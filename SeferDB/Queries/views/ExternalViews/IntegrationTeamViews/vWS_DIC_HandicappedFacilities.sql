/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DIC_HandicappedFacilities]'))
	DROP VIEW [dbo].[vWS_DIC_HandicappedFacilities]
GO

CREATE VIEW [dbo].[vWS_DIC_HandicappedFacilities]
AS SELECT  FacilityCode ,
        FacilityDescription
   FROM DIC_HandicappedFacilities

GO

GRANT SELECT ON [dbo].[vWS_DIC_HandicappedFacilities] TO [public] AS [dbo]
GO
