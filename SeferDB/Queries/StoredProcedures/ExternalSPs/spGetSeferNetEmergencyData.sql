IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetSeferNetEmergencyData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetSeferNetEmergencyData]
GO

CREATE PROC [dbo].[spGetSeferNetEmergencyData]
AS

select  DISTINCT xde.deptCode, xdes.serviceCode
INTO #svc
FROM x_Dept_Employee_Service xdes
join x_Dept_Employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
join Employee e on xde.employeeID = e.employeeID
where xdes.Status = 1	and xde.active = 1 and e.active = 1


CREATE CLUSTERED INDEX IX_SVC_TMP ON #svc (deptCode,serviceCode)

	select 1 as Medical_Institute_code, d.deptCode as Clinic_Code, d.deptName as Clinic_Desc, 
		d.cityCode as Code_City, d.districtCode as Region_Code, distr.deptName as Region_Desc, 
		d.districtCode as Area_Code,  distr.deptName as Area_Desc, 
		isnull(d.StreetCode, 0) as Street_Code, d.streetName as Street_Name, 
		isnull(d.house, 0) as House_Num, d.zipCode as Zip_Code, 
		((dxy.xcoord * 1000) + 50000) as Code_X, ((dxy.ycoord * 1000) + 500000) as Code_Y, 1 as Type_X_Y, 
		
		isnull(d.HasElectricalPanel, 0) as Electrical_Panel_YN_Code, 
		isnull(d.HasGenerator, 0) as Generator_YN_Code, 
		isnull(d.IsUnifiedClinic, 0) as Unified_Clinic_YN_Code


		, cHours.OldClinicCode, cHours.UnitTypeCode, cHours.UnitTypeName
		, cHours.OpeningHour1, cHours.ClosingHour1, cHours.OpeningHour2, cHours.ClosingHour2
		,d.deptcode
		,d.DefencePolicyCode
		,d.TypeOfDefenceCode
INTO #tmp
	from dept d 
	join Dept distr on d.districtCode = distr.deptCode
	left join x_dept_XY dxy on d.deptCode = dxy.deptCode
	join [vClalitUdActiveClinics] cHours on d.deptCode = cHours.NewClinicCode
		where d.status = 1 
		and (d.typeUnitCode BETWEEN 101 AND 103  OR 
				d.typeUnitCode = 501
				OR (d.typeUnitCode = 212 
					and exists (select 1 
								from #svc xdes
								where xdes.serviceCode in (2, 40)
									and xdes.deptCode = d.deptCode
									)
					)

			)


SELECT Medical_Institute_code,
       Clinic_Code,
       Clinic_Desc,
       Code_City,
       Region_Code,
       Region_Desc,
       Area_Code,
       Area_Desc,
       Street_Code,
       Street_Name,
       House_Num,
       Zip_Code,
       Code_X,
       Code_Y,
       Type_X_Y,
	   dbo.GetDeptPhoneNumber(d.deptcode, 1, 1) AS Phone1, 
		dbo.GetDeptPhoneNumber(d.deptcode, 1, 2) AS Phone2,  
		dbo.GetDeptPhoneNumber(d.deptcode, 2, 1) AS Fax, 
			
			ISNULL((SELECT TOP 1 1 FROM #svc xdes
				WHERE xdes.serviceCode = 2 AND xdes.deptCode = d.deptCode
					)
			, 0) AS Family_Doc_YN, -- ServiceCode = 2

		ISNULL((SELECT TOP 1 1 FROM #svc xdes
				WHERE xdes.serviceCode = 659 AND xdes.deptCode = d.deptCode
					)
			, 0) AS Nurse_YN, -- ServiceCode = 659
		ISNULL((SELECT TOP 1 1 FROM #svc xdes
				WHERE xdes.serviceCode = 40 AND xdes.deptCode = d.deptCode
					)
			, 0) AS Pediatrician_YN, -- ServiceCode = 40
		ISNULL((SELECT TOP 1 1 FROM #svc xdes
				WHERE xdes.serviceCode = 63 AND xdes.deptCode = d.deptCode
					)
			, 0) AS Gynecologist_YN, -- ServiceCode = 63

		CAST(ISNULL((SELECT TOP 1 1 FROM Dept dPharm
				WHERE dPharm.subAdministrationCode = d.deptCode
					AND dPharm.typeUnitCode = 401 AND dPharm.status = 1)
			, 0) AS BIT) AS Pharmacy_YN, 
		ISNULL(d.TypeOfDefenceCode, -999) AS Type_Defense_Code, 
		ISNULL(d.DefencePolicyCode, -999) AS Defense_policy_Code, 
		CAST(ISNULL((SELECT TOP 1 1 FROM DeptHandicappedFacilities dHF
				WHERE dHF.DeptCode = d.deptCode AND dhf.FacilityCode = 1)
			, 0) AS BIT) AS Disabled_Access_YN_Code, 

       Electrical_Panel_YN_Code,
       Generator_YN_Code,
       Unified_Clinic_YN_Code,
       OldClinicCode,
       UnitTypeCode,
       UnitTypeName,
       OpeningHour1,
       ClosingHour1,
       OpeningHour2,
       ClosingHour2 
FROM #tmp AS d

GO

GRANT EXEC ON dbo.spGetSeferNetEmergencyData TO [clalit\webuser]
GO

GRANT EXEC ON dbo.spGetSeferNetEmergencyData TO [clalit\IntranetDev]
GO
