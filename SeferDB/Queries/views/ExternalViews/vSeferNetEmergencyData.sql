CREATE view [dbo].[vSeferNetEmergencyData]
as

	select 1 as Medical_Institute_code, d.deptCode as Clinic_Code, d.deptName as Clinic_Desc, 
		d.cityCode as Code_City, d.districtCode as Region_Code, distr.deptName as Region_Desc, 
		d.districtCode as Area_Code,  distr.deptName as Area_Desc, 
		isnull(d.StreetCode, 0) as Street_Code, d.streetName as Street_Name, 
		isnull(d.house, 0) as House_Num, d.zipCode as Zip_Code, 
		((dxy.xcoord * 1000) + 50000) as Code_X, ((dxy.ycoord * 1000) + 500000) as Code_Y, 1 as Type_X_Y, 
		dbo.GetDeptPhoneNumber(d.deptcode, 1, 1) as Phone1, 
		dbo.GetDeptPhoneNumber(d.deptcode, 1, 2) as Phone2,  
		dbo.GetDeptPhoneNumber(d.deptcode, 2, 1) as Fax, 
		isnull((select top 1 1 from x_Dept_Employee_Service xdes
				join x_Dept_Employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
				join Employee e on xde.employeeID = e.employeeID
				where xdes.serviceCode = 2 and xde.deptCode = d.deptCode
					and xdes.Status = 1	and xde.active = 1 and e.active = 1)
			, 0) as Family_Doc_YN, -- ServiceCode = 2
		isnull((select top 1 1 from x_Dept_Employee_Service xdes
				join x_Dept_Employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
				join Employee e on xde.employeeID = e.employeeID
				where xdes.serviceCode = 659 and xde.deptCode = d.deptCode
					and xdes.Status = 1	and xde.active = 1 and e.active = 1)
			, 0) as Nurse_YN, -- ServiceCode = 659
		isnull((select top 1 1 from x_Dept_Employee_Service xdes
				join x_Dept_Employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
				join Employee e on xde.employeeID = e.employeeID
				where xdes.serviceCode = 40 and xde.deptCode = d.deptCode
					and xdes.Status = 1	and xde.active = 1 and e.active = 1)
			, 0) as Pediatrician_YN, -- ServiceCode = 40
		isnull((select top 1 1 from x_Dept_Employee_Service xdes
				join x_Dept_Employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
				join Employee e on xde.employeeID = e.employeeID
				where xdes.serviceCode = 63 and xde.deptCode = d.deptCode
					and xdes.Status = 1	and xde.active = 1 and e.active = 1)
			, 0) as Gynecologist_YN, -- ServiceCode = 63
		cast(isnull((select top 1 1 from Dept dPharm
				where dPharm.subAdministrationCode = d.deptCode
					and dPharm.typeUnitCode = 401 and dPharm.status = 1)
			, 0) as bit) as Pharmacy_YN, 
		isnull(d.TypeOfDefenceCode, -999) as Type_Defense_Code, 
		isnull(d.DefencePolicyCode, -999) as Defense_policy_Code, 
		cast(isnull((select top 1 1 from DeptHandicappedFacilities dHF
				where dHF.DeptCode = d.deptCode and dhf.FacilityCode = 1)
			, 0) as bit) as Disabled_Access_YN_Code, 
		isnull(d.HasElectricalPanel, 0) as Electrical_Panel_YN_Code, 
		isnull(d.HasGenerator, 0) as Generator_YN_Code, 
		isnull(d.IsUnifiedClinic, 0) as Unified_Clinic_YN_Code


		, cHours.OldClinicCode, cHours.UnitTypeCode, cHours.UnitTypeName
		, cHours.OpeningHour1, cHours.ClosingHour1, cHours.OpeningHour2, cHours.ClosingHour2

	from dept d 
	join Dept distr on d.districtCode = distr.deptCode
	left join x_dept_XY dxy on d.deptCode = dxy.deptCode
	join [vClalitUdActiveClinics] cHours on d.deptCode = cHours.NewClinicCode
		where d.status = 1 
		and (d.typeUnitCode BETWEEN 101 AND 103  OR 
				d.typeUnitCode = 501
				OR (d.typeUnitCode = 212 
					and exists (select 1 
								from x_Dept_Employee_Service xdes
								join x_Dept_Employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
								join Employee e on xde.employeeID = e.employeeID
								where xdes.serviceCode in (2, 40)
									and xde.deptCode = d.deptCode
									and xdes.Status = 1
									and xde.active = 1
									and e.active = 1)
					)
			)

--and d.deptcode = 161300

GO
