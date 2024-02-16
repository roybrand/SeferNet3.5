/*
נתוני רופאים עם קואורדינטות עבור רופא ראשי - מערכת GIS
יש לשלוף אך ורק יחידות + רופאים פעילים
*/

/*
א.	שם רופא
ב.	שם מרפאה
ג. קוד ושם סוג הסכם
ד. סה"כ שעות קבלה
ה.	מקצוע
ו.	טלפון
ז.	שעות קבלה 
ח. הערות לשעות
*/

USE [SeferNet]
GO


ALTER view [dbo].[vGISDoctorData]
as

select 
RIGHT('000000000' + convert(varchar(9), InDeptCode), 9) + 
	RIGHT('00000000000' + CONVERT(varchar(11), InEmployeeID), 11) + 
		CONVERT(varchar(1), isnull(AgreementTypeID, 1)) + 
		RIGHT('0000000' + CONVERT(varchar(7), InServiceCode), 7) as 'Key',
	doctorName, InDeptCode as deptCode, deptName, cityCode, AgreementTypeID, AgreementTypeDescription,
				phone, serviceDescription, isExpert, 
				STUFF((select ';' + s.ServiceDescription 
						from EmployeeServices es 
						join Services s on es.serviceCode = s.ServiceCode and s.IsProfession = 1
						where es.EmployeeID = InEmployeeID 
							 for xml PATH('') ), 1, 1 , '' ) as AllProfessions,
				STUFF((select ';' + s.ServiceDescription 
						from EmployeeServices es 
						join Services s on es.serviceCode = s.ServiceCode
						where es.EmployeeID = InEmployeeID 
							and es.expProfession = 1 for xml PATH('') ), 1, 1 , '' ) as Expertise,
				STUFF((select ';' + sc.ServiceCategoryDescription 
						from x_ServiceCategories_Services xsc 
						join ServiceCategories sc on sc.ServiceCategoryID = xsc.ServiceCategoryID
						where xsc.ServiceCode = InServiceCode
						for xml PATH('') ), 1, 1, '') as MainServices,
				cast(ROUND((select sum(dbo.rfn_TimeInterval_float(der.openingHour, der.closingHour))
					from x_Dept_Employee_Service xdes
					join x_Dept_Employee de on xdes.DeptEmployeeID = de.DeptEmployeeID
					join deptEmployeeReception der on der.DeptEmployeeID = xdes.DeptEmployeeID
					join deptEmployeeReceptionServices ders on ders.receptionID = der.receptionID and ders.serviceCode = xdes.serviceCode
					where GETDATE() between ISNULL(der.validFrom,'1900-01-01') 
						and ISNULL(der.validTo,'2079-01-01')  
						and de.employeeID = InEmployeeID
						and de.deptCode = InDeptCode
						and de.AgreementType = AgreementTypeID
						and xdes.serviceCode = InServiceCode
						and de.active = 1 and xdes.Status = 1
					group by de.deptCode, de.employeeID, de.AgreementType, xdes.serviceCode
				), 2, 1) as numeric(20,2)) as ReceptionHoursSum, 	
				isnull(max([Sunday_1]), '') as [Sunday_1],isnull(max([Sunday_2]), '') as [Sunday_2],isnull(max([Sunday_3]), '') as [Sunday_3],isnull(max([Monday_1]), '') as [Monday_1],isnull(max([Monday_2]), '') as [Monday_2],isnull(max([Monday_3]), '') as [Monday_3],isnull(max([Tuesday_1]), '') as [Tuesday_1],isnull(max([Tuesday_2]), '') as [Tuesday_2],isnull(max([Tuesday_3]), '') as [Tuesday_3],isnull(max([Wednesday_1]), '') as [Wednesday_1],isnull(max([Wednesday_2]), '') as [Wednesday_2],isnull(max([Wednesday_3]), '') as [Wednesday_3],isnull(max([Thursday_1]), '') as [Thursday_1],isnull(max([Thursday_2]), '') as [Thursday_2],isnull(max([Thursday_3]), '') as [Thursday_3],isnull(max([Friday_1]), '') as [Friday_1],isnull(max([Friday_2]), '') as [Friday_2],isnull(max([Friday_3]), '') as [Friday_3],isnull(max([Holiday_1]), '') as [Holiday_1],isnull(max([Holiday_2]), '') as [Holiday_2],isnull(max([HolHamoeed_1]), '') as [HolHamoeed_1],isnull(max([HolHamoeed_2]), '') as [HolHamoeed_2],isnull(max([HolHamoeed_3]), '') as [HolHamoeed_3],isnull(max([HolidayEvening_1]), '') as [HolidayEvening_1],isnull(max([HolidayEvening_2]), '') as [HolidayEvening_2],isnull(max([Saturday_1]), '') as [Saturday_1],isnull(max([Saturday_2]), '') as [Saturday_2]
				,isnull(max([Ramadan_1]), '') as [Ramadan_1],isnull(max([Ramadan_2]), '') as [Ramadan_2],isnull(max([OptionalHoliday_1]), '') as [OptionalHoliday_1],isnull(max([OptionalHoliday_2]), '') as [OptionalHoliday_2]
,isnull(max([Remark_Sunday_1]), '') as [Remark_Sunday_1],isnull(max([Remark_Sunday_2]), '') as [Remark_Sunday_2],isnull(max([Remark_Sunday_3]), '') as [Remark_Sunday_3],isnull(max([Remark_Monday_1]), '') as [Remark_Monday_1],isnull(max([Remark_Monday_2]), '') as [Remark_Monday_2],isnull(max([Remark_Monday_3]), '') as [Remark_Monday_3],isnull(max([Remark_Tuesday_1]), '') as [Remark_Tuesday_1],isnull(max([Remark_Tuesday_2]), '') as [Remark_Tuesday_2],isnull(max([Remark_Tuesday_3]), '') as [Remark_Tuesday_3],isnull(max([Remark_Wednesday_1]), '') as [Remark_Wednesday_1],isnull(max([Remark_Wednesday_2]), '') as [Remark_Wednesday_2],isnull(max([Remark_Wednesday_3]), '') as [Remark_Wednesday_3],isnull(max([Remark_Thursday_1]), '') as [Remark_Thursday_1],isnull(max([Remark_Thursday_2]), '') as [Remark_Thursday_2],isnull(max([Remark_Thursday_3]), '') as [Remark_Thursday_3],isnull(max([Remark_Friday_1]), '') as [Remark_Friday_1],isnull(max([Remark_Friday_2]), '') as [Remark_Friday_2],isnull(max([Remark_Friday_3]), '') as [Remark_Friday_3],isnull(max([Remark_Holiday_1]), '') as [Remark_Holiday_1],isnull(max([Remark_Holiday_2]), '') as [Remark_Holiday_2],isnull(max([Remark_HolHamoeed_1]), '') as [Remark_HolHamoeed_1],isnull(max([Remark_HolHamoeed_2]), '') as [Remark_HolHamoeed_2],isnull(max([Remark_HolHamoeed_3]), '') as [Remark_HolHamoeed_3],isnull(max([Remark_HolidayEvening_1]), '') as [Remark_HolidayEvening_1],isnull(max([Remark_HolidayEvening_2]), '') as [Remark_HolidayEvening_2],isnull(max([Remark_Saturday_1]), '') as [Remark_Saturday_1],isnull(max([Remark_Saturday_2]), '') as [Remark_Saturday_2]
 from 
(select
				e.employeeID as InEmployeeID,
				e.firstName+' '+e.lastName as doctorName, 
				d.deptCode as InDeptCode, d.deptName, d.cityCode, dag.AgreementTypeID, dag.AgreementTypeDescription,
				dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
				xdes.ServiceCode as InServiceCode, ser.serviceDescription, 
				isnull(es.expProfession, 0) as isExpert,
				er.receptionDay,
				er.openingHour ,
				er.closingHour ,
				[DIC_ReceptionDays].ReceptionDayName,
				openingHour + '-'+closingHour as Hours,
				derp.RemarkText,
row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode ,er.receptionDay 
					order by er.openingHour ,er.closingHour )rn,
[DIC_ReceptionDays].EnumName+'_'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift ,
'Remark_'+[DIC_ReceptionDays].EnumName+'_'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift2
from Employee e
join x_Dept_Employee de on de.employeeID = e.employeeID
join x_Dept_Employee_Service xdes on de.DeptEmployeeID = xdes.DeptEmployeeID
join Dept d on de.deptCode = d.deptCode
left join Dept distr on d.districtCode = distr.deptCode
join Cities c on d.cityCode = c.cityCode
left join Streets s on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy on d.deptCode = dxy.deptCode
join deptEmployeeReception er on de.DeptEmployeeID = er.DeptEmployeeID
left join [DIC_ReceptionDays] on er.receptionDay = [DIC_ReceptionDays].ReceptionDayCode
join deptEmployeeReceptionServices ers on er.receptionID = ers.receptionID 
	and ers.serviceCode = xdes.serviceCode
join Services ser on ers.serviceCode = ser.serviceCode
left join EmployeeServices es on e.employeeID = es.EmployeeID and ers.serviceCode = es.serviceCode
left join DIC_AgreementTypes dag on de.AgreementType = dag.AgreementTypeID
left join DeptEmployeeReceptionRemarks derp
on derp.EmployeeReceptionID = er.receptionID
where d.status = 1
and e.active = 1
and de.active = 1
and xdes.Status = 1
and e.EmployeeSectorCode = 7
and GETDATE() between ISNULL(er.validFrom,'1900-01-01') 
and ISNULL(er.validTo,'2079-01-01')  
) a
pivot 
(max(Hours) for shift in ([Sunday_1],[Sunday_2],[Sunday_3],[Monday_1],[Monday_2],[Monday_3],[Tuesday_1],[Tuesday_2],[Tuesday_3],[Wednesday_1],[Wednesday_2],[Wednesday_3],[Thursday_1],[Thursday_2],[Thursday_3],[Friday_1],[Friday_2],[Friday_3],[Saturday_1],[Saturday_2],[Holiday_1],[Holiday_2],[HolHamoeed_1],[HolHamoeed_2],[HolHamoeed_3],[HolidayEvening_1],[HolidayEvening_2],[Ramadan_1],[Ramadan_2],[OptionalHoliday_1],[OptionalHoliday_2])
) AS PivotTable1
pivot 
(max(RemarkText) for shift2 in ([Remark_Sunday_1],[Remark_Sunday_2],[Remark_Sunday_3],[Remark_Monday_1],[Remark_Monday_2],[Remark_Monday_3],[Remark_Tuesday_1],[Remark_Tuesday_2],[Remark_Tuesday_3],[Remark_Wednesday_1],[Remark_Wednesday_2],[Remark_Wednesday_3],[Remark_Thursday_1],[Remark_Thursday_2],[Remark_Thursday_3],[Remark_Friday_1],[Remark_Friday_2],[Remark_Friday_3],[Remark_Saturday_1],[Remark_Saturday_2],[Remark_Holiday_1],[Remark_Holiday_2],[Remark_HolHamoeed_1],[Remark_HolHamoeed_2],[Remark_HolHamoeed_3],[Remark_HolidayEvening_1],[Remark_HolidayEvening_2])
) AS PivotTable2
--where InDeptCode in (59103, 22370,18587, 94236)
group by InEmployeeID, doctorName, InDeptCode, deptName, cityCode, AgreementTypeID, AgreementTypeDescription, 
				phone, InServiceCode, serviceDescription, isExpert
union 
select
	RIGHT('000000000' + convert(varchar(9), d.deptCode), 9) + 
		RIGHT('00000000000' + CONVERT(varchar(11), e.employeeID), 11) + 
		CONVERT(varchar(1), isnull(AgreementTypeID, 1)) + 
		RIGHT('0000000' + CONVERT(varchar(7), isnull(prof.ServiceCode, 0)), 7) as 'Key',
	e.firstName+' '+e.lastName as doctorName,
	d.deptCode, d.deptName, d.cityCode, 
	de.AgreementType, dag.AgreementTypeDescription,
	dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
	prof.ServiceDescription, 
	isnull(es.expProfession, 0) as isExpert, 
	STUFF((select ';' + s.ServiceDescription 
			from EmployeeServices es 
			join Services s on es.serviceCode = s.ServiceCode and s.IsProfession = 1
			where es.EmployeeID = e.employeeID 
				 for xml PATH('') ), 1, 1 , '' ) as AllProfessions,
	STUFF((select ';' + s.ServiceDescription 
			from EmployeeServices es 
			join Services s on es.serviceCode = s.ServiceCode
			where es.EmployeeID = e.employeeID 
				and es.expProfession = 1 for xml PATH('') ), 1, 1 , '' ) as Expertise,
	STUFF((select ';' + sc.ServiceCategoryDescription 
			from ServiceCategories sc 
			join x_ServiceCategories_Services xsc on sc.ServiceCategoryID = xsc.ServiceCategoryID
			where xsc.ServiceCode = prof.serviceCode
			for xml PATH('') ), 1, 1, '') as MainServices,
	0 as ReceptionHoursSum,
	'' as [Sunday_1],'' as [Sunday_2],'' as [Sunday_3],'' as [Monday_1],'' as [Monday_2],'' as [Monday_3],'' as [Tuesday_1],'' as [Tuesday_2],'' as [Tuesday_3],'' as [Wednesday_1],'' as [Wednesday_2],'' as [Wednesday_3],'' as [Thursday_1],'' as [Thursday_2],'' as [Thursday_3],'' as [Friday_1],'' as [Friday_2],'' as [Friday_3],
	'' as [Holiday_1],'' as [Holiday_2], '' as [HolHamoeed_1],'' as [HolHamoeed_2],'' as [HolHamoeed_3],'' as [HolidayEvening_1],'' as [HolidayEvening_2],'' as [Saturday_1],'' as [Saturday_2],'' as [Ramadan_1],'' as [Ramadan_2],'' as [OptionalHoliday_1],'' as [OptionalHoliday_2],
	'' as [Remark_Sunday_1],'' as [Remark_Sunday_2],'' as [Remark_Sunday_3],'' as [Remark_Monday_1],'' as [Remark_Monday_2],'' as [Remark_Monday_3],'' as [Remark_Tuesday_1],'' as [Remark_Tuesday_2],'' as [Remark_Tuesday_3],'' as [Remark_Wednesday_1],'' as [Remark_Wednesday_2],'' as [Remark_Wednesday_3],'' as [Remark_Thursday_1],'' as [Remark_Thursday_2],'' as [Remark_Thursday_3],'' as [Remark_Friday_1],'' as [Remark_Friday_2],'' as [Remark_Friday_3],'' as [Remark_Holiday_1],'' as [Remark_Holiday_2],'' as [Remark_HolHamoeed_1],'' as [Remark_HolHamoeed_2],'' as [Remark_HolHamoeed_3],'' as [Remark_HolidayEvening_1],'' as [Remark_HolidayEvening_2],'' as [Remark_Saturday_1],'' as [Remark_Saturday_2]
from Employee e
join x_Dept_Employee de on de.employeeID = e.employeeID
join Dept d on de.deptCode = d.deptCode
left join Dept distr on d.districtCode = distr.deptCode
join Cities c on d.cityCode = c.cityCode
left join Streets s on d.cityCode = s.CityCode and d.StreetCode = s.StreetCode
left join x_dept_XY dxy on d.deptCode = dxy.deptCode
join x_Dept_Employee_Service xdes on de.DeptEmployeeID = xdes.DeptEmployeeID 
join Services prof on xdes.serviceCode = prof.ServiceCode
left join EmployeeServices es on e.employeeID = es.EmployeeID and xdes.serviceCode = es.serviceCode
left join DIC_AgreementTypes dag on de.AgreementType = dag.AgreementTypeID
where d.status = 1
and e.active = 1
and de.active = 1
and xdes.Status = 1
and e.EmployeeSectorCode = 7
and xdes.serviceCode not in (select serviceCode
								from deptEmployeeReceptionServices rp1 
								left join deptEmployeeReception er1
								on er1.receptionID = rp1.receptionID
								where er1.DeptEmployeeID = de.DeptEmployeeID)
and (de.AgreementType not in (3, 4)
	or (de.AgreementType in (3, 4) and (xdes.serviceCode = 180300  
		or not exists (select * from x_Dept_Employee_Service xdes2
						where xdes2.DeptEmployeeID = xdes.DeptEmployeeID
							and xdes2.serviceCode = 180300))))

--and d.deptCode in (59103, 22370,18587, 94236)
--order by doctorName, deptName

GO


GRANT SELECT ON [dbo].vGISDoctorData TO [public] AS [dbo]
GO
