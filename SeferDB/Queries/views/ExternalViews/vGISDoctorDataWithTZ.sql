CREATE view [dbo].[vGISDoctorDataWithTZ]
as

with phones as (
	SELECT CASE WHEN esp.phone is NOT null 
				THEN dbo.fun_ParsePhoneNumberWithExtension(esp.prePrefix, esp.prefix, esp.phone, esp.extension ) 
				ELSE 
					CASE WHEN dep.phone is NOT null 
					THEN dbo.fun_ParsePhoneNumberWithExtension(dep.prePrefix, dep.prefix, dep.phone, dep.extension ) 
					ELSE 
						CASE WHEN dp.phone is NOT null 
						THEN dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension ) 
						ELSE 
						''
						END
					END
				END as phone1
			
		,CASE WHEN (esp2.phone is NOT null)
				THEN dbo.fun_ParsePhoneNumberWithExtension(esp2.prePrefix, esp2.prefix, esp2.phone, esp2.extension ) 
				ELSE 
					CASE WHEN (dep2.phone is NOT null AND esp.phone is null) 
					THEN dbo.fun_ParsePhoneNumberWithExtension(dep2.prePrefix, dep2.prefix, dep2.phone, dep2.extension ) 
					ELSE 
						CASE WHEN (dp2.phone is NOT null AND esp.phone is null AND dep.phone is null)
						THEN dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.prefix, dp2.phone, dp2.extension ) 
						ELSE 
						''
						END
					END
				END as phone2
		,CASE WHEN (esp3.phone is NOT null)
				THEN dbo.fun_ParsePhoneNumberWithExtension(esp3.prePrefix, esp3.prefix, esp3.phone, esp3.extension ) 
				ELSE 
					CASE WHEN (dep3.phone is NOT null AND esp.phone is null AND esp2.phone is null) 
					THEN dbo.fun_ParsePhoneNumberWithExtension(dep3.prePrefix, dep3.prefix, dep3.phone, dep3.extension ) 
					ELSE 
						CASE WHEN (dp3.phone is NOT null AND esp.phone is null AND dep.phone is null AND esp2.phone is null AND dep2.phone is null)
						THEN dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.prefix, dp3.phone, dp3.extension ) 
						ELSE 
						''
						END
					END
				END as phone3				
		,CASE WHEN esp4.phone is NOT null 
				THEN dbo.fun_ParsePhoneNumberWithExtension(esp4.prePrefix, esp4.prefix, esp4.phone, esp4.extension ) 
				ELSE 
					CASE WHEN dep4.phone is NOT null 
					THEN dbo.fun_ParsePhoneNumberWithExtension(dep4.prePrefix, dep4.prefix, dep4.phone, dep4.extension ) 
					ELSE 
						CASE WHEN dp4.phone is NOT null 
						THEN dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.prefix, dp4.phone, dp4.extension ) 
						ELSE 
						''
						END
					END
				END as fax
				
	,xdes.serviceCode, xde.DeptEmployeeID, xde.deptCode
	--INTO #phones
	FROM x_Dept_Employee_Service xdes
	JOIN x_Dept_Employee xde ON xdes.DeptEmployeeID = xde.DeptEmployeeID

	LEFT JOIN DeptPhones dp ON xde.deptCode = dp.deptCode
		AND dp.phoneType = 1 AND dp.phoneOrder = 1
	LEFT JOIN DeptEmployeePhones dep ON xde.DeptEmployeeID = dep.DeptEmployeeID
		AND dep.phoneType = 1 AND dep.phoneOrder = 1
	LEFT JOIN EmployeeServicePhones esp ON xdes.x_Dept_Employee_ServiceID = esp.x_Dept_Employee_ServiceID
		AND esp.phoneType = 1 AND esp.phoneOrder = 1
	----------------				
	LEFT JOIN DeptPhones dp2 ON xde.deptCode = dp2.deptCode
		AND dp2.phoneType = 1 AND dp2.phoneOrder = 2
	LEFT JOIN DeptEmployeePhones dep2 ON xde.DeptEmployeeID = dep2.DeptEmployeeID
		AND dep2.phoneType = 1 AND dep2.phoneOrder = 2
	LEFT JOIN EmployeeServicePhones esp2 ON xdes.x_Dept_Employee_ServiceID = esp2.x_Dept_Employee_ServiceID
		AND esp2.phoneType = 1 AND esp2.phoneOrder = 2	
	--------------------
	LEFT JOIN DeptPhones dp3 ON xde.deptCode = dp3.deptCode
		AND dp3.phoneType = 1 AND dp3.phoneOrder = 3
	LEFT JOIN DeptEmployeePhones dep3 ON xde.DeptEmployeeID = dep3.DeptEmployeeID
		AND dep3.phoneType = 1 AND dep3.phoneOrder = 3
	LEFT JOIN EmployeeServicePhones esp3 ON xdes.x_Dept_Employee_ServiceID = esp3.x_Dept_Employee_ServiceID
		AND esp3.phoneType = 1 AND esp3.phoneOrder = 3		
	--------------------
	LEFT JOIN DeptPhones dp4 ON xde.deptCode = dp4.deptCode
		AND dp4.phoneType = 2 AND dp4.phoneOrder = 1
	LEFT JOIN DeptEmployeePhones dep4 ON xde.DeptEmployeeID = dep4.DeptEmployeeID
		AND dep4.phoneType = 2 AND dep4.phoneOrder = 1
	LEFT JOIN EmployeeServicePhones esp4 ON xdes.x_Dept_Employee_ServiceID = esp4.x_Dept_Employee_ServiceID
		AND esp4.phoneType = 2 AND esp4.phoneOrder = 1			
	-- ********************************************
)
(
select  EmployeeID, DegreeName as Title, firstName as FirstName, lastName as LastName
		, firstName + ' ' + lastName as Name /*doctorName*/
		, firstName_MF, lastName_MF
		, deptcode, deptName as Clinic, 
		case when (AgreementTypeID in (1, 2)) then 'קהילה' 
				when (AgreementTypeID in (3, 4)) then 'מושלם'
				else 'בית חולים' end as AgreementTypeDescription,
		deptTypeName, ISNULL(deptSubTypeName,'') as deptSubTypeName,
		districtName, cityName as City, 
		street as Street, house, SUBSTRING(addressComment, 0, 250) as addressComment, 
		zipCode, SUBSTRING(REPLACE(REPLACE(dbo.GetAddress(deptcode), CHAR(13), ' '), CHAR(10), ''), 0, 250) as FullAddress, xcoord, ycoord, 
		Phone1, Phone2, Phone3, Fax,
		serviceDescription as Expertise, Language, Accessibility, PublicTransport,
		AppointmentByNet,
max([Sunday_From1]) as [Sunday_From1],max([Sunday_To1]) as [Sunday_To1], max('') as [Sunday_Freq1],max([Sunday_Comm1]) as [Sunday_Comm1],max([Sunday_From2]) as [Sunday_From2],max([Sunday_To2]) as [Sunday_To2], max('') as [Sunday_Freq2],max([Sunday_Comm2]) as [Sunday_Comm2],max([Sunday_From3]) as [Sunday_From3],max([Sunday_To3]) as [Sunday_To3], max('') as [Sunday_Freq3],max([Sunday_Comm3]) as [Sunday_Comm3],
max([Monday_From1]) as [Monday_From1],max([Monday_To1]) as [Monday_To1], max('') as [Monday_Freq1],max([Monday_Comm1]) as [Monday_Comm1],max([Monday_From2]) as [Monday_From2],max([Monday_To2]) as [Monday_To2], max('') as [Monday_Freq2],max([Monday_Comm2]) as [Monday_Comm2],max([Monday_From3]) as [Monday_From3],max([Monday_To3]) as [Monday_To3], max('') as [Monday_Freq3],max([Monday_Comm3]) as [Monday_Comm3],
max([Tuesday_From1]) as [Tuesday_From1],max([Tuesday_To1]) as [Tuesday_To1], max('') as [Tuesday_Freq1],max([Tuesday_Comm1]) as [Tuesday_Comm1],max([Tuesday_From2]) as [Tuesday_From2],max([Tuesday_To2]) as [Tuesday_To2], max('') as [Tuesday_Freq2],max([Tuesday_Comm2]) as [Tuesday_Comm2],max([Tuesday_From3]) as [Tuesday_From3],max([Tuesday_To3]) as [Tuesday_To3], max('') as [Tuesday_Freq3],max([Tuesday_Comm3]) as [Tuesday_Comm3],
max([Wednesday_From1]) as [Wednesday_From1],max([Wednesday_To1]) as [Wednesday_To1], max('') as [Wednesday_Freq1],max([Wednesday_Comm1]) as [Wednesday_Comm1],max([Wednesday_From2]) as [Wednesday_From2],max([Wednesday_To2]) as [Wednesday_To2], max('') as [Wednesday_Freq2],max([Wednesday_Comm2]) as [Wednesday_Comm2],max([Wednesday_From3]) as [Wednesday_From3],max([Wednesday_To3]) as [Wednesday_To3], max('') as [Wednesday_Freq3],max([Wednesday_Comm3]) as [Wednesday_Comm3],
max([Thursday_From1]) as [Thursday_From1],max([Thursday_To1]) as [Thursday_To1], max('') as [Thursday_Freq1],max([Thursday_Comm1]) as [Thursday_Comm1],max([Thursday_From2]) as [Thursday_From2],max([Thursday_To2]) as [Thursday_To2], max('') as [Thursday_Freq2],max([Thursday_Comm2]) as [Thursday_Comm2],max([Thursday_From3]) as [Thursday_From3],max([Thursday_To3]) as [Thursday_To3], max('') as [Thursday_Freq3],max([Thursday_Comm3]) as [Thursday_Comm3],
max([Friday_From1]) as [Friday_From1],max([Friday_To1]) as [Friday_To1], max('') as [Friday_Freq1],max([Friday_Comm1]) as [Friday_Comm1],max([Friday_From2]) as [Friday_From2],max([Friday_To2]) as [Friday_To2], max('') as [Friday_Freq2],max([Friday_Comm2]) as [Friday_Comm2],max([Friday_From3]) as [Friday_From3],max([Friday_To3]) as [Friday_To3], max('') as [Friday_Freq3],max([Friday_Comm3]) as [Friday_Comm3],
max([Saturday_From1]) as [Saturday_From1],max([Saturday_To1]) as [Saturday_To1], max('') as [Saturday_Freq1],max([Saturday_Comm1]) as [Saturday_Comm1],max([Saturday_From2]) as [Saturday_From2],max([Saturday_To2]) as [Saturday_To2], max('') as [Saturday_Freq2],max([Saturday_Comm2]) as [Saturday_Comm2],
max([HolHamoeed_From1]) as [HolHamoeed_From1],max([HolHamoeed_To1]) as [HolHamoeed_To1], max('') as [HolHamoeed_Freq1],max([HolHamoeed_Comm1]) as [HolHamoeed_Comm1],max([HolHamoeed_From2]) as [HolHamoeed_From2],max([HolHamoeed_To2]) as [HolHamoeed_To2], max('') as [HolHamoeed_Freq2],max([HolHamoeed_Comm2]) as [HolHamoeed_Comm2],
max([HolidayEvening_From1]) as [HolidayEvening_From1],max([HolidayEvening_To1]) as [HolidayEvening_To1], max('') as [HolidayEvening_Freq1],max([HolidayEvening_Comm1]) as [HolidayEvening_Comm1],max([HolidayEvening_From2]) as [HolidayEvening_From2],max([HolidayEvening_To2]) as [HolidayEvening_To2], max('') as [HolidayEvening_Freq2],max([HolidayEvening_Comm2]) as [HolidayEvening_Comm2],
max([Holiday_From1]) as [Holiday_From1], max([Holiday_To1]) as [Holiday_To1], max('') as [Holiday_Freq1],max([Holiday_Comm1]) as [Holiday_Comm1],max([Holiday_From2]) as [Holiday_From2],max([Holiday_To2]) as [Holiday_To2], max('') as [Holiday_Freq2],max([Holiday_Comm2]) as [Holiday_Comm2]
 from 
(select
				e.firstName, e.lastName, ed.DegreeName,
				e.firstName_MF, e.lastName_MF, e.employeeID,
				d.deptCode, d.deptName, dag.AgreementTypeID,
				ut.UnitTypeName as deptTypeName, sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, REPLACE(REPLACE(d.addressComment, CHAR(13), ' '), CHAR(10), '') as addressComment, 
				d.zipCode, dxy.xcoord, dxy.ycoord,
				phones.Phone1,
				phones.Phone2,	
				phones.Phone3,					
				phones.Fax,					
				ser.serviceDescription, dbo.fun_GetEmployeeLanguages(e.employeeID) as Language,
				dbo.fun_GetClinicHandicappedFacilities(d.deptCode) as Accessibility,
				d.transportation as PublicTransport, 
				case when dq.QueueOrderMethod = 4 then 'כן' else '' end as AppointmentByNet,
				er.receptionDay, er.openingHour , er.closingHour ,
				[DIC_ReceptionDays].ReceptionDayName, derp.RemarkText,
row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode ,er.receptionDay 
					order by er.openingHour ,er.closingHour )rn,
[DIC_ReceptionDays].EnumName+'_From'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift ,
[DIC_ReceptionDays].EnumName+'_To'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift1 ,
[DIC_ReceptionDays].EnumName+'_Comm'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift2 ,
[DIC_ReceptionDays].EnumName+'_Freq'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift3 
from Employee e
join x_Dept_Employee de
on de.employeeID = e.employeeID
join Dept d
on de.deptCode = d.deptCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy on d.deptCode = dxy.deptCode
join UnitType ut on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut on d.subUnitTypeCode = sut.subUnitTypeCode
left join EmployeeQueueOrderMethod dq on dq.DeptEmployeeID = de.DeptEmployeeID and dq.QueueOrderMethod = 4
left join deptEmployeeReception er
on de.DeptEmployeeID = er.DeptEmployeeID
left join [DIC_ReceptionDays]
on er.receptionDay = [DIC_ReceptionDays].ReceptionDayCode
left join deptEmployeeReceptionServices ers
on er.receptionID = ers.receptionID
join Services ser
on ers.serviceCode = ser.serviceCode
left join DIC_AgreementTypes dag
on de.AgreementType = dag.AgreementTypeID
left join DeptEmployeeReceptionRemarks derp
on derp.EmployeeReceptionID = er.receptionID
left join DIC_EmployeeDegree ed on e.degreeCode = ed.DegreeCode
LEFT JOIN phones ON de.DeptEmployeeID = phones.DeptEmployeeID
	AND ser.ServiceCode = phones.serviceCode
where d.status = 1
and e.active = 1
and de.active = 1
and e.EmployeeSectorCode = 7
and GETDATE() between ISNULL(er.validFrom,'1900-01-01') 
and ISNULL(er.validTo,'2079-01-01')  
) a
pivot 
(max(openingHour) for shift in ([Sunday_From1],[Sunday_From2],[Sunday_From3],[Monday_From1],[Monday_From2],[Monday_From3],[Tuesday_From1],[Tuesday_From2],[Tuesday_From3],[Wednesday_From1],[Wednesday_From2],[Wednesday_From3],[Thursday_From1],[Thursday_From2],[Thursday_From3],[Friday_From1],[Friday_From2],[Friday_From3],[Saturday_From1],[Saturday_From2],[HolHamoeed_From1],[HolHamoeed_From2],[HolidayEvening_From1],[HolidayEvening_From2],[Holiday_From1],[Holiday_From2])
) AS PivotTable1
pivot 
(max(closingHour) for shift1 in ([Sunday_To1],[Sunday_To2],[Sunday_To3],[Monday_To1],[Monday_To2],[Monday_To3],[Tuesday_To1],[Tuesday_To2],[Tuesday_To3],[Wednesday_To1],[Wednesday_To2],[Wednesday_To3],[Thursday_To1],[Thursday_To2],[Thursday_To3],[Friday_To1],[Friday_To2],[Friday_To3],[Saturday_To1],[Saturday_To2],[HolHamoeed_To1],[HolHamoeed_To2],[HolidayEvening_To1],[HolidayEvening_To2],[Holiday_To1],[Holiday_To2])
) AS PivotTable2
pivot 
(max(RemarkText) for shift2 in ([Sunday_Comm1],[Sunday_Comm2],[Sunday_Comm3],[Monday_Comm1],[Monday_Comm2],[Monday_Comm3],[Tuesday_Comm1],[Tuesday_Comm2],[Tuesday_Comm3],[Wednesday_Comm1],[Wednesday_Comm2],[Wednesday_Comm3],[Thursday_Comm1],[Thursday_Comm2],[Thursday_Comm3],[Friday_Comm1],[Friday_Comm2],[Friday_Comm3],[Saturday_Comm1],[Saturday_Comm2],[HolHamoeed_Comm1],[HolHamoeed_Comm2],[HolidayEvening_Comm1],[HolidayEvening_Comm2],[Holiday_Comm1],[Holiday_Comm2])
) AS PivotTable4
group by firstName, lastName, DegreeName, firstName_MF, lastName_MF, employeeID, deptCode, 
				deptName, AgreementTypeID, deptTypeName, deptSubTypeName, districtName, 
				cityName, street, house, addressComment, zipCode, xcoord, ycoord,
				Phone1, Phone2, Phone3, Fax, serviceDescription, Language, 
				Accessibility, PublicTransport, AppointmentByNet


union 

select	
/*
		serviceDescription as Expertise, Language, Accessibility, PublicTransport,
		AppointmentByNet,*/
				e.employeeID ,ed.DegreeName as Title, e.firstName as FirstName, e.lastName as LastName,
				e.firstName+' '+e.lastName as Name, /*doctorName*/
				e.firstName_MF, e.lastName_MF,
				d.deptCode, d.deptName as Clinic, 
				case when (AgreementTypeID in (1, 2)) then 'קהילה' 
					 when (AgreementTypeID in (3, 4)) then 'מושלם'
					 else 'בית חולים' end as AgreementTypeDescription,
				ut.UnitTypeName as deptTypeName, sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName as City, 
				case when d.StreetCode is null then d.streetName else s.Name end as Street,
				d.house, SUBSTRING(REPLACE(REPLACE(d.addressComment, CHAR(13), ' '), CHAR(10), ''), 0, 250) as addressComment, 
				d.zipCode, SUBSTRING(REPLACE(REPLACE(dbo.GetAddress(d.deptcode), CHAR(13), ' '), CHAR(10), ''), 0, 250) as FullAddress, 
				dxy.xcoord, dxy.ycoord,
				phones.Phone1,
				phones.Phone2,	
				phones.Phone3,					
				phones.Fax,	
				prof.ServiceDescription  as Expertise, 
				dbo.fun_GetEmployeeLanguages(e.employeeID) as Language, 
				dbo.fun_GetClinicHandicappedFacilities(d.deptCode) as Accessibility, 
				d.transportation as PublicTransport,
				case when dq.QueueOrderMethod = 4 then 'כן' else '' end as AppointmentByNet,
'' as [Sunday_From1],'' as [Sunday_To1], '' as [Sunday_Freq1],'' as [Sunday_Comm1],'' as [Sunday_From2],'' as [Sunday_To2], '' as [Sunday_Freq2],'' as [Sunday_Comm2],'' as [Sunday_From3],'' as [Sunday_To3], '' as [Sunday_Freq3],'' as [Sunday_Comm3],
'' as [Monday_From1],'' as [Monday_To1], '' as [Monday_Freq1],'' as [Monday_Comm1],'' as [Monday_From2],'' as [Monday_To2], '' as [Monday_Freq2],'' as [Monday_Comm2],'' as [Monday_From3],'' as [Monday_To3], '' as [Monday_Freq3],'' as [Monday_Comm3],
'' as [Tuesday_From1],'' as [Tuesday_To1], '' as [Tuesday_Freq1],'' as [Tuesday_Comm1],'' as [Tuesday_From2],'' as [Tuesday_To2], '' as [Tuesday_Freq2],'' as [Tuesday_Comm2],'' as [Tuesday_From3],'' as [Tuesday_To3], '' as [Tuesday_Freq3],'' as [Tuesday_Comm3],
'' as [Wednesday_From1],'' as [Wednesday_To1], '' as [Wednesday_Freq1],'' as [Wednesday_Comm1],'' as [Wednesday_From2],'' as [Wednesday_To2], '' as [Wednesday_Freq2],'' as [Wednesday_Comm2],'' as [Wednesday_From3],'' as [Wednesday_To3], '' as [Wednesday_Freq3],'' as [Wednesday_Comm3],
'' as [Thursday_From1],'' as [Thursday_To1], '' as [Thursday_Freq1],'' as [Thursday_Comm1],'' as [Thursday_From2],'' as [Thursday_To2], '' as [Thursday_Freq2],'' as [Thursday_Comm2],'' as [Thursday_From3],'' as [Thursday_To3], '' as [Thursday_Freq3],'' as [Thursday_Comm3],
'' as [Friday_From1],'' as [Friday_To1], '' as [Friday_Freq1],'' as [Friday_Comm1],'' as [Friday_From2],'' as [Friday_To2], '' as [Friday_Freq2],'' as [Friday_Comm2],'' as [Friday_From3],'' as [Friday_To3], '' as [Friday_Freq3],'' as [Friday_Comm3],
'' as [Saturday_From1],'' as [Saturday_To1], '' as [Saturday_Freq1],'' as [Saturday_Comm1],'' as [Saturday_From2],'' as [Saturday_To2], '' as [Saturday_Freq2],'' as [Saturday_Comm2],
'' as [HolHamoeed_From1],'' as [HolHamoeed_To1], '' as [HolHamoeed_Freq1],'' as [HolHamoeed_Comm1],'' as [HolHamoeed_From2],'' as [HolHamoeed_To2], '' as [HolHamoeed_Freq2],'' as [HolHamoeed_Comm2],
'' as [HolidayEvening_From1],'' as [HolidayEvening_To1], '' as [HolidayEvening_Freq2],'' as [HolidayEvening_Comm1],'' as [HolidayEvening_From2],'' as [HolidayEvening_To2], '' as [HolidayEvening_Freq2],'' as [HolidayEvening_Comm2],
'' as [Holiday_From1],'' as [Holiday_To1], '' as [Holiday_Freq1],'' as [Holiday_Comm1],'' as [Holiday_From2],'' as [Holiday_To2], '' as [Holiday_Freq2],'' as [Holiday_Comm2]
from Employee e
join x_Dept_Employee de
on de.employeeID = e.employeeID
join Dept d
on de.deptCode = d.deptCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
join UnitType ut on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut on d.subUnitTypeCode = sut.subUnitTypeCode
left join EmployeeQueueOrderMethod dq on dq.DeptEmployeeID = de.DeptEmployeeID and dq.QueueOrderMethod = 4
join x_Dept_Employee_Service dep
on de.DeptEmployeeID = dep.DeptEmployeeID 
join Services prof
on dep.serviceCode = prof.ServiceCode
left join DIC_AgreementTypes dag
on de.AgreementType = dag.AgreementTypeID
left join DIC_EmployeeDegree ed on e.degreeCode = ed.DegreeCode
LEFT JOIN phones ON dep.DeptEmployeeID = phones.DeptEmployeeID
	AND dep.ServiceCode = phones.serviceCode
where d.status = 1
and e.active = 1
and de.active = 1
and e.EmployeeSectorCode = 7
and dep.serviceCode not in (select serviceCode
								from deptEmployeeReceptionServices rp1 
								left join deptEmployeeReception er1
								on er1.receptionID = rp1.receptionID
								where er1.DeptEmployeeID = de.DeptEmployeeID)
)
--order by firstName, lastName, clinic

GO


