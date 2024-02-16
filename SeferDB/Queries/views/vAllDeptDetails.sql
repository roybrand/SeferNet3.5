IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vAllDeptDetails')
	BEGIN
		DROP  view  vAllDeptDetails
	END

GO

CREATE VIEW [dbo].[vAllDeptDetails]
AS
SELECT  dbo.Dept.deptCode, dbo.Dept.deptName, dbo.UnitType.UnitTypeName, dbo.View_SubUnitTypes.subUnitTypeName, 
        dbo.fun_getManagerName(dbo.Dept.deptCode) AS managerName, dbo.fun_getAdminManagerName(dbo.Dept.deptCode) 
        AS administrativeManagerName, dbo.fun_getGeriatricsManagerName(dbo.Dept.deptCode) AS geriatricsManagerName, 
        dbo.fun_getPharmacologyManagerName(dbo.Dept.deptCode) AS pharmacologyManagerName, 
        dbo.fun_getDeputyHeadOfDepartment(Dept.deptCode) AS deputyHeadOfDepartment, dbo.fun_getSecretaryName(Dept.deptCode) AS secretaryName,
        dbo.View_AllDistricts.districtName, dbo.Cities.cityName, 
        ISNULL(dbo.Dept.addressComment, '&nbsp;') AS addressComment, dbo.Dept.email, dbo.fun_GetDeptPhones(dbo.Dept.deptCode, 1) AS phones, 
        CASE dbo.fun_GetDeptPhones(Dept.deptCode, 2) WHEN '' THEN '&nbsp;' ELSE dbo.fun_GetDeptPhones(Dept.deptCode, 2) END AS faxes, 
        CASE RTRIM(LTRIM(isNull(house, ''))) WHEN '' THEN isNull(streetName, '') ELSE (isNull(streetName + ', ', '') + CAST(house AS varchar(3))) 
        END AS simpleAddress, dbo.DIC_ParkingInClinic.parkingInClinicDescription AS parking, dbo.PopulationSectors.PopulationSectorDescription, 
        dbo.DIC_ActivityStatus.statusDescription, dbo.Dept.transportation, ISNULL(dbo.View_AllAdministrations.AdministrationName, '&nbsp;') 
        AS AdministrationName, ISNULL(subAdmin.SubAdministrationName, '&nbsp;') AS subAdministrationName, dbo.deptSimul.Simul228, 
        dbo.DIC_deptLevel.deptLevelDescription, dbo.fun_GetClinicHandicappedFacilities(dbo.Dept.deptCode) AS handicappedFacilities,
		dbo.Dept.showEmailInInternet, dbo.fun_GetDeptAttribution(dbo.Dept.IsCommunity, dbo.Dept.IsMushlam, dbo.Dept.IsHospital, dbo.Dept.subUnitTypeCode) as deptAttribution
		,dbo.Dept.IsHospital
FROM    dbo.Dept INNER JOIN
        dbo.UnitType ON dbo.Dept.typeUnitCode = dbo.UnitType.UnitTypeCode INNER JOIN
        dbo.DIC_deptLevel ON dbo.Dept.deptLevel = dbo.DIC_deptLevel.deptLevelCode LEFT OUTER JOIN
        dbo.View_SubUnitTypes ON dbo.Dept.subUnitTypeCode = dbo.View_SubUnitTypes.subUnitTypeCode AND 
        dbo.Dept.typeUnitCode = dbo.View_SubUnitTypes.UnitTypeCode LEFT OUTER JOIN
        dbo.View_AllDistricts ON dbo.Dept.districtCode = dbo.View_AllDistricts.districtCode INNER JOIN
        dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode INNER JOIN
        dbo.DIC_ActivityStatus ON dbo.Dept.status = dbo.DIC_ActivityStatus.status LEFT OUTER JOIN
        dbo.View_AllAdministrations ON dbo.Dept.administrationCode = dbo.View_AllAdministrations.AdministrationCode LEFT OUTER JOIN
        dbo.View_SubAdministrations AS subAdmin ON dbo.Dept.subAdministrationCode = subAdmin.SubAdministrationCode LEFT JOIN
        dbo.deptSimul ON dbo.Dept.deptCode = dbo.deptSimul.deptCode LEFT OUTER JOIN
        dbo.DIC_ParkingInClinic ON dbo.Dept.parking = dbo.DIC_ParkingInClinic.parkingInClinicCode LEFT OUTER JOIN
        dbo.PopulationSectors ON dbo.Dept.populationSectorCode = dbo.PopulationSectors.PopulationSectorID LEFT OUTER JOIN
        dbo.DIC_QueueOrder ON dbo.Dept.QueueOrder = dbo.DIC_QueueOrder.QueueOrder

GO
                      
grant select on vAllDeptDetails to public 

go