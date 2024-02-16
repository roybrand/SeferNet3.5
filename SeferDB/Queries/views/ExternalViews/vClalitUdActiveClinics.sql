use SeferNet
go

/*
שליפה עבור שולחן עבודה לשעות פעילות של מרפאה ביום השליפה
יש לשלוף אך ורק מרפאות מהסוג : 
מרכז בריאות הילד - 212
מרפאה כפרית - 101
מרפאה משולבת - 103
מרפאה ראשונית - 102

יש לשוף את השדות הבאים :
1.	קוד מחוז
2.	שם מחוז
3.	קוד מרפאה- סימול ישן
4.	קוד מרפאה – סימול חדש
5.	שם מרפאה
6.	שעות פעילות של מרפאה – לחלק ל-4 שדות (שעת פתיחה בוקר, שעת סגירה בוקר, שעת פתיחה אחר הצהריים, שעת סגירה אחר הצהריים)

*/

ALTER view [dbo].[vClalitUdActiveClinics]
as
select MahozCode, MohozName, OldClinicCode, NewClinicCode, ClinicName,
max([openingHour_1]) as OpeningHour1, max([closingHour_1]) as ClosingHour1,
max([openingHour_2]) as OpeningHour2, max([closingHour_2]) as ClosingHour2
from 
(
	select d.districtCode as MahozCode , distr.deptName as MohozName,
	ds.Simul228 as OldClinicCode, d.deptCode as NewClinicCode, d.deptName as ClinicName, 
					dr.receptionDay,
					dr.openingHour as Hours,
					row_number() over (partition by d.deptCode,dr.receptionDay 
										order by dr.openingHour
									) rn,
					'openingHour' + '_' + cast(row_number() over (partition by d.deptCode,dr.receptionDay 
																	order by dr.openingHour ) as varchar(2)) as Nr 

	from dept d 
	join DeptReception dr on d.deptCode = dr.deptCode and dr.receptionDay = datepart(dw,getdate())
	left join DeptReceptionRemarks drr on dr.receptionID = drr.ReceptionID
	left join deptSimul ds on d.deptCode = ds.deptCode and ds.closingDateSimul >= getdate()
	left join Dept distr on d.districtCode = distr.deptCode
	where d.status = 1 
	and (d.typeUnitCode BETWEEN 101 AND 103 OR d.typeUnitCode = 212)
	and dr.ReceptionHoursTypeID = 1
	and GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')  
	and (drr.RemarkID is null or drr.RemarkID <> 72)

	UNION

	select d.districtCode, distr.deptName as districtName,
	ds.Simul228 as oldDeptCode, d.deptCode, d.deptName, 
					dr.receptionDay,
					dr.closingHour as Hours,
					row_number() over (partition by d.deptCode,dr.receptionDay 
										order by dr.openingHour
									) rn,
					'closingHour' + '_' + cast(row_number() over (partition by d.deptCode,dr.receptionDay 
																	order by dr.openingHour ) as varchar(2)) as Nr 

	from dept d 
	join DeptReception dr on d.deptCode = dr.deptCode and dr.receptionDay = datepart(dw,getdate())
	left join DeptReceptionRemarks drr on dr.receptionID = drr.ReceptionID
	left join deptSimul ds on d.deptCode = ds.deptCode and ds.closingDateSimul >= getdate()
	left join Dept distr on d.districtCode = distr.deptCode
	where d.status = 1 
	and (d.typeUnitCode BETWEEN 101 AND 103 OR d.typeUnitCode = 212)
	and dr.ReceptionHoursTypeID = 1
	and GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')  
	and (drr.RemarkID is null or drr.RemarkID <> 72)
) a
pivot 
(max(Hours) for Nr in ([openingHour_1],[closingHour_1],[openingHour_2],[closingHour_2])
) AS PivotTable
group by  MahozCode, MohozName, OldClinicCode, NewClinicCode, ClinicName


union


select d.districtCode as MahozCode, distr.deptName as MohozName, ds.Simul228 as OldClinicCode, 
	d.deptcode as NewClinicCode, d.deptName as ClinicName,
NULL as OpeningHour1, NULL as ClosingHour1,
NULL as OpeningHour2, NULL as ClosingHour2
from Dept d
left join Dept distr on d.districtCode = distr.deptCode
left join deptSimul ds on d.deptCode = ds.deptCode and ds.closingDateSimul >= getdate()
where d.deptCode not in (select deptCode from DeptReception 
			where ReceptionHoursTypeID = 1 
			and DeptReception.receptionDay = datepart(dw,getdate()))
and d.status = 1 
and (d.typeUnitCode BETWEEN 101 AND 103 OR d.typeUnitCode = 212)

go

----grant select on vClalitUdActiveClinics to [clalit\CCFDevUsers]
----go
----grant select on vClalitUdActiveClinics to [clalit\IntranetDev]
----go

