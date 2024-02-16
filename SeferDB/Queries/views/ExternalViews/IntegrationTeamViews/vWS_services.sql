/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_services]'))
	DROP VIEW [dbo].[vWS_services]
GO

CREATE VIEW [dbo].[vWS_services]
AS SELECT  ServiceCode ,
        ServiceDescription,
        IsService ,
        IsProfession 
FROM [services]

GO

GRANT SELECT ON [dbo].[vWS_services] TO [public] AS [dbo]
GO
