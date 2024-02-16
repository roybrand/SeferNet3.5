/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_DeptReception]'))
	DROP VIEW [dbo].[vWS_DeptReception]
GO

CREATE VIEW [dbo].[vWS_DeptReception]
AS SELECT 
        receptionID ,
        deptCode ,
        receptionDay ,
        openingHour ,
        closingHour ,
        validFrom ,
        validTo
    FROM DeptReception  WHERE ReceptionHoursTypeID=1
and (validFrom <= GETDATE() OR  validFrom  IS NULL) 
                AND (validTo      >= GETDATE() OR  validTo Is NULL)   

GO

GRANT SELECT ON [dbo].[vWS_DeptReception] TO [public] AS [dbo]
GO
