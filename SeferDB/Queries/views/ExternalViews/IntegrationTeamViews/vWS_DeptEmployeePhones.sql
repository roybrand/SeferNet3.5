/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptEmployeePhones]'))
	DROP VIEW [dbo].[vWS_DeptEmployeePhones]
GO

CREATE VIEW [dbo].[vWS_DeptEmployeePhones]
AS SELECT  phoneType ,
        prePrefix ,
        prefix ,
        phone ,
        extension ,
        DeptEmployeeID
        FROM DeptEmployeePhones

GO

GRANT SELECT ON [dbo].[vWS_DeptEmployeePhones] TO [public] AS [dbo]
GO
