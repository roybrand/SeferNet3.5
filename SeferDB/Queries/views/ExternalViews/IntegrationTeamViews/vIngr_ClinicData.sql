
/*-------------------------------------------------------------------------
Get all dept data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicData]'))
	DROP VIEW [dbo].vIngr_ClinicData
GO


CREATE VIEW [dbo].vIngr_ClinicData
AS

select d.deptCode as ClinicCode, ds.Simul228 as OldClinicCode, d.deptName as ClinicName, 
		d.typeUnitCode as TypeUnitCode, ut.UnitTypeName as UnitTypeName, 
		ISNULL(d.subUnitTypeCode, 0) as IsIndependent, sut.subUnitTypeName,
		d.districtCode as District, d.administrationCode as AdministrationCode, 
		d.cityCode as TownCode, c.cityName as TownName, 
		case when d.StreetCode is null then d.streetName else s.Name end as Street,
		d.house as HouseNo, d.addressComment as AddressComment, 
		d.zipCode, d.transportation as Bus, ISNULL(d.showUnitInInternet, ut.ShowInInternet) as ShowUnitInInternet,
		d.IsCommunity, d.IsMushlam,d.IsHospital, 
		case when dq.queueOrderMethod = 1 then 1 else 0 end as OrderByClinicPhoneNumber,
		case when dq.queueOrderMethod = 2 then 
     		(select dbo.fun_ParsePhoneNumberWithExtension(DPH.prePrefix, DPH.prefix, DPH.phone, DPH.extension) AS ClinicPhoneNumber                  
			FROM DeptQueueOrderPhones DPH 
			WHERE dq.queueOrderMethodID = DPH.queueOrderMethodID
			AND DPH.phoneType = 1 and DPH.phoneOrder = 1
			) else '' end as OrderBySpecialPhoneNumber ,
		case when dq.queueOrderMethod = 3 then '*2700' else '' end as  OrderByTelemarketingCenter,
		case when dq.queueOrderMethod = 4 then 1 else 0 end as OrderByInternet,
		case when d.QueueOrder = 4 then 1 else 0 end as OrderByClientClinic

from Dept d 
left join deptSimul ds
on d.deptCode = ds.deptCode
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on ISNULL(d.subUnitTypeCode, 0) = sut.subUnitTypeCode
left join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.StreetCode = s.StreetCode
left join DeptQueueOrderMethod dq
on d.deptCode = dq.deptCode
where d.status = 1

GO


GRANT SELECT ON [dbo].vIngr_ClinicData TO [public] AS [dbo]
GO
