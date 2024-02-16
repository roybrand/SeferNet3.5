/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_languages]'))
	DROP VIEW [dbo].[vWS_languages]
GO

CREATE VIEW [dbo].[vWS_languages]
AS SELECT  languageCode ,
        languageDescription
  FROM languages

GO

GRANT SELECT ON [dbo].[vWS_languages] TO [public] AS [dbo]
GO
