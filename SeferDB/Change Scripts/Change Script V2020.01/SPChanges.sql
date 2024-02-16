-- VIEWS
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


-- Reports:

ALTER Procedure [dbo].[rprt_DeptEmployees]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@UnitTypeCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,
	@DeptEmployeeStatusCodes varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,-- NEW	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, 
	@EmployeeStatus		varchar(2)= null,
	@DeptEmployeeStatus varchar(2)= null,
	@EmployeeSex varchar(2)=null, 
	@EmployeeDegree varchar(2)= null,
	@EmployeeLanguages varchar(2)= null, 
	@ReceiveGuests varchar(2)= null,
			
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @sqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xUnitTypeCodes varchar(max)=null,
	@xEmployeeSector_cond varchar(max)=null,	
	@xUnitedServiceCodes varchar(max)=null,		 	 
	@xExpertProfessionCodes varchar(max)=null,
	@xCitiesCodes varchar(max)=null, 	 
	@xAgreementType_cond varchar(max)=null,
	@xDeptEmployeeStatusCodes varchar(max)=null
'

SET @Declarations = ''

---------------------------
set @sql = 'SELECT distinct * from (select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM Dept as d    
LEFT JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
JOIN EmployeeInClinic_preselected EmpPresel ON x_Dept_Employee.deptEmployeeID = EmpPresel.deptEmployeeID
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active ' + @NewLineChar;
if(@EmployeeSector = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode ' + @NewLineChar;
if(@adminClinic = '1' )
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode ' + @NewLineChar;
set @sqlFrom = @sqlFrom + 	
'LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode ' + @NewLineChar;
if(@unitType = '1')
	set @sqlFrom = @sqlFrom +   
	'LEFT JOIN View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode ' + @NewLineChar;
if(@subUnitType = '1')	
	set @sqlFrom = @sqlFrom +  
	'LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode = SubUnitType.subUnitTypeCode
		 and  d.typeUnitCode = SubUnitType.UnitTypeCode ' + @NewLineChar;
if(@city = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN Cities on d.CityCode = Cities.CityCode ' + @NewLineChar;
if(@simul = '1')
	set @sqlFrom = @sqlFrom +  
	' LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode ' + @NewLineChar;
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode ' + @NewLineChar;
if(@QueueOrderDescription = '1')	
	set @sqlFrom = @sqlFrom + 
	' cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails ' + @NewLineChar;
if(@DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom + 
	' LEFT JOIN DeptEmployeePhones as emplPh1 on x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
	 LEFT JOIN DeptEmployeePhones as emplPh2 on x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 ' + @NewLineChar;
if(@Fax = '1' OR @DeptEmployeeFax = '1')
	set @sqlFrom = @sqlFrom + 		
	' LEFT JOIN DeptEmployeePhones as emplPh3 on x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 ' + @NewLineChar;
if(@Phone1 = '1' OR @DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom +  			
	' LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 ' + @NewLineChar;
if(@Phone2 = '1' OR @DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom +  		
	' LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 ' + @NewLineChar;
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 ' + @NewLineChar;
if(@Fax = '1' OR @DeptEmployeeFax = '1')
	set @sqlFrom = @sqlFrom + 		
	' LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 ' + @NewLineChar;
if(@sector = '1')	
	set @sqlFrom = @sqlFrom + 	
	' LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID ' + @NewLineChar;
if(@Professions = '1') 
	set @sqlFrom = @sqlFrom + 
	' LEFT JOIN [dbo].View_DeptEmployeeProfessions as DEProfessions	 
		on x_Dept_Employee.deptCode = DEProfessions.deptCode
		and x_Dept_Employee.AgreementType = DEProfessions.AgreementType
		and Employee.employeeID = DEProfessions.employeeID ' + @NewLineChar;
if(@EmployeeExpertProfession = '1')
	set @sqlFrom = @sqlFrom +  
	' LEFT JOIN [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
		on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
		and x_Dept_Employee.AgreementType = DEExpProfessions.AgreementType
		and Employee.employeeID = DEExpProfessions.employeeID ' + @NewLineChar;
if(@Position = '1' ) 
	set @sqlFrom = @sqlFrom +  
	'LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID ' + @NewLineChar;
if(@DeptEmployeeServices = '1' ) 
	set @sqlFrom = @sqlFrom +  	
	' LEFT JOIN [dbo].View_DeptEmployeeServices as DEServices 
		on x_Dept_Employee.deptCode = DEServices.deptCode 
		and x_Dept_Employee.AgreementType = DEServices.AgreementType
		and Employee.employeeID = DEServices.employeeID ' + @NewLineChar;
if(@DeptEmployeeRemark = '1' ) 
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and Employee.employeeID = DERemarks.employeeID ' + @NewLineChar;
if(@EmployeeDegree = '1')	
	set @sqlFrom = @sqlFrom +  		
	'LEFT JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode ' + @NewLineChar;

SET @SqlWhere = ' WHERE 1=1 '

IF(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )) ) '
IF(@UnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.typeUnitCode IN (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
IF(@CitiesCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
IF(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) ' + @NewLineChar;
IF(@AgreementType_cond <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond )) ) '
IF(@UnitedServiceCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND ( SELECT count(*) 
		FROM x_Dept_Employee_Service as xDEP 
		WHERE xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID							
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) > 0 '
IF(@ExpertProfessionCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND ( SELECT count(*) 
		FROM x_Dept_Employee_Service as xDEP 
		left join EmployeeServices on 
					x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDEP.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE x_Dept_Employee.DeptEmployeeID = xDEP.DeptEmployeeID	
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0 '	

IF(@EmployeeSector_cond <> '-1' AND @ServiceCodes = '-1')
	SET @SqlWhere = @SqlWhere + 
	' AND ( CASE WHEN Employee.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												 THEN Employee.EmployeeSectorCode 
												 ELSE [Services].SectorToShowWith END
								FROM [Services]
								JOIN x_Dept_Employee_Service as xdes ON [Services].ServiceCode = xdes.ServiceCode
									AND xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
								), Employee.EmployeeSectorCode)
				 ELSE Employee.EmployeeSectorCode
				 END 
					= @xEmployeeSector_cond
	) '	
		  
	--' AND ( Employee.EmployeeSectorCode = @xEmployeeSector_cond ) '
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
IF(@EmployeeSector_cond <> '-1' AND @ServiceCodes <> '-1')
	SET @SqlWhere = @SqlWhere +
	
	' AND ( CASE WHEN Employee.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												 THEN Employee.EmployeeSectorCode 
												 ELSE [Services].SectorToShowWith END
								FROM [Services]
								JOIN x_Dept_Employee_Service as xdes ON [Services].ServiceCode = xdes.ServiceCode
									AND xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
								), Employee.EmployeeSectorCode)
				 ELSE Employee.EmployeeSectorCode
				 END 
					= @xEmployeeSector_cond
	) '
	 	  
	--' AND ( Employee.EmployeeSectorCode = @xEmployeeSector_cond ) '	
	
IF(@DeptEmployeeStatusCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND ( x_Dept_Employee.active = @xDeptEmployeeStatusCodes ) '


if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName, isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode, UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode, dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end 

if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode, ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@Professions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEProfessions.ProfessionDescriptions as ProfessionDescription
			 ,DEProfessions.ProfessionCodes as ProfessionCode ' 
			+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEServices.ServiceDescriptions as ServiceDescription 
			,DEServices.ServiceCodes as ServiceCode' 
		+ @NewLineChar;
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' EmpPresel.EmployeeLanguageDescription as EmployeeLanguages' + @NewLineChar;
end 
	
if(@QueueOrderDescription = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
		+ @NewLineChar
	end	

if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpPresel.phone as EmployeePhone1 ' + @NewLineChar;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpPresel.fax as EmployeeFax ' + @NewLineChar;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql
		 + ' EmpPresel.AgreementType as AgreementTypeCode,
		 EmpPresel.AgreementTypeDescription as AgreementTypeDescription ' + @NewLineChar;
	end	

if(@EmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpStatus.Status as StatusCode, EmpStatus.StatusDescription as StatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEmpStatus.Status as DeptEmployeeStatusCode, DeptEmpStatus.StatusDescription as DeptEmployeeStatusDescription '+ @NewLineChar;
	end	
if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if(@ReceiveGuests = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CASE  WHEN EmpPresel.ReceiveGuests = 1 THEN ''כן'' ELSE ''לא'' END  as ReceiveGuests '+ @NewLineChar;
	end	
	
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
--=================================================================
--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xUnitTypeCodes = @UnitTypeCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xUnitedServiceCodes = @UnitedServiceCodes,		
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xCitiesCodes = @CitiesCodes,
	@xAgreementType_cond = @AgreementType_cond,
	@xDeptEmployeeStatusCodes = @DeptEmployeeStatusCodes
 
SET @ErrCode = @sql 
RETURN 
GO

ALTER PROCEDURE [dbo].[rprt_DeptsByProfessionsTypes]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@ServiceCodes varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@StatusCodes varchar(max)=null,	
	@SectorCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,  
	@CitiesCodes varchar(max)=null,
	@Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@status varchar (2)=null,			
	@statusFromDate varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@fromDateName varchar (2)=null,			
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@streetName varchar (2)=null,
	@house varchar (2)=null,	
	@floor varchar (2)=null,
	@flat varchar (2)=null,	

	@addressComment varchar (2)=null, 	
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null, 
	@DirectPhone varchar (2)=null,-- NEW
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	
	@transportation varchar (2)=null,
	@deptLevelDesc varchar (2)=null,
	@professions varchar (2)=null,
	@DeptServices varchar (2)=null,	
	@EmployeeServices varchar (2)=null,	
	@DeptHandicappedFacilities varchar (2)=null, -- name changed
	@Membership  varchar (2)=null,
	@IsExcelVersion varchar (2)= null,
	@showUnitInInternet varchar (2)=null,
	@DeptCoordinates varchar (2)=null,
	
	@ErrCode VARCHAR(max) OUTPUT
	
-----------------------------------------
)with recompile

AS
--------------------------------------
DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE  @sql nvarchar(max)
DECLARE  @sqlEnd nvarchar(max)
DECLARE  @sqlFrom varchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,	
	@xServiceCodes varchar(max)=null, 
	@xUnitTypeCodes varchar(max)=null,
	@xSubUnitTypeCodes varchar(max)=null,
	@xStatusCodes varchar(max)=null, 
	@xSectorCodes varchar(max)=null,
	@xProfessionCodes varchar(max)=null, 
	@xUnitedServiceCodes varchar(max)=null,		 
	@xCitiesCodes varchar(max)=null, 
	@xMembership_cond varchar(max)=null 
'

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10) 

SET @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
			
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM dept as d '   

if(@adminClinic = '1')
	set @sqlFrom = @sqlFrom +	 
	'left join dept as dAdmin on d.administrationCode = dAdmin.deptCode '
if(@district = '1')
	set @sqlFrom = @sqlFrom +	
	'left join dept as dDistrict on d.districtCode = dDistrict.deptCode '	
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom +		
	'left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '
if(@unitType = '1')
	set @sqlFrom = @sqlFrom +
	'left join View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode '
if(@subUnitType = '1')
	set @sqlFrom = @sqlFrom +
	'left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and d.typeUnitCode =  SubUnitType.UnitTypeCode '
if(@sector = '1')
	set @sqlFrom = @sqlFrom +
	' left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '		
set @sqlFrom = @sqlFrom +   
 'left join deptSimul on d.DeptCode = deptSimul.DeptCode '
if(@city = '1')
	set @sqlFrom = @sqlFrom + 
 'left join Cities on d.CityCode =  Cities.CityCode ' 
if(@status = '1' or @statusFromDate = '1') 
	set @sqlFrom = @sqlFrom +  
	 --'left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
	 --left join DIC_ActivityStatus on DeptStatus.Status = DIC_ActivityStatus.status ' 
	 'LEFT JOIN 
		(SELECT MAX(StatusID) as StatusID, DeptCode, Status, FromDate, ToDate
		  FROM DeptStatus
		  GROUP BY DeptCode, Status, FromDate, ToDate
		  HAVING FromDate < GETDATE()
		  AND (ToDate is null OR ToDate > GETDATE())
		) AS DeptStatus
		  ON d.deptCode = DeptStatus.DeptCode
		  and d.status = DeptStatus.Status
	  LEFT JOIN DIC_ActivityStatus on d.status = DIC_ActivityStatus.status   
		  '
	 
set @sqlFrom = @sqlFrom +   
 ' left join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode '
if(@Phone1 = '1')
	set @sqlFrom = @sqlFrom +
	' left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 '
if(@Phone2 = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 '
if(@Fax = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '
if(@DeptCoordinates = '1')	
	set @sqlFrom = @sqlFrom +  	
	' left join x_dept_XY on d.deptCode = x_dept_XY.deptCode '

-----------------------------------------------------------
 if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName, isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode, UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	
	
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 

if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end

if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end

if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end

if(@status = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Status as StatusCode , DIC_ActivityStatus.statusDescription as StatusName '+ @NewLineChar;
	end 

if(@statusFromDate = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(max), DeptStatus.FromDate, 103) AS StatusFromDate '+ @NewLineChar;
	
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(max), DeptStatus.ToDate, 103) AS StatusToDate '+ @NewLineChar;
	end 

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if (@streetName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.streetName '+ @NewLineChar;
	end	
	
if (@house = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.house '+ @NewLineChar;
	end	
	
if (@floor = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.floor '+ @NewLineChar;
	end
		
if (@flat = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.flat '+ @NewLineChar;
	end	
 
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;	
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end

if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end		

if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode, ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 

if(@showUnitInInternet = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case 
		when d.showUnitInInternet = ''1'' then ''כן''
		else ''לא''
	end as showUnitInInternet '+ @NewLineChar;		
end

if(@fromDateName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' (select top 1 
			CONVERT(VARCHAR(10), FromDate, 103)  
			from dbo.DeptNames
			where deptCode=d.DeptCode and fromDate <=getDate()
			order by fromDate desc) as fromDateName '+ @NewLineChar;
end 

if(@addressComment = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.addressComment as AddressComment '+ @NewLineChar;
end
										 
if(@DeptHandicappedFacilities = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
	--' dbo.rfn_GetDeptHandicappedFacilities(d.DeptCode) as DeptHandicappedFacilities '+ @NewLineChar;
	
	' 	(select stuff((select distinct '','' + DIC_HF.FacilityDescription 
		from DeptHandicappedFacilities as DHF
		join DIC_HandicappedFacilities as DIC_HF 
		on DHF.FacilityCode = DIC_HF.FacilityCode
		and DeptCode = d.DeptCode 
		for xml path('''')),1,1,''''
							)) as DeptHandicappedFacilities '
	+ @NewLineChar;
	
end

if(@transportation = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.transportation as transportation '+ @NewLineChar;
end

if(@deptLevelDesc = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'isNull(ddl.deptLevelCode , -1)	as deptLevelCode ,	 
		ddl.deptLevelDescription as deptLevelDesc '+ @NewLineChar;
end

if(@professions = '1' )
begin
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql +  
	'(select stuff((select distinct '',''+ s.ServiceDescription
										from x_Dept_Employee_Service x_des
										join x_Dept_Employee x_de
										on x_des.DeptEmployeeID = x_de.DeptEmployeeID
										and x_de.active = 1
										join [Services] s
										on x_des.serviceCode = s.ServiceCode
										and s.IsProfession = 1
										where x_de.deptCode = d.DeptCode
										and x_des.Status = 1
										for xml path('''')),1,1,''''
							)) as professionDescription,  
	(select stuff((select distinct '',''+ CAST(s.ServiceCode as varchar(5))
										from x_Dept_Employee_Service x_des
										join x_Dept_Employee x_de
										on x_des.DeptEmployeeID = x_de.DeptEmployeeID
										and x_de.active = 1
										join [Services] s
										on x_des.serviceCode = s.ServiceCode
										and s.IsProfession = 1
										where x_de.deptCode = d.DeptCode
										and x_des.Status = 1
										for xml path('''')),1,1,''''
							)) as professionCode '
		+ @NewLineChar; 							
end

if(@EmployeeServices = '1')
begin 

	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
	'(select stuff((select distinct '',''+ s.ServiceDescription
										from x_Dept_Employee_Service x_des
										join x_Dept_Employee x_de
										on x_des.DeptEmployeeID = x_de.DeptEmployeeID
										and x_de.active = 1
										join [Services] s
										on x_des.serviceCode = s.ServiceCode
										and s.IsProfession = 0
										where x_de.deptCode = d.DeptCode
										and x_des.Status = 1
										for xml path('''')),1,1,''''
							)) as EmployeeServices,  
	(select stuff((select distinct '',''+ CAST(s.ServiceCode as varchar(5))
										from x_Dept_Employee_Service x_des
										join x_Dept_Employee x_de
										on x_des.DeptEmployeeID = x_de.DeptEmployeeID
										and x_de.active = 1
										join [Services] s
										on x_des.serviceCode = s.ServiceCode
										and s.IsProfession = 0
										where x_de.deptCode = d.DeptCode
										and x_des.Status = 1
										for xml path('''')),1,1,''''
							)) as EmployeeServiceCode '	
		 + @NewLineChar;
end

if(@DeptServices = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ''''' as DeptServices, ''''as DeptServiceCode '
		--'dbo.rfn_GetDeptServiceDescriptions(d.DeptCode) as DeptServices  
		--,dbo.rfn_GetDeptServiceCodes(d.DeptCode) as DeptServiceCode  '  -- todo: ALTER FUNCTION fun_GetDeptServiceCodes
		+ @NewLineChar;
end

if(@DeptCoordinates = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
		'CONVERT(decimal(10,3), x_dept_XY.xcoord ) as XCoord  
		,CONVERT(decimal(10,3), x_dept_XY.ycoord ) as YCoord 
		,CONVERT(decimal(15,13), x_dept_XY.XLongitude ) as XLongitude 
		,CONVERT(decimal(15,13), x_dept_XY.YLatitude ) as YLatitude 			
		'  -- todo: create function fun_GetDeptServiceCodes
		+ @NewLineChar;
end

--=================================================================
SET @SqlWhere = ' WHERE 1=1 '
IF(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere +
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString( @xDistrictCodes ) as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF(@StatusCodes <> '-1')
	SET @SqlWhere = @SqlWhere +	
	' AND (d.Status IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '

IF(@CitiesCodes <> '-1' AND @CitiesCodes <> '')
	SET @SqlWhere = @SqlWhere +	
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '

IF(@UnitedServiceCodes <> '-1')
	BEGIN
		SET @SqlWhere = @SqlWhere +	
		' AND (	(SELECT count(*) 
				FROM x_Dept_Employee_Service 
				join x_Dept_Employee 
				on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
				'

		IF(@StatusCodes <> '-1')			
			SET @SqlWhere = @SqlWhere +	
				'AND x_Dept_Employee_Service.Status = @xStatusCodes 
				'
				
		SET @SqlWhere = @SqlWhere +					
				'WHERE x_Dept_Employee.deptCode = d.deptCode 
				AND ServiceCode IN (SELECT IntField FROM dbo.SplitString(@xUnitedServiceCodes ))) > 0 ) '
	END		

IF(@Membership_cond <> '-1')
	SET @SqlWhere = @SqlWhere +			
	' AND ( 
		   d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )) 
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )) 
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )) 
		) '
IF(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.administrationCode in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
IF(@UnitTypeCodes <> '-1' AND @UnitTypeCodes <> '')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.typeUnitCode in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes ))) '
IF(@SubUnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND ( d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes ))) '
IF(@SectorCodes <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( @xSectorCodes ))) '

set @sql = @sql + @sqlFrom + @SqlWhere + @sqlEnd 

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql


EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xServiceCodes = @ServiceCodes, 
	@xUnitTypeCodes = @UnitTypeCodes,
	@xSubUnitTypeCodes = @SubUnitTypeCodes,
	@xStatusCodes = @StatusCodes, 
	@xSectorCodes = @SectorCodes,
	@xProfessionCodes = @ProfessionCodes, 
	@xUnitedServiceCodes = @UnitedServiceCodes,		 
	@xCitiesCodes = @CitiesCodes, 
	@xMembership_cond = @Membership_cond	 
SET @ErrCode = @sql 
RETURN
GO

ALTER Procedure [dbo].rprt_EmployeeReceptions
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@CitiesCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@PositionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,
	@EmployeeSex_cond varchar(max)=null, 
	@ValidFrom_cond varchar(max)=null,
	@ValidTo_cond varchar(max)=null,

	@district varchar (2)= null,
	@adminClinic varchar (2) = null,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,

	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,

	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	
	@EmployeeLanguages varchar(2)= null,	

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xCitiesCodes varchar(max)=null, 	 
	@xEmployeeSector_cond varchar(max)=null,	
	@xUnitTypeCodes varchar(max)=null,
	@xSubUnitTypeCodes varchar(max)=null,
	@xServiceCodes varchar(max)=null, 	 
	@xProfessionCodes varchar(max)=null,
	@xUnitedServiceCodes varchar(max)=null,	
	@xPositionCodes varchar(max)=null,
	@xExpertProfessionCodes varchar(max)=null,
	@xAgreementType_cond varchar(max)=null,
	@xValidFrom_cond varchar(max)=null,
	@xValidTo_cond varchar(max)=null	
'

SET @Declarations = ''

---------------------------

SET @sql = 'SELECT distinct * FROM (SELECT ' + @NewLineChar;
SET @sqlEnd = ') as resultTable '
				+' order by EmployeeLastName' + @NewLineChar;

SET @SqlFrom = 'FROM Employee 
LEFT JOIN x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID '
if(@DistrictCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) '
if(@EmployeeSector_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond )) ) '
if(@EmployeeSex_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (Employee.Sex IN (SELECT IntField FROM dbo.SplitString(@xEmployeeSex_cond ))) '
if(@PositionCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (
		(	SELECT count(*) 
			FROM x_Dept_Employee_Position 
			JOIN x_Dept_Employee xde
				on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
			WHERE Employee.employeeID = xde.employeeID	
			AND positionCode IN (SELECT IntField FROM dbo.SplitString( @xPositionCodes ))) > 0
		) '
if(@UnitedServiceCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 			
	' AND (
		(	SELECT count(*) 
			FROM EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID								
			AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) > 0
		) '
if(@ExpertProfessionCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (
		(	SELECT count(*) 
			FROM  EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID AND EmployeeServices.expProfession = 1
			AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0
		) '
if(@AgreementType_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@xAgreementType_cond ))) '

SET @SqlFrom = @SqlFrom +
' LEFT JOIN Dept as d ON d.deptCode = x_Dept_Employee.deptCode '
if(@AdminClinicCode <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.administrationCode in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
if(@UnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.typeUnitCode in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
if(@SubUnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )) ) '
if(@CitiesCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
if(@adminClinic = '1') 
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN dept as dAdmin ON d.administrationCode = dAdmin.deptCode '
if(@district = '1')
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN dept as dDistrict ON Employee.primaryDistrict = dDistrict.deptCode '

SET @SqlFrom = @SqlFrom +
' LEFT JOIN View_UnitType as UnitType ON d.typeUnitCode =  UnitType.UnitTypeCode   
LEFT JOIN View_SubUnitTypes as SubUnitType ON d.subUnitTypeCode =  SubUnitType.subUnitTypeCode AND  d.typeUnitCode =  SubUnitType.UnitTypeCode '
if(@simul = '1')
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '

if(@EmployeeSector = '1')
	SET @SqlFrom = @SqlFrom +	
	' INNER JOIN View_EmployeeSector ON Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '
SET @SqlFrom = @SqlFrom +
' LEFT JOIN dbo.View_DeptEmployeeReceptions AS V_DEReception 
	ON x_Dept_Employee.deptCode = V_DEReception.deptCode
	AND x_Dept_Employee.AgreementType = V_DEReception.AgreementType
	AND x_Dept_Employee.employeeID = V_DEReception.employeeID '
if(@ValidFrom_cond <> '-1' OR @ValidTo_cond <> '-1')
	SET @SqlFrom = @SqlFrom +		
' JOIN Employee as Emp3 ON Employee.employeeID = Emp3.employeeID 
	 AND[dbo].rfn_CheckExpirationDate_str
	(CONVERT(varchar(10), V_DEReception.validFrom, 20),
	 CONVERT(varchar(10), V_DEReception.validTo, 20), 
	  IsNull(@xValidFrom_cond, null),
	  IsNull(@xValidTo_cond, null)) = 1 '
if(@EmployeeExpertProfession = '1')
	SET @SqlFrom = @SqlFrom +	 
' LEFT JOIN [dbo].View_EmployeeExpertProfessions as DEExpProfessions 
	on Employee.employeeID = DEExpProfessions.employeeID '
if(@EmployeePosition = '1' )
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		ON x_Dept_Employee.deptCode = DEPositions.deptCode
		AND x_Dept_Employee.AgreementType = DEPositions.AgreementType
		AND Employee.employeeID = DEPositions.employeeID ' 
		
SET @SqlWhere = ' WHERE 1=1 AND x_Dept_Employee.active = 1 '

 
if(@EmployeeName = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@district = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		SET @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end
	
if(@adminClinic = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 

--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@EmployeePosition = '1' )
	begin
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeExpertProfession = '1')
	begin
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

	
if (@EmployeeSex = '1')
begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end


------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@EmployeeServices = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'V_DEReception.serviceDescription  as serviceDescription,
	 V_DEReception.serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @EmployeeProfessions -------------------------------------------------------

if(@EmployeeProfessions = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'V_DEReception.ProfessionDescription  as ProfessionDescription,
	 V_DEReception.ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' V_DEReception.ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 
		

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' V_DEReception.openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' V_DEReception.closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' V_DEReception.totalHours  as totalHours ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' CONVERT(varchar(10), V_DEReception.validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' CONVERT(varchar(10), V_DEReception.validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' V_DEReception.remarkText  as RecepRemark ' + @NewLineChar;
end 
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_GetEmployeeLanguages(Employee.employeeID) as EmployeeLanguages' 
			+ @NewLineChar;
end 

--=================================================================
set @sql = @sql + @SqlFrom + @sqlWhere + @sqlEnd
 
SET @sql = 'SET DATEFORMAT dmy ' + @NewLineChar + @sql + @NewLineChar + 'SET DATEFORMAT mdy;'

--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql 
			
SET DATEFORMAT dmy;

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xCitiesCodes = @CitiesCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xUnitTypeCodes = @UnitTypeCodes,			
	@xSubUnitTypeCodes = @SubUnitTypeCodes,
	@xServiceCodes = @ServiceCodes,	
	@xProfessionCodes = @ProfessionCodes,
	@xUnitedServiceCodes = @UnitedServiceCodes,			
	@xPositionCodes = @PositionCodes,
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xAgreementType_cond = @AgreementType_cond,
	@xValidFrom_cond = @ValidFrom_cond,	
	@xValidTo_cond = @ValidTo_cond

SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 
GO

ALTER Procedure [dbo].[rprt_DeptEmployeeReceptions]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@UnitTypeCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,

	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,-- NEW	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null, 
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,

	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@ReceptionRoom varchar (2)=null,	
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	@EmployeeLanguages varchar(2)= null, 
	@IsExcelVersion varchar (2)=null,

	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @sqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xUnitTypeCodes varchar(max)=null,
	@xEmployeeSector_cond varchar(max)=null,	
	@xUnitedServiceCodes varchar(max)=null,		 
	@xExpertProfessionCodes varchar(max)=null,
	@xCitiesCodes varchar(max)=null, 	 
	@xAgreementType_cond varchar(max)=null
'

SET @Declarations = 'DECLARE @DateNow as date = GETDATE()
'

---------------------------
set @sql = 'SELECT distinct * FROM
			(SELECT ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM Dept as d    
JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID '
if(@EmployeeSector = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '
if(@AgreementType = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	' JOIN DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID '
if(@adminClinic = '1' )
	set @sqlFrom = @sqlFrom + @NewLineChar +
	'LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode ' 
if(@district = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode '
if(@unitType = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode	'
if(@subUnitType = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode	 
		AND d.typeUnitCode = SubUnitType.UnitTypeCode '
if(@simul = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode '
if(@city = '1')	
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	'LEFT JOIN Cities on d.CityCode =  Cities.CityCode '
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	'LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '
set @sqlFrom = @sqlFrom + @NewLineChar +
'cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails '
if(@DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	'LEFT JOIN DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
	LEFT JOIN DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 '
if(@DeptEmployeeFax = '1')		
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	'LEFT JOIN DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 '
if(@DeptEmployeePhone = '1' OR @Phone1 = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 ' 
if(@DeptEmployeePhone = '1' OR @Phone2 = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 '
if(@DeptEmployeeFax = '1' OR @Fax = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '
if(@sector = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '
if(@EmployeeExpertProfession = '1') 	
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
		on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
		and x_Dept_Employee.AgreementType = DEExpProfessions.AgreementType
		and Employee.employeeID = DEExpProfessions.employeeID '
if(@Position = '1' ) 		
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID '
if(@DeptEmployeeRemark = '1' )		
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and Employee.employeeID = DERemarks.employeeID '
set @sqlFrom = @sqlFrom + @NewLineChar +		
'		
------------ Dept and services Reception --------------
LEFT JOIN dbo.View_DeptEmployeeReceptions AS DeptReception on x_Dept_Employee.deptCode = DeptReception.deptCode
	and x_Dept_Employee.employeeID = DeptReception.employeeID ' + @NewLineChar;		
----------------------------------------------------------------------------------
SET @SqlWhere = ' WHERE 1=1 AND x_Dept_Employee.active = 1 
AND (DeptReception.validTo is null OR  DeptReception.validTo > @DateNow)
'
if(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString( @xDistrictCodes ) as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )'
if(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.administrationCode  in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )))'
if(@UnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) )'
if(@CitiesCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) )'
if(@AgreementType_cond <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@xAgreementType_cond ))) '
	
if(@UnitedServiceCodes <> '-1' AND @EmployeeSector_cond = '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	'AND (
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS 
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) > 0
	)'
if(@UnitedServiceCodes <> '-1' AND @EmployeeSector_cond <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	'AND (
		(	SELECT count(*) 
			FROM x_Dept_Employee_Service as xDES
			JOIN Services S ON xDES.serviceCode = S.ServiceCode
			WHERE xDES.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			AND (
					( Employee.IsMedicalTeam = 1 
					AND
					S.SectorToShowWith IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond ))
					)
					OR
					( Employee.IsMedicalTeam <> 1 
					AND
					Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond ))
					)					
				)

			AND xDES.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))
		) > 0
	)'	

if(@ExpertProfessionCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	'AND (
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDS 
		LEFT JOIN EmployeeServices on x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDS.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0
	)'	

if(@EmployeeSector_cond <> '-1' AND @ExpertProfessionCodes = '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	'AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond )) )'

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end

if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end



if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	

------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@DeptEmployeeServices = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceDescription  as serviceDescription,
	 [DeptReception].serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @Professions -------------------------------------------------------

if(@Professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].ProfessionDescription  as ProfessionDescription,
	 [DeptReception].ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' [DeptReception].ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].totalHours  as totalHours ' + @NewLineChar;
end 

----------- ReceptionRoom --------------------------------------------------
if(@ReceptionRoom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].ReceptionRoom  as receptionRoom ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].remarkText  as RecepRemark ' + @NewLineChar;
end 
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_GetEmployeeLanguages(Employee.employeeID) as EmployeeLanguages' 
			+ @NewLineChar;
end 
--=================================================================

set @sql = @Declarations + @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
-- Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xUnitTypeCodes = @UnitTypeCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xUnitedServiceCodes = @UnitedServiceCodes,		
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xCitiesCodes = @CitiesCodes,
	@xAgreementType_cond = @AgreementType_cond


SET @ErrCode = @sql 
RETURN 
GO

ALTER Procedure [dbo].[rprt_EmployeeWithNoReceptionHoursPerService]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@UnitTypeCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,-- NEW	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, 
	@EmployeeSex varchar(2)=null, 
	@EmployeeDegree varchar(2)= null,
	@EmployeeLanguages varchar(2)= null, 
	@ReceiveGuests varchar(2)= null,
			
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @sqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	 @xDistrictCodes varchar(max)=null,
	 @xAdminClinicCode varchar(max)=null,
	 @xUnitTypeCodes varchar(max)=null,
	 @xEmployeeSector_cond varchar(max)=null,	
	 @xServiceCodes varchar(max)=null, 
	 @xProfessionCodes varchar(max)=null,
	 @xUnitedServiceCodes varchar(max)=null,
	 @xExpertProfessionCodes varchar(max)=null,
	 @xCitiesCodes varchar(max)=null, 	 
	 @xAgreementType_cond varchar(max)=null
'

SET @Declarations = ''

---------------------------
set @sql = 'SELECT distinct * from (select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM Dept as d    
JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
JOIN vEmployeeServiceInClinicWithNoReception vEmpServNoReception ON x_Dept_Employee.deptEmployeeID = vEmpServNoReception.deptEmployeeID
JOIN EmployeeInClinic_preselected EmpPresel ON x_Dept_Employee.deptEmployeeID = EmpPresel.deptEmployeeID
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active ' + @NewLineChar;
if(@EmployeeSector = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode ' + @NewLineChar;
if(@adminClinic = '1' )
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode ' + @NewLineChar;
set @sqlFrom = @sqlFrom + 	
'LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode ' + @NewLineChar;
if(@unitType = '1')
	set @sqlFrom = @sqlFrom +   
	'LEFT JOIN View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode ' + @NewLineChar;
if(@subUnitType = '1')	
	set @sqlFrom = @sqlFrom +  
	'LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode = SubUnitType.subUnitTypeCode
		 and  d.typeUnitCode = SubUnitType.UnitTypeCode ' + @NewLineChar;
if(@city = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN Cities on d.CityCode = Cities.CityCode ' + @NewLineChar;
if(@simul = '1')
	set @sqlFrom = @sqlFrom +  
	' LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode ' + @NewLineChar;
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode ' + @NewLineChar;
if(@QueueOrderDescription = '1')	
	set @sqlFrom = @sqlFrom + 
	' cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails ' + @NewLineChar;
if(@DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom + 
	' LEFT JOIN DeptEmployeePhones as emplPh1 on x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
	 LEFT JOIN DeptEmployeePhones as emplPh2 on x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 ' + @NewLineChar;
if(@Fax = '1' OR @DeptEmployeeFax = '1')
	set @sqlFrom = @sqlFrom + 		
	' LEFT JOIN DeptEmployeePhones as emplPh3 on x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 ' + @NewLineChar;
if(@Phone1 = '1' OR @DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom +  			
	' LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 ' + @NewLineChar;
if(@Phone2 = '1' OR @DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom +  		
	' LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 ' + @NewLineChar;
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 ' + @NewLineChar;
if(@Fax = '1' OR @DeptEmployeeFax = '1')
	set @sqlFrom = @sqlFrom + 		
	' LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 ' + @NewLineChar;
if(@sector = '1')	
	set @sqlFrom = @sqlFrom + 	
	' LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID ' + @NewLineChar;
if(@Position = '1' ) 
	set @sqlFrom = @sqlFrom +  
	'LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID ' + @NewLineChar;
if(@DeptEmployeeServices = '1' ) 
	set @sqlFrom = @sqlFrom +  	
	' LEFT JOIN [dbo].View_DeptEmployeeServices as DEServices 
		on x_Dept_Employee.deptCode = DEServices.deptCode 
		and x_Dept_Employee.AgreementType = DEServices.AgreementType
		and Employee.employeeID = DEServices.employeeID ' + @NewLineChar;
if(@DeptEmployeeRemark = '1' ) 
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and Employee.employeeID = DERemarks.employeeID ' + @NewLineChar;
if(@EmployeeDegree = '1')	
	set @sqlFrom = @sqlFrom +  		
	'LEFT JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode ' + @NewLineChar;

SET @SqlWhere = ' WHERE x_Dept_Employee.active = 1 '

IF(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )) ) '
IF(@UnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.typeUnitCode IN (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
IF(@CitiesCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
IF(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) ' + @NewLineChar;
IF(@AgreementType_cond <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond )) ) '
IF(@UnitedServiceCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 
	' AND ( vEmpServNoReception.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes )))
	'		  
IF(@ExpertProfessionCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND ( vEmpServNoReception.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))
			AND vEmpServNoReception.expProfession = 1) 
	'	
--IF(@ServiceCodes <> '-1')
--	SET @SqlWhere = @SqlWhere + 	  
--	' AND ( vEmpServNoReception.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xServiceCodes )))
--	'	
IF(@EmployeeSector_cond <> '-1' AND @ServiceCodes = '-1')
	SET @SqlWhere = @SqlWhere + 
	' AND ( CASE WHEN Employee.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												 THEN Employee.EmployeeSectorCode 
												 ELSE [Services].SectorToShowWith END
								FROM [Services]
								JOIN x_Dept_Employee_Service as xdes ON [Services].ServiceCode = xdes.ServiceCode
									AND xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
								), Employee.EmployeeSectorCode)
				 ELSE Employee.EmployeeSectorCode
				 END 
					= @xEmployeeSector_cond
	) '	
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
IF(@EmployeeSector_cond <> '-1' AND @ServiceCodes <> '-1')
	SET @SqlWhere = @SqlWhere +
	
	' AND ( CASE WHEN Employee.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												 THEN Employee.EmployeeSectorCode 
												 ELSE [Services].SectorToShowWith END
								FROM [Services]
								JOIN x_Dept_Employee_Service as xdes ON [Services].ServiceCode = xdes.ServiceCode
									AND xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
								), Employee.EmployeeSectorCode)
				 ELSE Employee.EmployeeSectorCode
				 END 
					= @xEmployeeSector_cond
	) '
	
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName, isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode, UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode, dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end 

if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode, ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@Professions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' CASE WHEN vEmpServNoReception.IsProfession = 1 
			  THEN vEmpServNoReception.ServiceDescription ELSE '''' END as ProfessionDescription
			, CASE CAST(vEmpServNoReception.IsProfession as varchar(2))
			  WHEN ''1'' THEN CAST(vEmpServNoReception.ServiceCode as varchar(6)) ELSE '''' END as ProfessionCode 
			  ' 
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' CASE CAST(vEmpServNoReception.expProfession as varchar(2)) 
			  WHEN ''1'' THEN '' מומחה/ית'' ELSE '''' END as ExpertProfessionDescription
			 ,vEmpServNoReception.expProfession as ExpertProfessionCode
			 ' 
	end

if(@DeptEmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' CASE WHEN vEmpServNoReception.IsService = 1 
			  THEN vEmpServNoReception.ServiceDescription ELSE '''' END as ServiceDescription
			, CASE CAST(vEmpServNoReception.IsService as varchar(2))
			  WHEN ''1'' THEN CAST(vEmpServNoReception.ServiceCode as varchar(6)) ELSE '''' END as ServiceCode 
			  ' 		
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' EmpPresel.EmployeeLanguageDescription as EmployeeLanguages' + @NewLineChar;
end 
	
if(@QueueOrderDescription = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
		+ @NewLineChar
	end	

if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpPresel.phone as EmployeePhone1 ' + @NewLineChar;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpPresel.fax as EmployeeFax ' + @NewLineChar;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql
		 + ' EmpPresel.AgreementType as AgreementTypeCode,
		 EmpPresel.AgreementTypeDescription as AgreementTypeDescription ' + @NewLineChar;
	end	

if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if(@ReceiveGuests = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CASE  WHEN EmpPresel.ReceiveGuests = 1 THEN ''כן'' ELSE ''לא'' END  as ReceiveGuests '+ @NewLineChar;
	end	
	
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
--=================================================================
--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
-- Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xUnitTypeCodes = @UnitTypeCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xServiceCodes = @ServiceCodes,
	@xProfessionCodes = @ProfessionCodes,
	@xUnitedServiceCodes = @UnitedServiceCodes,	
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xCitiesCodes = @CitiesCodes,
	@xAgreementType_cond = @AgreementType_cond--,
	--@xDeptEmployeeStatusCodes = @DeptEmployeeStatusCodes
 
SET @ErrCode = @sql 
RETURN 
GO

ALTER Procedure [dbo].[rprt_Employees]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@CitiesCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@PositionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,
	@EmployeeLanguage_cond varchar(max)=null, 
	@EmployeeSex_cond varchar(max)=null, 
	@StatusCodes varchar(max)=null,
	@DeptEmployeeStatusCodes varchar(max)=null,

	@district varchar (2)= null,	
	@ClinicDistrict varchar (2)= null,
	@adminClinic varchar (2) = null,		 
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, --  Dept QueueOrderDescription 

	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@EmployeeEmail varchar (2)=null,
	@ShowEmployeeEmailInInternet varchar (2)=null,
	@EmployeeHomePhone varchar (2)=null,
	@EmployeeCellPhone varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@EmployeeDegree varchar(2)= null,
	@EmployeeStatus varchar(2)= null,
	@DeptEmployeeStatus varchar(2)= null,
	
	@EmployeeLanguages varchar(2)= null, 

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(4000) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @sqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xCitiesCodes varchar(max)=null, 	 
	@xEmployeeSector_cond varchar(max)=null,	
	@xUnitTypeCodes varchar(max)=null,
	@xSubUnitTypeCodes varchar(max)=null,
	@xServiceCodes varchar(max)=null, 	 
	@xProfessionCodes varchar(max)=null,
	@xUnitedServiceCodes varchar(max)=null,
	@xPositionCodes varchar(max)=null,
	@xExpertProfessionCodes varchar(max)=null,
	@xAgreementType_cond varchar(max)=null,
	@xEmployeeLanguage_cond varchar(max)=null, 
	@xEmployeeSex_cond varchar(max)=null, 
	@xStatusCodes varchar(max)=null,
	@xDeptEmployeeStatusCodes varchar(max)=null
'

---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 'FROM Employee 
LEFT JOIN x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
LEFT JOIN Dept as d on d.deptCode = x_Dept_Employee.deptCode '

if(@EmployeeStatus = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active '
if(@DeptEmployeeStatus = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	'JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active '
if (@AgreementType = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	'JOIN DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID '
if(@EmployeeLanguage_cond <> '-1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN EmployeeLanguages on EmployeeLanguages.EmployeeID = Employee.employeeID '
if(@adminClinic = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode '
if(@district = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN dept as dDistrict on Employee.primaryDistrict = dDistrict.deptCode '
if(@ClinicDistrict = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN dept as deptDistrict on d.DistrictCode = deptDistrict.deptCode '
if(@simul = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode '
if(@city = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN Cities on d.CityCode =  Cities.CityCode ' 
SET @sqlFrom = @sqlFrom + @NewLineChar + 	
' cross apply rfn_GetDeptEmployeeQueueOrderDetails(x_Dept_Employee.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails '
if(@EmployeeSector = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '
if(@EmployeeDegree = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode '

if(@DeptEmployeePhone = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
'LEFT JOIN DeptEmployeePhones as emplPh1 on x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1
LEFT JOIN DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
LEFT JOIN DeptPhones as deptPh1  
	on d.deptCode = deptPh1.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh1.PhoneType = 1 and deptPh1.phoneOrder = 1  
LEFT JOIN DeptPhones as deptPh2  
	on d.deptCode = deptPh2.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh2.PhoneType = 1 and deptPh2.phoneOrder = 2 '

if(@DeptEmployeeFax = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN DeptEmployeePhones as emplPh3 on x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID 
		and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
	LEFT JOIN DeptPhones as deptPh3 
		on d.deptCode = deptPh3.deptCode 
		and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
		and deptPh3.PhoneType = 2 and deptPh3.phoneOrder = 1 '

if(@EmployeeHomePhone = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN EmployeePhones as  EmployeePhones1  on  Employee.employeeID = EmployeePhones1.employeeID 
	and EmployeePhones1.PhoneType = 1 and EmployeePhones1.phoneOrder = 1 '
if(@EmployeeCellPhone = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	 
	' LEFT JOIN EmployeePhones as EmployeePhones2  on Employee.employeeID = EmployeePhones2.employeeID 
	and EmployeePhones2.PhoneType = 3 and EmployeePhones2.phoneOrder = 1 '
if(@EmployeeProfessions = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN [dbo].View_EmployeeProfessions as DEProfessions	
		on Employee.employeeID = DEProfessions.employeeID '
if(@EmployeeExpertProfession = '1') 		
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	'LEFT JOIN [dbo].View_EmployeeExpertProfessions as DEExpProfessions 
		on Employee.employeeID = DEExpProfessions.employeeID '
if(@EmployeePosition = '1' ) 	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID '
if(@EmployeeServices = '1' )		
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN [dbo].View_EmployeeServices as DEServices 
		on Employee.employeeID = DEServices.employeeID '
if(@DeptEmployeeRemark = '1' )  -- changed		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	'LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and x_Dept_Employee.employeeID = DERemarks.employeeID '
		
SET @sqlWhere = ' WHERE 1=1 ';
if(@DistrictCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) '
if(@EmployeeSector_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond )) ) '
if(@EmployeeSex_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (Employee.Sex IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSex_cond ))) '
if(@StatusCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (Employee.active IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '
if(@PositionCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (
		(	SELECT count(*) 
			FROM x_Dept_Employee_Position 
			inner join x_Dept_Employee xde
			on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
			WHERE Employee.employeeID = xde.employeeID	
			AND positionCode IN (SELECT IntField FROM dbo.SplitString( @xPositionCodes ))) > 0
		) '
if(@UnitedServiceCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 		
	' AND (
		(	SELECT count(*) 
			FROM EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID								
			AND EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) > 0
		) '
if(@ExpertProfessionCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (
		(	SELECT count(*) 
			FROM  EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID 	and EmployeeServices.expProfession = 1
			and EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0
		) '
if(@AdminClinicCode <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (d.administrationCode  in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
if(@UnitTypeCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
if(@SubUnitTypeCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )) ) '
if(@CitiesCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
if(@AgreementType_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond ))) '
if(@DeptEmployeeStatusCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 		 
	' AND (x_Dept_Employee.active IN (SELECT IntField FROM dbo.SplitString( @xDeptEmployeeStatusCodes )) ) '
if(@EmployeeLanguage_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (EmployeeLanguages.LanguageCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeLanguage_cond )) ) '

if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '
		+ @NewLineChar;
	end
	
if(@ClinicDistrict = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + 'deptDistrict.DeptName as ClinicDistrictName , isNull(deptDistrict.deptCode , -1) as ClinicDistrictCode '
		+ @NewLineChar;
	end	

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 	

--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if (@AgreementType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
			+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
			DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
end

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	

if(@EmployeePosition = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeProfessions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEProfessions.ProfessionDescriptions as ProfessionDescription
			 ,DEProfessions.ProfessionCodes as ProfessionCode ' 
			+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@EmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEServices.ServiceDescriptions as ServiceDescription 
			,DEServices.ServiceCodes as ServiceCode' 
		+ @NewLineChar;
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end

if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if(@EmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpStatus.Status as StatusCode, EmpStatus.StatusDescription as StatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEmpStatus.Status as DeptEmployeeStatusCode, DeptEmpStatus.StatusDescription as DeptEmployeeStatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeePhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh1.prePrefix, deptPh1.Prefix, deptPh1.Phone, deptPh1.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh2.prePrefix, deptPh2.Prefix, deptPh2.Phone, deptPh2.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
end

if(@DeptEmployeeFax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh3.prePrefix, deptPh3.Prefix, deptPh3.Phone, deptPh3.Extension ) 
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
end	

if(@QueueOrderDescription = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql 
	+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
	+ @NewLineChar 
	+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
	+ @NewLineChar 
	+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
	+ @NewLineChar
	+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
	+ @NewLineChar
	+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
	+ @NewLineChar
end	

--------- homePhone ---------------------------------------------------------------
if(@EmployeeHomePhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(EmployeePhones1.prePrefix, EmployeePhones1.Prefix,EmployeePhones1.Phone, EmployeePhones1.extension ) as EmployeePrivatePhone1, 
				case when EmployeePhones1.isUnlisted = 1 then ''כן'' else ''לא'' end as EmployeePrivatePhone1_isUnlisted'
				+ @NewLineChar;
end

---------- cellPhone --------------------------------------------------------------------------------
if(@EmployeeCellPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(EmployeePhones2.prePrefix, EmployeePhones2.Prefix, EmployeePhones2.Phone, EmployeePhones2.extension) as EmployeePrivatePhone2, 
			case when EmployeePhones2.isUnlisted = 1 then ''כן'' else ''לא'' end as EmployeePrivatePhone2_isUnlisted'
			+ @NewLineChar;
end 
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_GetEmployeeLanguages(Employee.employeeID) as EmployeeLanguages' 
			+ @NewLineChar;
end 

--=================================================================
set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql 


EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xCitiesCodes = @CitiesCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xUnitTypeCodes = @UnitTypeCodes,			
	@xSubUnitTypeCodes = @SubUnitTypeCodes,
	@xServiceCodes = @ServiceCodes,	
	@xProfessionCodes = @ProfessionCodes,
	@xUnitedServiceCodes = @UnitedServiceCodes,		
	@xPositionCodes = @PositionCodes,
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xAgreementType_cond = @AgreementType_cond,
	@xEmployeeLanguage_cond = @EmployeeLanguage_cond,
	@xEmployeeSex_cond = @EmployeeSex_cond,	
	@xStatusCodes = @StatusCodes,
	@xDeptEmployeeStatusCodes = @DeptEmployeeStatusCodes
	
SET @ErrCode = @sql 
RETURN 
GO

ALTER Procedure [dbo].[rpc_GetDeptReceptionAndRemarks]
(
	@DeptCode int,
	@ExpirationDate datetime,
	@ServiceCodes varchar(100),
	@RemarkCategoriesForAbsence varchar(50),
	@RemarkCategoriesForClinicActivity varchar(50)
)
as

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForAbsence
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForAbsence)

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForClinicActivity
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForClinicActivity)

------ dept receptions ------------------------------------- OK!
	SELECT 
	DeptReception.receptionID,
	DeptReception.receptionDay,
	vReceptionDaysForDisplay.ReceptionDayName,
		CASE DeptReception.closingHour 
			WHEN '00:00' THEN	 
				CASE DeptReception.openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE DeptReception.openingHour END
			WHEN '23:59' THEN	
				CASE DeptReception.openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE DeptReception.openingHour END
			ELSE DeptReception.openingHour END as openingHour,
		CASE DeptReception.closingHour 
			WHEN '00:00' THEN	
				CASE DeptReception.openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE DeptReception.closingHour END
			WHEN '23:59' THEN	
				CASE DeptReception.openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE DeptReception.closingHour END
			ELSE DeptReception.closingHour END as closingHour,
		(select count(receptionDay) 
			FROM DeptReception
			where deptCode = @DeptCode
			and ((
			(validFrom is not null AND @ExpirationDate >= validFrom )
			and (validTo is not null and DATEDIFF(dd, validTo , @ExpirationDate) <= 0) )
			OR (validFrom IS NULL AND validTo IS NULL) )
		) as ReceptionDaysCount,	
		dbo.fun_getDeptReceptionRemarksValid(receptionID) as remarks,
		ValidTo as ExpirationDate,
		DATEDIFF(dd, GETDATE(), IsNull(ValidTo,'01/01/2050')) as WillExpireIn,
		ReceptionHoursTypeID
	INTO #DeptReception
	FROM DeptReception
	INNER JOIN vReceptionDaysForDisplay on DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
	WHERE deptCode = @DeptCode
	AND (validFrom is null OR @ExpirationDate >= validFrom )
	AND (validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0) 

IF EXISTS (SELECT * FROM #DeptReception WHERE ReceptionHoursTypeID = 1)
BEGIN

	SELECT DIC_ReceptionDays.ReceptionDayCode, T.receptionID, ISNULL( T.receptionDay, ReceptionDayCode ) as receptionDay  
	,ISNULL( T.ReceptionDayName, DIC_ReceptionDays.ReceptionDayName ) as ReceptionDayName
	,ISNULL(T.openingHour, '') as openingHour, ISNULL(T.closingHour, '') as closingHour
	,ISNULL(T.ReceptionDaysCount, 0) as ReceptionDaysCount
	,ISNULL(T.remarks, 'סגור') as remarks, T.ExpirationDate, ISNULL(T.WillExpireIn, 0) as WillExpireIn
	, ISNULL(T.ReceptionHoursTypeID, 1) as ReceptionHoursTypeID
	FROM DIC_ReceptionDays
	LEFT JOIN (	SELECT * FROM #DeptReception ) T
		ON DIC_ReceptionDays.ReceptionDayCode = T.receptionDay
	WHERE T.receptionDay is not null OR DIC_ReceptionDays.ReceptionDayCode <=7

	UNION

	SELECT #DeptReception.receptionDay as ReceptionDayCode,* FROM #DeptReception WHERE ReceptionHoursTypeID <> 1	

	ORDER BY DIC_ReceptionDays.ReceptionDayCode, openingHour
END
ELSE
BEGIN
	SELECT #DeptReception.receptionDay as ReceptionDayCode,* FROM #DeptReception WHERE ReceptionHoursTypeID <> 1	
	ORDER BY ReceptionDayCode, openingHour
END

--------- Clinic General Remarks ------------------------- OK!
SELECT View_DeptRemarks.remarkID
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark -- as 'sweeping' 
,GenRem.RemarkCategoryID
FROM View_DeptRemarks
JOIN DIC_GeneralRemarks GenRem ON View_DeptRemarks.DicRemarkID = GenRem.remarkID
LEFT JOIN #RemarkCategoriesForClinicActivity REMACT ON GenRem.RemarkCategoryID = REMACT.RemarkCategoryID
WHERE deptCode = @deptCode
--AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY REMACT.RemarkCategoryID DESC, IsSharedRemark DESC, validFrom, updateDate

-- Clinic name & District name
SELECT 
dept.deptName, 
View_AllDistricts.districtName,
cityName,
'address' = dbo.GetAddress(@DeptCode),
'phone' = (
	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
	FROM DeptPhones
	WHERE deptCode = @DeptCode
	AND phoneType = 1
	ORDER BY phoneOrder)
FROM dept
INNER JOIN View_AllDistricts ON dept.districtCode = View_AllDistricts.districtCode
INNER JOIN Cities ON dept.cityCode = Cities.cityCode
WHERE dept.deptCode = @DeptCode



--------- Dept Reception Remarks   -------------------------------------------------
SELECT
ReceptionID,
RemarkText
FROM DeptReceptionRemarks
WHERE ReceptionID IN (SELECT receptionID FROM DeptReception WHERE deptCode = @DeptCode)
AND validFrom <= @ExpirationDate 
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0) 

-- ReceptionDaysUnited for ClinicReception and OfficeServicesReception
-- it's useful to build synchronised GridView for both receptions
SELECT deptEmployeeReception.receptionDay, ReceptionDayName
FROM deptEmployeeReceptionServices
join deptEmployeeReception on deptEmployeeReceptionServices.receptionID = deptEmployeeReception.receptionID
INNER JOIN [Services] ON deptEmployeeReceptionServices.serviceCode = [Services].serviceCode
INNER JOIN vReceptionDaysForDisplay ON deptEmployeeReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
join x_Dept_Employee on deptEmployeeReception.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID


AND x_Dept_Employee.deptCode = @DeptCode
AND (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (@ExpirationDate >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @ExpirationDate)
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (@ExpirationDate >= validFrom and validTo >= @ExpirationDate))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)

UNION

SELECT DeptReception.receptionDay, ReceptionDayName
FROM DeptReception
INNER JOIN vReceptionDaysForDisplay ON DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE DeptReception.deptCode = @DeptCode
AND (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (@ExpirationDate >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @ExpirationDate)
				or ((validFrom IS not NULL and  validTo IS not NULL) and (@ExpirationDate >= validFrom and validTo >= @ExpirationDate))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)

ORDER BY receptionDay


-- closest dept reception change
SELECT MIN(ValidFrom)
FROM DeptReception
WHERE deptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14

-- closest office reception change
SELECT MIN(ValidFrom)
FROM DeptReception
WHERE ReceptionHoursTypeID = 2
AND deptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14

-- ReceptionHoursType
SELECT distinct DIC_ReceptionHoursTypes.ReceptionHoursTypeID,DIC_ReceptionHoursTypes.ReceptionTypeDescription FROM DeptReception
join DIC_ReceptionHoursTypes on DeptReception.ReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
where deptCode = @DeptCode

-- DefaultReceptionHoursType
SELECT DefaultReceptionHoursTypeID,DIC_ReceptionHoursTypes.ReceptionTypeDescription from subUnitType
join Dept on subUnitType.UnitTypeCode = Dept.typeUnitCode
and subUnitType.subUnitTypeCode = Dept.subUnitTypeCode
join DIC_ReceptionHoursTypes on subUnitType.DefaultReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
where Dept.deptCode = @DeptCode

-- Closest reception change for each ReceptionType
select min(d.validFrom) as nextDateChange, d.ReceptionHoursTypeID 
from DeptReception d
where (d.validFrom between GETDATE() and dateadd(day, 14, GETDATE())
	and deptCode = @DeptCode)
group by d.ReceptionHoursTypeID

------ Employee remarks -------------------------------------------------------------

SELECT distinct
dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark
,v_DE_ER.displayInInternet, '' as ServiceName, 0 as ServiceCode
,v_DE_ER.EmployeeID
,Employee.lastName
,Employee.IsMedicalTeam
,DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
,GenRem.RemarkCategoryID
,CASE WHEN CATABS.RemarkCategoryID IS null THEN 0 ELSE 1 END as AbsenceRemark
,v_DE_ER.ValidFrom
,v_DE_ER.updateDate 

INTO #Remarks

from View_DeptEmployee_EmployeeRemarks as v_DE_ER
JOIN Employee ON v_DE_ER.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
JOIN DIC_GeneralRemarks GenRem ON v_DE_ER.DicRemarkID = GenRem.remarkID
JOIN DIC_RemarkCategory RemCat ON GenRem.RemarkCategoryID = RemCat.RemarkCategoryID
JOIN x_Dept_Employee xDE ON v_DE_ER.DeptEmployeeID = xDE.DeptEmployeeID
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE v_DE_ER.DeptCode = @DeptCode

AND Employee.EmployeeSectorCode = 7
AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)
AND xDE.active = 1

------ Service remarks -------------------------------------------------------------
UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as remark
,displayInInternet, ServiceDescription + ': &nbsp;' as ServiceName, xdes.ServiceCode 
,xd.employeeID
,Employee.lastName
,Employee.IsMedicalTeam
,DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
,GenRem.RemarkCategoryID
,CASE WHEN CATABS.RemarkCategoryID IS null THEN 0 ELSE 1 END as AbsenceRemark
,desr.ValidFrom
,desr.updateDate 

FROM DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks GenRem ON desr.RemarkID = GenRem.remarkID
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
JOIN Employee ON xd.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE xd.DeptCode = @DeptCode

AND (@ServiceCodes is null OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCodes))) 
AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 )


SELECT DISTINCT employeeID, AbsenceRemark as HasAbsenceRemark
INTO #Absence
FROM #Remarks
WHERE AbsenceRemark = 1

SELECT *
FROM #Remarks
LEFT JOIN #Absence ON #Remarks.employeeID = #Absence.employeeID
ORDER BY #Absence.HasAbsenceRemark DESC,#Remarks.IsMedicalTeam, #Remarks.lastName, #Remarks.AbsenceRemark DESC
	,#Remarks.ValidFrom, #Remarks.updateDate

GO

ALTER Procedure [dbo].[rprt_EmployeeRemarks]
(
	@DistrictCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@Remark_cond varchar(max)=null,
	@IsRemarkAttributedToAllClinics_cond varchar(max)=null,
	@ShowRemarkInInternet_cond varchar(max)=null,
	@IsFutureRemark_cond varchar(max)=null,
	@IsValidRemark_cond varchar(max)=null,
	@AgreementType_cond varchar(max)=null,

	@district varchar (2)= null,
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,

	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Remark varchar (2)=null,
	@RemarkAttributedToAllClinics varchar (2)=null,
	@ShowRemarkInInternet varchar (2)=null,
	@RemarkValidFrom varchar (2)=null,
	@RemarkValidTo varchar (2)=null,

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

--SET variables 
DECLARE @params nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @SqlRemSelect nvarchar(max)
DECLARE @SqlServRemSelect nvarchar(max)
DECLARE @SqlTempServRemarks nvarchar(max)

SET @Declarations = 
' DECLARE @xDateNow date = GETDATE()
'

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xEmployeeSector_cond varchar(max)=null,
	@xProfessionCodes varchar(max)=null,
	@xRemark_cond varchar(max)=null,
	@xIsRemarkAttributedToAllClinics_cond varchar(max)=null,
	@xShowRemarkInInternet_cond varchar(max)=null,
	@xIsFutureRemark_cond varchar(max)=null,
	@xAgreementType_cond varchar(max)=null
'

---------------------------
SET @SqlTempServRemarks = 'SELECT x_Dept_Employee_Service.DeptEmployeeID
		, Services.ServiceDescription + '': '' + dbo.rfn_GetFotmatedRemark(DeptEmployeeServiceRemarks.RemarkText) AS ServiceRemark
		,DeptEmployeeServiceRemarks.RemarkID, DeptEmployeeServiceRemarks.DisplayInInternet
		, DeptEmployeeServiceRemarks.ValidFrom, DeptEmployeeServiceRemarks.ValidTo
		INTO #TempServiceRemarks
		FROM x_Dept_Employee_Service
		JOIN x_Dept_Employee ON x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		JOIN Employee ON x_Dept_Employee.EmployeeID = Employee.EmployeeID
		JOIN Services ON x_Dept_Employee_Service.serviceCode = Services.ServiceCode
		JOIN DeptEmployeeServiceRemarks ON x_Dept_Employee_Service.x_Dept_Employee_ServiceID = DeptEmployeeServiceRemarks.x_dept_employee_serviceID
		WHERE x_Dept_Employee_Service.Status = 1 AND Employee.IsMedicalTeam = 0
		' 

SET @sql = 'SELECT distinct * INTO #Tmp FROM (SELECT x_Dept_Employee.deptCode as dc ' + @NewLineChar;
SET @sqlEnd = ') AS resultTable '+ @NewLineChar;
SET @sqlWhere = '';


SET @sqlFrom = 'FROM Employee 
	JOIN Employee AS Emp ON Employee.employeeID = Emp.employeeID
	AND  Employee.Active = 1 '
IF(@DistrictCodes <> '-1')
SET @sqlFrom = @sqlFrom + @NewLineChar +
	' AND ( Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) '
IF(@EmployeeSector_cond <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(@xEmployeeSector_cond )) ) '
IF(@ProfessionCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	' AND EXISTS(	SELECT * FROM EmployeeServices 
					WHERE Employee.employeeID = EmployeeServices.employeeID								
					AND EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( @xProfessionCodes )))
					 '
	
SET @sqlFrom = @sqlFrom + @NewLineChar +	
' JOIN x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
LEFT JOIN Dept AS d ON d.deptCode = x_Dept_Employee.deptCode
JOIN View_DeptEmployeesCurrentStatus AS v_DECStatus 
	ON x_Dept_Employee.deptCode = v_DECStatus.deptCode
	AND Employee.employeeID = v_DECStatus.employeeID
	AND v_DECStatus.status = 1 
	'
IF(@AgreementType_cond <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	'AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond ))) 
	'

IF(@EmployeeProfessions = '1' ) 		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN [dbo].View_DeptEmployeeProfessions AS DEProfessions 
		ON x_Dept_Employee.deptCode = DEProfessions.deptCode
		AND x_Dept_Employee.AgreementType = DEProfessions.AgreementType
		AND Employee.employeeID = DEProfessions.employeeID '
IF(@EmployeePosition = '1' ) 		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN [dbo].View_DeptEmployeePositions AS DEPositions 
		ON x_Dept_Employee.deptCode = DEPositions.deptCode
		AND x_Dept_Employee.AgreementType = DEPositions.AgreementType
		AND Employee.employeeID = DEPositions.employeeID '
IF(@AgreementType = '1' )		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN DIC_AgreementTypes ON x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID '
IF(@adminClinic = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN dept AS dAdmin ON d.administrationCode = dAdmin.deptCode '
IF(@district = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN dept AS dDistrict ON d.districtCode = dDistrict.deptCode '
IF(@simul = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '
IF(@city = '1') 
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN Cities ON d.CityCode =  Cities.CityCode '
IF(@EmployeeSector = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	' INNER JOIN View_EmployeeSector ON Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '

--==========================================
SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
SET @sql = @sql + ' x_Dept_Employee.DeptEmployeeID '

IF(@district = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		SET @sql = @sql + ' dDistrict.DeptName AS DistrictName, isNull(dDistrict.deptCode, -1) AS DeptCode '+ @NewLineChar;
	end
IF(@adminClinic = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' dAdmin.DeptName AS AdminClinicName, isNull(dAdmin.DeptCode, -1) AS AdminClinicCode '+ @NewLineChar;
	end 
	
-------------- Clinic----------------------------
IF( @ClinicName= '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'd.DeptName AS ClinicName ' + @NewLineChar;	
	end

IF( @ClinicCode= '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' d.deptCode AS ClinicCode ' + @NewLineChar;	
	end

IF(@simul = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'deptSimul.Simul228 AS Code228 '+ @NewLineChar;
	end 

IF(@city = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		SET @sql = @sql + ' Cities.CityCode AS CityCode, Cities.CityName AS CityName'+ @NewLineChar;
	end

IF (@address = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'dbo.GetAddress(d.deptCode) AS ClinicAddress '+ @NewLineChar;
	end	

------------------------------- Employee --------------------------------------------
IF(@EmployeeName = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'Employee.firstName AS EmployeeFirstName, Employee.lastName AS EmployeeLastName'+ @NewLineChar;
	end
	
IF(@EmployeeID = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeID AS EmployeeID '+ @NewLineChar;
	end

IF(@EmployeeSector = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeSectorCode AS EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription AS EmployeeSectorDescription'+ @NewLineChar;
	end

IF(@EmployeePosition = '1' ) 
	begin
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
			' DEPositions.PositionDescriptions AS PositionDescription
			 ,DEPositions.PositionCodes AS PositionCode' 
		+ @NewLineChar;
	end
	
IF(@EmployeeProfessions = '1' ) 
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql +
			' DEProfessions.ProfessionDescriptions AS ProfessionDescription
			 ,DEProfessions.ProfessionCodes AS ProfessionCode ' 
			+ @NewLineChar;
	end

IF(@AgreementType = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
		+ 'DIC_AgreementTypes.AgreementTypeID AS AgreementTypeCode,
			DIC_AgreementTypes.AgreementTypeDescription AS AgreementTypeDescription '
		+ @NewLineChar;
	end	

--=================================================================

SET @Sql = @Declarations + @Sql + @SqlFrom + @sqlWhere + @sqlEnd

--Exec rpc_HelperLongPrint @Sql 

-- remarks select

SET @SqlRemSelect = @Sql +
	'
	SELECT DISTINCT T.* '
--------- Remarks ---------------------------
IF(@Remark = '1')
	begin 
		SET @SqlRemSelect = @SqlRemSelect +
		', v_DepEm_EmRem.RemarkTextFormated AS RemarkText,
		v_DepEm_EmRem.DicRemarkID AS RemarkID
		, '''' as ServiceRemark
		'
	end	
IF(@ShowRemarkInInternet = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + 
		', case when v_DepEm_EmRem.displayInInternet = 1 then ''כן'' else ''לא'' end AS ShowRemarkInInternet'
	end	
IF(@RemarkAttributedToAllClinics = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + 
		', case when v_DepEm_EmRem.AttributedToAllClinicsInCommunity = 1 then ''כן'' else ''לא'' end AS RemarkAttributedToAllClinics '
	end	
IF(@RemarkValidFrom = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + ', v_DepEm_EmRem.ValidFrom AS RemarkValidFrom '
	end		
IF(@RemarkValidTo = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + ', v_DepEm_EmRem.ValidTo AS RemarkValidTo '
	end		
-------------------------------------------------	7
SET @SqlRemSelect = @SqlRemSelect +	
	'
	FROM #Tmp T
	LEFT JOIN View_DeptEmployee_EmployeeRemarks AS v_DepEm_EmRem 
		ON T.dc = v_DepEm_EmRem.DeptCode
		AND T.EmployeeID = v_DepEm_EmRem.EmployeeID
	'
IF(@ShowRemarkInInternet_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + 		
	' AND (v_DepEm_EmRem.displayInInternet IN (SELECT IntField FROM dbo.SplitString( @xShowRemarkInInternet_cond )) ) 
	'
IF(@IsValidRemark_cond = '1')
	SET @SqlRemSelect = @SqlRemSelect + 
	' AND (v_DepEm_EmRem.ValidFrom <= @xDateNow 
			AND (v_DepEm_EmRem.ValidTo is NULL OR v_DepEm_EmRem.ValidTo >= @xDateNow)
			)
	'
IF(@IsValidRemark_cond = '0')
	SET @SqlRemSelect = @SqlRemSelect + 
	' AND (v_DepEm_EmRem.ValidFrom > @xDateNow 
			OR (v_DepEm_EmRem.ValidTo is NOT NULL AND v_DepEm_EmRem.ValidTo < @xDateNow)
			)
	'	
IF(@Remark_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + 	
	' AND (v_DepEm_EmRem.DicRemarkID IN (SELECT IntField FROM dbo.SplitString( @xRemark_cond )) ) 
	'
IF(@IsRemarkAttributedToAllClinics_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + @NewLineChar +		
	' AND (v_DepEm_EmRem.AttributedToAllClinicsInCommunity IN (SELECT IntField FROM dbo.SplitString( @xIsRemarkAttributedToAllClinics_cond )) ) '
IF(@IsFutureRemark_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + @NewLineChar +		
	' AND (	 @xIsFutureRemark_cond = ''1'' AND v_DepEm_EmRem.validFrom >= GETDATE()
		 OR  @xIsFutureRemark_cond = ''0'' AND v_DepEm_EmRem.validFrom < GETDATE() 
		) '
IF(@Remark = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect +
		'WHERE v_DepEm_EmRem.DicRemarkID is not null'
	end	
	
-- Service remarks select

SET @SqlServRemSelect = 
	'
	UNION 
	
	SELECT DISTINCT T.* '
--------- Remarks ---------------------------
IF(@Remark = '1')
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect +
		', '''' AS RemarkText,
		#TempServiceRemarks.RemarkID
		, #TempServiceRemarks.ServiceRemark as ServiceRemark
		'
	end	
IF(@ShowRemarkInInternet = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + 
		', case when #TempServiceRemarks.displayInInternet = 1 then ''כן'' else ''לא'' end AS ShowRemarkInInternet'
	end	
IF(@RemarkAttributedToAllClinics = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + 
		', '' '' AS RemarkAttributedToAllClinics '
	end	
IF(@RemarkValidFrom = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + ', #TempServiceRemarks.ValidFrom AS RemarkValidFrom '
	end		
IF(@RemarkValidTo = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + ', #TempServiceRemarks.ValidTo AS RemarkValidTo '
	end		
-------------------------------------------------	7
SET @SqlServRemSelect = @SqlServRemSelect +	
	'
	FROM #Tmp T
	JOIN #TempServiceRemarks ON T.DeptEmployeeID = #TempServiceRemarks.DeptEmployeeID
	'
IF(@ShowRemarkInInternet_cond <> '-1')
	SET @SqlServRemSelect = @SqlServRemSelect + 		
	' AND (#TempServiceRemarks.displayInInternet IN (SELECT IntField FROM dbo.SplitString( @xShowRemarkInInternet_cond )) ) 
	'
IF(@IsValidRemark_cond = '1')
	SET @SqlServRemSelect = @SqlServRemSelect + 
	' AND (#TempServiceRemarks.ValidFrom <= @xDateNow 
			AND (#TempServiceRemarks.ValidTo is NULL OR #TempServiceRemarks.ValidTo >= @xDateNow)
			)
	'
IF(@IsValidRemark_cond = '0')
	SET @SqlServRemSelect = @SqlServRemSelect + 
	' AND (#TempServiceRemarks.ValidFrom > @xDateNow 
			OR (#TempServiceRemarks.ValidTo is NOT NULL AND #TempServiceRemarks.ValidTo < @xDateNow)
			)
	'	
IF(@Remark_cond <> '-1')
	SET @SqlServRemSelect = @SqlServRemSelect + 	
	' AND (#TempServiceRemarks.RemarkID IN (SELECT IntField FROM dbo.SplitString( @xRemark_cond )) ) 
	'

IF(@IsFutureRemark_cond <> '-1')
	SET @SqlServRemSelect = @SqlServRemSelect + @NewLineChar +		
	' AND (	 @xIsFutureRemark_cond = ''1'' AND #TempServiceRemarks.validFrom >= GETDATE()
		 OR  @xIsFutureRemark_cond = ''0'' AND #TempServiceRemarks.validFrom < GETDATE() 
		) '





--print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @Sql 

SET @Sql = @SqlTempServRemarks + @SqlRemSelect + @SqlServRemSelect

SET DATEFORMAT dmy;

EXECUTE sp_executesql @Sql, @params, 
	@xDistrictCodes = @DistrictCodes, 
	@xEmployeeSector_cond = @EmployeeSector_cond, 
	@xProfessionCodes = @ProfessionCodes, 
	@xRemark_cond = @Remark_cond, 
	@xIsRemarkAttributedToAllClinics_cond = @IsRemarkAttributedToAllClinics_cond, 
	@xShowRemarkInInternet_cond = @ShowRemarkInInternet_cond, 
	@xIsFutureRemark_cond = @IsFutureRemark_cond, 
	@xAgreementType_cond = @AgreementType_cond

SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 

GO