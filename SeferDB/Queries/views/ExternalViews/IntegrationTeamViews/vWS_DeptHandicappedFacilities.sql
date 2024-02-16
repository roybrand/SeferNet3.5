/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptHandicappedFacilities]'))
	DROP VIEW [dbo].[vWS_DeptHandicappedFacilities]
GO

CREATE VIEW [dbo].[vWS_DeptHandicappedFacilities]
AS SELECT  DeptCode ,
        FacilityCode 
FROM DeptHandicappedFacilities

GO

GRANT SELECT ON [dbo].[vWS_DeptHandicappedFacilities] TO [public] AS [dbo]
GO
