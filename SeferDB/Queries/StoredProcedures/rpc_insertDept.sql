IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_insertDept')
	BEGIN
		PRINT 'Dropping Procedure rpc_insertDept'
		DROP  Procedure  rpc_insertDept
	END

GO

CREATE Procedure [dbo].[rpc_insertDept]
	(
		@DeptCode int,
		@UpdateUser varchar(50),
		@ErrorCode int = 0 OUTPUT
	)

AS
	
DECLARE @populationSectorCode int 
SET @populationSectorCode = null
SET @populationSectorCode = CASE (SELECT SugSimul FROM SimulOld731 WHERE KodSimulOld = @DeptCode)
	WHEN 1 THEN 3 /*מיעוטים*/ WHEN 2 THEN 2 /*חרדים*/ WHEN 3 THEN 4 /*עולים*/ ELSE 1 /*כללי*/ END

/* List of Hospitals */
SELECT Dept.deptCode as districtCode
INTO #HospitalDistricts 
FROM Dept where typeUnitCode = 60

/* Hospital */
SELECT SimulDeptId, 
	CASE WHEN HD.districtCode IS NOT null THEN HD.districtCode ELSE
	CASE WHEN HD1.districtCode IS NOT null THEN HD1.districtCode ELSE
	CASE WHEN HD2.districtCode IS NOT null THEN HD2.districtCode ELSE
	CASE WHEN HD3.districtCode IS NOT null THEN HD3.districtCode ELSE	
	CASE WHEN HD4.districtCode IS NOT null THEN HD4.districtCode ELSE		
	CASE WHEN HD5.districtCode IS NOT null THEN HD5.districtCode ELSE 0	
	END END END END END END as DistrictCode
INTO #HospitalDistrict	
FROM InterfaceFromSimulNewDepts as Int1
LEFT JOIN #HospitalDistricts HD ON Int1.manageId = HD.districtCode

LEFT JOIN Simul403 as AdmSimul ON Int1.ManageId = AdmSimul.KodSimul
LEFT JOIN #HospitalDistricts HD1 ON AdmSimul.ManageId = HD1.districtCode

LEFT JOIN Simul403 as AdmSimul2 ON AdmSimul.manageId = AdmSimul2.KodSimul
LEFT JOIN #HospitalDistricts HD2 ON AdmSimul2.ManageId = HD2.districtCode

LEFT JOIN Simul403 as AdmSimul3 ON AdmSimul2.manageId = AdmSimul3.KodSimul
LEFT JOIN #HospitalDistricts HD3 ON AdmSimul3.ManageId = HD3.districtCode

LEFT JOIN Simul403 as AdmSimul4 ON AdmSimul3.manageId = AdmSimul4.KodSimul
LEFT JOIN #HospitalDistricts HD4 ON AdmSimul4.ManageId = HD4.districtCode

LEFT JOIN Simul403 as AdmSimul5 ON AdmSimul4.manageId = AdmSimul5.KodSimul
LEFT JOIN #HospitalDistricts HD5 ON AdmSimul5.ManageId = HD5.districtCode

WHERE SimulDeptId = @DeptCode 	

INSERT INTO dept
(deptCode, deptName, deptNameFreePart, deptType, districtCode, deptLevel, typeUnitCode, subUnitTypeCode, administrationCode, subAdministrationCode, managerName, cityCode, zipCode, StreetCode, streetName, house, flat, entrance, floor, email, status, independent, populationSectorCode, updateUser,
MFStreetName,MFStreetCode, showUnitInInternet, IsCommunity, IsHospital)
SELECT
IFS.SimulDeptId, 
SimulDeptName + ' - ' + UT.UnitTypeName + ' - ' + Cities.cityName as deptName, 
CASE WHEN (Key_typUnit = 112 OR Key_typUnit = 101) THEN '' ELSE SimulDeptName END as deptNameFreePart,
DeptType,
'DistrictId' = 	CASE 
					WHEN (HD.DistrictCode is not null AND HD.DistrictCode <> 0)
					THEN HD.DistrictCode 
					ELSE 
						CASE WHEN Cities.cityCode is not null
							 THEN Cities.districtCode
						ELSE (SELECT TOP 1 districtCode FROM View_AllDistricts)
						END 
				END,				
				
3, Key_typUnit, 
'subUnitTypeCode' = (SELECT TOP 1 subUnitTypeCode FROM subUnitType SUT
					INNER JOIN UnitType ON SUT.UnitTypeCode = UnitType.UnitTypeCode AND SUT.subUnitTypeCode = UnitType.DefaultSubUnitTypeCode
					WHERE SUT.UnitTypeCode = Key_typUnit),
ManageId, null, Menahel, 
'City' = CASE WHEN exists (select * from Cities where cityCode = IFS.City) THEN City ELSE 9999 END,		zip, 
Streets.StreetCode, IFS.street, house, flat, entrance, null, Email, 2/*StatusSimul*/, null, @populationSectorCode, @UpdateUser,
IFS.street, MF_Streets340.StreetCode, 0
,CASE WHEN (HD.DistrictCode is not null AND HD.DistrictCode <> 0) THEN 0 ELSE 1 END as IsCommunity
,CASE WHEN (HD.DistrictCode is not null AND HD.DistrictCode <> 0) THEN 1 ELSE 0 END as IsHospital
FROM InterfaceFromSimulNewDepts IFS
LEFT JOIN Cities ON IFS.City = Cities.cityCode
LEFT JOIN Streets ON IFS.street = Streets.Name
	AND Cities.cityCode = Streets.CityCode
LEFT JOIN MF_Streets340 ON IFS.street = MF_Streets340.Name
	AND IFS.City = MF_Streets340.CityCode 
LEFT JOIN View_AllDistricts d ON d.districtCode = IFS.DistrictId
LEFT JOIN UnitType UT ON IFS.Key_typUnit = UT.UnitTypeCode
LEFT JOIN #HospitalDistrict HD ON IFS.SimulDeptId = HD.SimulDeptId

WHERE IFS.SimulDeptId = @DeptCode

--SET @ErrorCode = @@ERROR

--INSERT INTO x_Dept_District
--(deptCode, districtCode)
--SELECT Dept.deptCode, S403.manageId
--FROM Simul403 S403 
--JOIN Dept ON S403.KodSimul = Dept.deptCode
--JOIN (SELECT deptCode FROM Dept WHERE typeUnitCode = 60 OR typeUnitCode = 65) Dist
--	ON S403.manageId = Dist.deptCode
--WHERE Dept.deptCode = @DeptCode
--AND S403.manageId <> Dept.districtCode

--SET @ErrorCode = @@ERROR

--IF EXISTS 
--	(SELECT * FROM
--	Simul403
--	JOIN Dept Dist ON Simul403.manageId = Dist.deptCode
--		AND Dist.typeUnitCode = 60
--	WHERE Simul403.KodSimul = @DeptCode)
--BEGIN
--	UPDATE Dept
--	SET IsHospital = 1, IsCommunity = 0
--	WHERE deptCode = @DeptCode
--END

SET @ErrorCode = @@ERROR

GO


GRANT EXEC ON rpc_insertDept TO [clalit\webuser]
GO

GRANT EXEC ON rpc_insertDept TO [clalit\IntranetDev]
GO
     