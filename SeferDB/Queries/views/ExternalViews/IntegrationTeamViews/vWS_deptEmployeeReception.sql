/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_deptEmployeeReception]'))
DROP VIEW [dbo].[vWS_deptEmployeeReception]
GO

CREATE VIEW [dbo].[vWS_deptEmployeeReception]
AS SELECT  receptionID ,
        receptionDay ,
        openingHour ,
        closingHour ,
        validFrom ,
        validTo ,
         DeptEmployeeID 
FROM deptEmployeeReception 
WHERE (validFrom <= GETDATE() OR  validFrom  IS NULL) 
                AND (validTo      >= GETDATE() OR  validTo Is NULL)   


GO


GRANT SELECT ON [dbo].[vWS_deptEmployeeReception] TO [public] AS [dbo]
GO
