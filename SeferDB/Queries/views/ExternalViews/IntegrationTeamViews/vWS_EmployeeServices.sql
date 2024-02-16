/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_EmployeeServices]'))
	DROP VIEW [dbo].[vWS_EmployeeServices]
GO

CREATE  VIEW [dbo].[vWS_EmployeeServices]
AS SELECT  EmployeeID ,
        serviceCode ,
        expProfession 
FROM EmployeeServices

GO

GRANT SELECT ON [dbo].[vWS_EmployeeServices] TO [public] AS [dbo]
GO
