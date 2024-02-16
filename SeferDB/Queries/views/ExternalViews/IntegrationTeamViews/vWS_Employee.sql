/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_Employee]'))
	DROP VIEW [dbo].[vWS_Employee]
GO

CREATE VIEW [dbo].[vWS_Employee]
AS SELECT  employeeID ,
        badgeID ,
        licenseNumber, 
        lastName ,
        firstName ,
        degreeCode ,
        sex ,
        email ,
        showEmailInInternet
 FROM dbo.Employee 
WHERE active=1 AND EmployeeSectorCode=7 AND IsDental = 0


GO

GRANT SELECT ON [dbo].[vWS_Employee] TO [public] AS [dbo]
GO
