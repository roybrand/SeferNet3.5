IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDepSubClinics')
	BEGIN
		drop procedure rpc_GetDepSubClinics
	END

GO

CREATE Procedure [dbo].[rpc_GetDepSubClinics]
(
	@DeptCode int
)
as

DECLARE @CurrentDate datetime = getdate()



---------------- SubClinics List    ***************************
SELECT 
Dept.deptCode,
Dept.deptName,
dept.deptLevel,
Dept.typeUnitCode,
UnitType.UnitTypeName,
'subUnitTypeCode' = CASE IsNull(dept.subUnitTypeCode, -1) 
					WHEN -1 THEN  (SELECT DefaultSubUnitTypeCode FROM UnitType WHERE UnitTypeCode = dept.TypeUnitCode)
					ELSE dept.subUnitTypeCode END,
Dept.IsCommunity,
Dept.IsMushlam,
Dept.IsHospital,
'address' = dbo.GetAddress(Dept.deptCode),
Dept.cityCode,
Cities.cityName,
'phone' = (SELECT TOP 1 
			dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension )
			FROM DeptPhones
			WHERE deptCode = Dept.deptCode AND DeptPhones.PhoneType = 1 and phoneOrder = 1),
-- julia
'countDeptRemarks' = 
	(SELECT COUNT(*) 
	from View_DeptRemarks
	WHERE deptCode = dept.deptCode
		AND validFrom <= @CurrentDate 
		AND ( validTo is null OR validTo >= @CurrentDate ) 
		AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 		 
	),
-- end block julia 
'countReception' = 
	(select count(receptionID) 
	from DeptReception
	where deptCode = dept.deptCode
	AND (validFrom <= @CurrentDate AND (validTo is null OR validTo >= @CurrentDate)))

FROM Dept
inner join Cities on Dept.CityCode = Cities.CityCode
inner join UnitType on  Dept.typeUnitCode = UnitType.UnitTypeCode

WHERE Dept.deptCode in
(SELECT deptCode from dept where subAdministrationCode = @DeptCode and status = 1)
ORDER BY Dept.deptName

go

GRANT EXEC ON rpc_GetDepSubClinics TO PUBLIC
GO