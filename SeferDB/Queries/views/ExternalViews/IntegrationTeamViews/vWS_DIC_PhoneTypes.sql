/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DIC_PhoneTypes]'))
	DROP VIEW [dbo].[vWS_DIC_PhoneTypes]
GO

CREATE VIEW [dbo].[vWS_DIC_PhoneTypes]
AS SELECT  phoneTypeCode ,
        phoneTypeName 
FROM DIC_PhoneTypes

GO

GRANT SELECT ON [dbo].[vWS_DIC_PhoneTypes] TO [public] AS [dbo]
GO
