/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_EmployeeLanguages]'))
	DROP VIEW [dbo].[vWS_EmployeeLanguages]
GO

CREATE VIEW [dbo].[vWS_EmployeeLanguages]
AS SELECT  EmployeeID ,
        languageCode 
  FROM EmployeeLanguages

GO

GRANT SELECT ON [dbo].[vWS_EmployeeLanguages] TO [public] AS [dbo]
GO
