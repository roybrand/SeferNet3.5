IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeMushlamCommunityReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_EmployeeMushlamCommunityReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_EmployeeMushlamCommunityReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@IsExcelVersion varchar(2)=null,
	@ErrCode varchar(max) OUTPUT
--------------------------------------
)with recompile

AS
--------------------------------------

SELECT employeeID, doctorName, licenseNumber, deptCode, deptName, 
UnitTypeName, subUnitTypeName, 
CASE WHEN IsCommunity = 1 THEN 'קהילה' ELSE 'מושלם' END as 'DeptType',
AgreementTypeDescription, 
districtName, 
cityName, 
CASE WHEN street is null THEN '' ELSE street END + ' ' + 
CASE WHEN addressComment is null THEN '' ELSE addressComment END as 'address',
profession,
professionCode,
max([א-1]) as [alef1],max([א-2]) as [alef2],max([א-3]) as [alef3],max([ב-1]) as [bet1],max([ב-2]) as [bet2],max([ב-3]) as [bet3],max([ג-1]) as [gim1],max([ג-2]) as [gim2],max([ג-3]) as [gim3],max([ד-1]) as [dal1],max([ד-2]) as [dal2],max([ד-3]) as [dal3],max([ה-1]) as [hey1],max([ה-2]) as [hey2],max([ה-3]) as [hey3],max([ו-1]) as [vav1],max([ו-2]) as [vav2],max([ו-3]) as [vav3],max([חג-1]) as [hag1],max([חג-2]) as [hag2],max([חוה"מ-1]) as [hoham1],max([חוה"מ-2]) as [hoham2],max([חוה"מ-3]) as [hoham3],max([ערב חג-1]) as [erevh1],max([ערב חג-2]) as [erevh2],max([ש-1]) as [sh1],max([ש-2]) as [sh2],
max([הערה-א-1]) as [alef1r],max([הערה-א-2]) as [alef2r],max([הערה-א-3]) as [alef3r],max([הערה-ב-1]) as [bet1r],max([הערה-ב-2]) as [bet2r],max([הערה-ב-3]) as [bet3r],max([הערה-ג-1]) as [gim1r],max([הערה-ג-2]) as [gim2r],max([הערה-ג-3]) as [gim3r],max([הערה-ד-1]) as [dal1r],max([הערה-ד-2]) as [dal2r],max([הערה-ד-3]) as [dal3r],max([הערה-ה-1]) as [hey1r],max([הערה-ה-2]) as [hey2r],max([הערה-ה-3]) as [hey3r],max([הערה-ו-1]) as [vav1r],max([הערה-ו-2]) as [vav2r],max([הערה-ו-3]) as [vav3r],max([הערה-חג-1]) as [hag1r],max([הערה-חג-2]) as [hag2r],max([הערה-חוה"מ-1]) as [hoham1r],max([הערה-חוה"מ-2]) as [hoham2r],max([הערה-חוה"מ-3]) as [hoham3r],max([הערה-ערב חג-1]) as [erevh1r],max([הערה-ערב חג-2]) as [erevh2r],max([הערה-ש-1]) as [sh1r],max([הערה-ש-2]) as [sh2r]
FROM 
	(SELECT
	e.employeeID,
    e.firstName+' '+e.lastName as doctorName, 
    e.licenseNumber,
    d.deptCode, d.deptName, ut.UnitTypeName, sut.subUnitTypeName, d.IsCommunity,
    dag.AgreementTypeID, dag.AgreementTypeDescription,
    distr.deptName as districtName, c.cityName, 
    CASE WHEN d.StreetCode is null THEN d.streetName ELSE s.Name END as street,
    d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
    dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
    ser.serviceDescription as profession,
    ser.ServiceCode as professionCode,
    er.receptionDay,
    er.openingHour,
    er.closingHour,
    [DIC_ReceptionDays].ReceptionDayName,
    openingHour + '-' + closingHour as Hours,
    derp.RemarkText,
	row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
	ORDER BY er.openingHour ,er.closingHour )rn,
	[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
    ORDER BY er.openingHour ,er.closingHour ) as varchar(10)) shift ,
	'הערה-'+[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
    ORDER BY er.openingHour ,er.closingHour ) as varchar(10)) shift2
	FROM Employee e
	JOIN x_Dept_Employee de on de.employeeID = e.employeeID
	JOIN Dept d	on de.deptCode = d.deptCode
	LEFT JOIN Dept distr on d.districtCode = distr.deptCode
	JOIN Cities c on d.cityCode = c.cityCode
	LEFT JOIN Streets s	on d.cityCode = s.CityCode 
		AND d.StreetCode = s.StreetCode
	JOIN UnitType ut on d.typeUnitCode = ut.UnitTypeCode
	LEFT JOIN DIC_SubUnitTypes sut on d.subUnitTypeCode = sut.subUnitTypeCode
	LEFT JOIN x_dept_XY dxy	on d.deptCode = dxy.deptCode
	LEFT JOIN deptEmployeeReception er on de.DeptEmployeeID = er.DeptEmployeeID
	LEFT JOIN [DIC_ReceptionDays] on er.receptionDay = [DIC_ReceptionDays].ReceptionDayCode
	LEFT JOIN deptEmployeeReceptionServices ers	on er.receptionID = ers.receptionID
	JOIN [Services] ser	on ers.serviceCode = ser.serviceCode
	LEFT JOIN DIC_AgreementTypes dag on de.AgreementType = dag.AgreementTypeID
	LEFT JOIN DeptEmployeeReceptionRemarks derp	on derp.EmployeeReceptionID = er.receptionID
	where d.status = 1
	AND e.active = 1
	AND de.active = 1
	AND e.EmployeeSectorCode = 7
	AND ser.ServiceCode <> 180300
	AND GETDATE() between ISNULL(er.validFrom,'1900-01-01') 
	AND ISNULL(er.validTo,'2079-01-01') 
 
	-- *********************** - רופאי מושלם ללא אף מרפאה
	-- AND not exists (SELECT COUNT(*) FROM x_Dept_Employee de2 
	--  JOIN Dept d2
	--  on de2.deptCode = d2.deptCode
	--  where de2.employeeID = de.employeeID
	--   --AND d2.cityCode = d.cityCode
	--   AND d2.IsMushlam = 1
	--  group by de2.employeeID)
	---- *********************** - רופאי מושלם שיש להם מרפאות קהילה
	--AND exists (SELECT COUNT(*) FROM x_Dept_Employee de2 
	--  JOIN Dept d2
	--  on de2.deptCode = d2.deptCode
	--  where de2.employeeID = de.employeeID
	--   AND d2.IsCommunity = 1
	--   AND d2.status = 1
	--   AND de2.active = 1
	--  group by de2.employeeID)
	--AND exists (SELECT COUNT(*) FROM x_Dept_Employee de2 
	--  JOIN Dept d2
	--  on de2.deptCode = d2.deptCode
	--  where de2.employeeID = de.employeeID
	--   AND d2.IsMushlam = 1
	--   AND d2.status = 1
	--  group by de2.employeeID)
	---- *********************** - רופאים עם יחידת מושלם וקהילה באותה העיר
	AND d.cityCode in
		(
		SELECT d2.cityCode -- COUNT(de2.deptCode), de2.employeeID
		FROM x_Dept_Employee de2 
		JOIN Dept d2 
			on de2.deptCode = d2.deptCode
		JOIN Employee e2 
			on de2.employeeID = e.employeeID
			AND e2.IsInCommunity = 1 
			AND e2.IsInMushlam = 1
		where e2.employeeID = e.employeeID
		AND d2.cityCode = d.cityCode
		AND d2.status = 1
		AND e2.active = 1
		AND de2.active = 1
		AND exists ( SELECT de3.deptCode FROM x_Dept_Employee de3
					 JOIN dept d3
					 on de3.deptCode = d3.deptCode
					 where de3.employeeID = de.employeeID
					 AND d3.cityCode = d.cityCode
					 AND d3.IsMushlam = 1 )
		AND exists (SELECT COUNT(*) FROM x_Dept_Employee de4 
					JOIN Dept d4
					on de4.deptCode = d4.deptCode
					where de4.employeeID = de.employeeID
					AND d4.cityCode = d.cityCode
					AND d4.IsCommunity = 1
					AND d4.status = 1
					AND de4.active = 1
					group by de4.employeeID )
		 group by d2.cityCode, de2.employeeID
		 having COUNT(de2.deptCode) > 1 )
	-- ******************************************
		AND (	@DistrictCodes = '-1' 
				OR
				(d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
									OR d.DeptCode IN (	SELECT x_Dept_District.DeptCode 
														FROM dbo.SplitString(@DistrictCodes) AS T
														JOIN x_Dept_District ON T.IntField = x_Dept_District.districtCode) 
				)
			) 
		AND (	@AdminClinicCode = '-1' 
				OR
				(d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode )) ) 
			)

		AND (	@CitiesCodes = '-1'
				OR 
				(d.CityCode IN (SELECT IntField FROM dbo.SplitString( @CitiesCodes )) )
			) 

	) a
pivot 
(max(Hours) for shift in ([א-1],[א-2],[א-3],[ב-1],[ב-2],[ב-3],[ג-1],[ג-2],[ג-3],[ד-1],[ד-2],[ד-3],[ה-1],[ה-2],[ה-3],[ו-1],[ו-2],[ו-3],[ש-1],[ש-2],[חג-1],[חג-2],[חוה"מ-1],[חוה"מ-2],[חוה"מ-3],[ערב חג-1],[ערב חג-2])
) AS PivotTable1
pivot 
(max(RemarkText) for shift2 in ([הערה-א-1],[הערה-א-2],[הערה-א-3],[הערה-ב-1],[הערה-ב-2],[הערה-ב-3],[הערה-ג-1],[הערה-ג-2],[הערה-ג-3],[הערה-ד-1],[הערה-ד-2],[הערה-ד-3],[הערה-ה-1],[הערה-ה-2],[הערה-ה-3],[הערה-ו-1],[הערה-ו-2],[הערה-ו-3],[הערה-ש-1],[הערה-ש-2],[הערה-חג-1],[הערה-חג-2],[הערה-חוה"מ-1],[הערה-חוה"מ-2],[הערה-חוה"מ-3],[הערה-ערב חג-1],[הערה-ערב חג-2])
) AS PivotTable2

group by employeeID, doctorName, licenseNumber, deptCode, deptName, AgreementTypeDescription,
    districtName, UnitTypeName, subUnitTypeName, IsCommunity, cityName, 
    street,
    addressComment, profession, professionCode
    
UNION 


SELECT e.employeeID, e.firstName+' '+e.lastName as doctorName, e.licenseNumber,
    d.deptCode, d.deptName, 
    ut.UnitTypeName, sut.subUnitTypeName, 
    CASE WHEN d.IsCommunity = 1 THEN 'קהילה' ELSE 'מושלם' END as 'DeptType',
    at.AgreementTypeDescription, 
    --CASE WHEN (AgreementTypeID in (1, 2)) THEN 'קהילה' 
    --  WHEN (AgreementTypeID in (3, 4)) THEN 'מושלם'
    --  ELSE 'בית חולים' END as AgreementTypeDescription,
    distr.deptName as districtName, 
    c.cityName, 
    --CASE WHEN d.StreetCode is null THEN d.streetName ELSE s.Name END as street,
    --d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
    --dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
    CASE WHEN d.streetName is null THEN '' ELSE d.streetName END + ' ' + 
    CASE WHEN d.addressComment is null THEN '' ELSE d.addressComment END as 'address',
    prof.ServiceDescription as profession,
	prof.ServiceCode as professionCode,
'' as [alef1],'' as [alef2],'' as [alef3],'' as [bet1],'' as [bet2],'' as [bet3], '' as [gim1],'' as [gim2],'' as [gim3],'' as [dal1],'' as [dal2],'' as [dal3],'' as [hey1],'' as [hey2],'' as [hey3],'' as [vav1],'' as [vav2],'' as [vav3],'' as [hag1],'' as [hag2],'' as [hoham1],'' as [hoham2],'' as [hoham3],'' as [erevh1],'' as [erevh2],'' as [sh1],'' as [sh2],
'' as [alef1r],'' as [alef2r],'' as [alef3r],'' as [bet1r],'' as [bet2r],'' as [bet3r],'' as [gim1r],'' as [gim2r],'' as [gim3r],'' as [dal1r],'' as [dal2r],'' as [dal3r],'' as [hey1r],'' as [hey2r],'' as [hey3r],'' as [vav1r],'' as [vav2r],'' as [vav3r],'' as [hag1r],'' as [hag2r],'' as [hoham1r],'' as [hoham2r],'' as [hoham3r],'' as [erevh1r],'' as [erevh2r],'' as [sh1r],'' as [sh2r]

FROM Employee e
JOIN x_Dept_Employee de on de.employeeID = e.employeeID
JOIN Dept d	on de.deptCode = d.deptCode
LEFT JOIN Dept distr on d.districtCode = distr.deptCode
JOIN Cities c on d.cityCode = c.cityCode
LEFT JOIN Streets s	on d.cityCode = s.CityCode 
	AND d.StreetCode = s.StreetCode
JOIN DIC_AgreementTypes at on de.AgreementType = at.AgreementTypeID
JOIN UnitType ut on d.typeUnitCode = ut.UnitTypeCode
LEFT JOIN DIC_SubUnitTypes sut on d.subUnitTypeCode = sut.subUnitTypeCode
LEFT JOIN x_dept_XY dxy	on d.deptCode = dxy.deptCode
JOIN x_Dept_Employee_Service dep on de.DeptEmployeeID = dep.DeptEmployeeID 
JOIN [Services] prof on dep.serviceCode = prof.ServiceCode
LEFT JOIN DIC_AgreementTypes dag				--???????????????????????
	on de.AgreementType = dag.AgreementTypeID
where d.status = 1
AND e.active = 1
AND de.active = 1
AND e.EmployeeSectorCode = 7
AND dep.serviceCode not in (SELECT serviceCode
							FROM deptEmployeeReceptionServices rp1 
							LEFT JOIN deptEmployeeReception er1
								on er1.receptionID = rp1.receptionID
							where er1.DeptEmployeeID = de.DeptEmployeeID)
AND dep.serviceCode <> 180300
---- *********************** - רופאים עם יחידת מושלם וקהילה באותה העיר
AND d.cityCode in
	(
	SELECT d2.cityCode -- COUNT(de2.deptCode), de2.employeeID
	FROM x_Dept_Employee de2 
	JOIN Dept d2
		on de2.deptCode = d2.deptCode
	JOIN Employee e2
		on de2.employeeID = e.employeeID		--???????????????
		AND e2.IsInCommunity = 1 AND e2.IsInMushlam = 1
	where e2.employeeID = e.employeeID
	AND d2.cityCode = d.cityCode
	AND d2.status = 1
	AND e2.active = 1
	AND de2.active = 1
	AND exists (SELECT de3.deptCode 
				FROM x_Dept_Employee de3
				JOIN dept d3
					on de3.deptCode = d3.deptCode
				where de3.employeeID = de.employeeID
				AND d3.cityCode = d.cityCode
				AND d3.IsMushlam = 1)
	) 
	AND (	@DistrictCodes = '-1' 
			OR
			(d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
								OR d.DeptCode IN (	SELECT x_Dept_District.DeptCode 
													FROM dbo.SplitString(@DistrictCodes) AS T
													JOIN x_Dept_District ON T.IntField = x_Dept_District.districtCode) 
			)
		) 
	AND (	@AdminClinicCode = '-1' 
			OR
			(d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode )) ) 
		)

	AND (	@CitiesCodes = '-1'
			OR 
			(d.CityCode IN (SELECT IntField FROM dbo.SplitString( @CitiesCodes )) )
		) 
GO

GRANT EXEC ON [dbo].rprt_DeptEmployeeAndPharmacyReceptionDifferences TO PUBLIC
GO