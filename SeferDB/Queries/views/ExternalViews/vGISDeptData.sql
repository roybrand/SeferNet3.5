/*
נתוני יחידות עם קואורדינטות עבור רופא ראשי - מערכת GIS
יש לשלוף אך ורק יחידות פעילות
*/

ALTER view [dbo].[vGISDeptData]
as
select deptcode, deptName,deptTypeName, 
				deptSubTypeName,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				SiteName, NeighbourhoodName,
				isAutoCoordUpdate, phone,
				isnull(max([Sunday_1]), '') as [Sunday_1],isnull(max([Sunday_2]), '') as [Sunday_2],isnull(max([Sunday_3]), '') as [Sunday_3],isnull(max([Monday_1]), '') as [Monday_1],isnull(max([Monday_2]), '') as [Monday_2],isnull(max([Monday_3]), '') as [Monday_3],isnull(max([Tuesday_1]), '') as [Tuesday_1],isnull(max([Tuesday_2]), '') as [Tuesday_2],isnull(max([Tuesday_3]), '') as [Tuesday_3],isnull(max([Wednesday_1]), '') as [Wednesday_1],isnull(max([Wednesday_2]), '') as [Wednesday_2],isnull(max([Wednesday_3]), '') as [Wednesday_3],isnull(max([Thursday_1]), '') as [Thursday_1],isnull(max([Thursday_2]), '') as [Thursday_2],isnull(max([Thursday_3]), '') as [Thursday_3],isnull(max([Friday_1]), '') as [Friday_1],isnull(max([Friday_2]), '') as [Friday_2],isnull(max([Friday_3]), '') as [Friday_3],isnull(max([Holiday_1]), '') as [Holiday_1],isnull(max([Holiday_2]), '') as [Holiday_2],isnull(max([HolHamoeed_1]), '') as [HolHamoeed_1],isnull(max([HolHamoeed_2]), '') as [HolHamoeed_2],isnull(max([HolHamoeed_3]), '') as [HolHamoeed_3],isnull(max([HolidayEvening_1]), '') as [HolidayEvening_1],isnull(max([HolidayEvening_2]), '') as [HolidayEvening_2],isnull(max([Saturday_1]), '') as [Saturday_1],isnull(max([Saturday_2]), '') as [Saturday_2]
				,isnull(max([Ramadan_1]), '') as [Ramadan_1],isnull(max([Ramadan_2]), '') as [Ramadan_2],isnull(max([OptionalHoliday_1]), '') as [OptionalHoliday_1],isnull(max([OptionalHoliday_2]), '') as [OptionalHoliday_2]
				,(select  sum(totalHours)
					FROM dbo.rfn_GetDeptAndServicesReception(deptCode, null, null, 1 , null) dd
					join DIC_ReceptionDays rd on dd.receptionDay = rd.ReceptionDayCode
					where rd.Display = 1
						and (dd.remarkText is null or dd.remarkText <> (select remark 
												from DIC_GeneralRemarks gr where gr.remarkID = 72))
				) as Hours
from 
	(select
				d.deptCode, replace(d.deptName, '''', '') as deptName, 
				ut.UnitTypeName as deptTypeName, 
				sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, replace(replace(replace(d.addressComment, '''', ''),char(10),' '),char(13),'') as addressComment, 
				d.zipCode, dxy.xcoord, dxy.ycoord,
				case when d.IsSite <> 0 then ISNULL(st.InstituteName, '') else '' end as SiteName,
				case when (d.IsSite = 0 or d.IsSite is null) then ISNULL(n.NybName, '') else '' end as NeighbourhoodName,
				1 as isAutoCoordUpdate,
				dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as phone,
				DeptReception.receptionDay,
				DeptReception.openingHour ,
				DeptReception.closingHour ,
				[DIC_ReceptionDays].ReceptionDayName,
				openingHour + '-'+closingHour as Hours,
				row_number() over (partition by d.deptCode,DeptReception.receptionDay 
									order by DeptReception.openingHour --,DeptReception.closingHour 
									)rn,
				[DIC_ReceptionDays].EnumName + '_' + 
					cast(row_number() over (partition by d.deptCode,DeptReception.receptionDay 
											order by DeptReception.openingHour /*,DeptReception.closingHour*/ 
											) as varchar(10)) shift 
from dept d join
DeptReception
on d.deptCode = DeptReception.deptCode  
left join [DIC_ReceptionDays]
on DeptReception.receptionDay = [DIC_ReceptionDays].ReceptionDayCode  
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
left join Atarim st on d.NeighbourhoodOrInstituteCode = st.InstituteCode
left join Neighbourhoods n on d.NeighbourhoodOrInstituteCode = n.NeighbourhoodCode
where d.status = 1
and DeptReception.ReceptionHoursTypeID = 1
and not exists (select * from DeptReceptionRemarks drr 
			where DeptReception.receptionID = drr.ReceptionID and drr.RemarkID = 72)
and GETDATE() between ISNULL(DeptReception.validFrom,'1900-01-01') 
and ISNULL(DeptReception.validTo,'2079-01-01')  
) a
pivot 
(max(Hours) for shift in ([Sunday_1],[Sunday_2],[Sunday_3],[Monday_1],[Monday_2],[Monday_3],[Tuesday_1],[Tuesday_2],[Tuesday_3],[Wednesday_1],[Wednesday_2],[Wednesday_3],[Thursday_1],[Thursday_2],[Thursday_3],[Friday_1],[Friday_2],[Friday_3],[Saturday_1],[Saturday_2],[Holiday_1],[Holiday_2],[HolHamoeed_1],[HolHamoeed_2],[HolHamoeed_3],[HolidayEvening_1],[HolidayEvening_2],[Ramadan_1],[Ramadan_2],[OptionalHoliday_1],[OptionalHoliday_2])
) AS PivotTable
group by deptcode, deptName, deptTypeName, 
				deptSubTypeName,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				SiteName, NeighbourhoodName, 
				isAutoCoordUpdate, phone
union
select d.deptcode, replace(d.deptName, '''', '') as deptName,
ut.UnitTypeName as deptTypeName, 
				sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, replace(replace(replace(d.addressComment, '''', ''),char(10),' '),char(13),'') as addressComment, 
				d.zipCode, dxy.xcoord, dxy.ycoord,
				case when d.IsSite <> 0 then ISNULL(st.InstituteName, '') else '' end as SiteName,
				case when (d.IsSite = 0 or d.IsSite is null) then ISNULL(n.NybName, '') else '' end as NeighbourhoodName,
				1 as isAutoCoordUpdate,
				dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as phone,
				'' as [Sunday_1],'' as [Sunday_2],'' as [Sunday_3],'' as [Monday_1],'' as [Monday_2],'' as [Monday_3],'' as [Tuesday_1],'' as [Tuesday_2],'' as [Tuesday_3],'' as [Wednesday_1],'' as [Wednesday_2],'' as [Wednesday_3],'' as [Thursday_1],'' as [Thursday_2],'' as [Thursday_3],'' as [Friday_1],'' as [Friday_2],'' as [Friday_3],
				'' as [Holiday_1],'' as [Holiday_2], '' as [HolHamoeed_1],'' as [HolHamoeed_2],'' as [HolHamoeed_3],'' as [HolidayEvening_1],'' as [HolidayEvening_2],'' as [Saturday_1],'' as [Saturday_2],'' as [Ramadan_1],'' as [Ramadan_2],'' as [OptionalHoliday_1],'' as [OptionalHoliday_2]
				,0 as Hours
from Dept d
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
left join Atarim st on d.NeighbourhoodOrInstituteCode = st.InstituteCode
left join Neighbourhoods n on d.NeighbourhoodOrInstituteCode = n.NeighbourhoodCode
where d.deptCode not in (select deptCode from DeptReception where DeptReception.ReceptionHoursTypeID = 1)
and d.status = 1


GO


--grant select on vGISDeptData to public 

--go