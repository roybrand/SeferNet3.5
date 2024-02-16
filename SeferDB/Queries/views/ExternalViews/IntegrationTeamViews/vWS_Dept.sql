/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/

ALTER VIEW [dbo].[vWS_Dept]
AS SELECT  deptCode ,
       deptName ,
        districtCode ,
        typeUnitCode ,
        subUnitTypeCode ,
        administrationCode,
		subAdministrationCode,
        cityCode ,
        StreetCode ,
		streetName ,
        house ,
        addressComment ,
        transportation ,
		email , 
		dbo.fun_getAdminManagerName(deptCode) as adminManagerName
FROM Dept 
WHERE status=1


GO
