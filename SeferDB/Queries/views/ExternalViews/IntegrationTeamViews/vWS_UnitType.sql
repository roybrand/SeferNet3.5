/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_UnitType]'))
	DROP VIEW [dbo].[vWS_UnitType]
GO

CREATE VIEW [dbo].[vWS_UnitType]
AS SELECT  UnitTypeCode ,
        UnitTypeName
 FROM UnitType

GO

GRANT SELECT ON [dbo].[vWS_UnitType] TO [public] AS [dbo]
GO
