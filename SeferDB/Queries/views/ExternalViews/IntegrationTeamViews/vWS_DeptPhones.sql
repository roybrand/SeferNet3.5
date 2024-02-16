/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptPhones]'))
	DROP VIEW [dbo].[vWS_DeptPhones]
GO

CREATE VIEW [dbo].[vWS_DeptPhones]
AS SELECT 
        deptCode ,
        phoneType ,
        prePrefix ,
        prefix ,
        phone ,
        extension 
  FROM DeptPhones

GO

GRANT SELECT ON [dbo].[vWS_DeptPhones] TO [public] AS [dbo]
GO
