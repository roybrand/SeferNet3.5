IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPharmacyDeptData]'))
	DROP VIEW [dbo].[vPharmacyDeptData]
GO

create VIEW [dbo].[vPharmacyDeptData]
AS

select d.deptCode, d.deptName, d.cityCode, c.cityName
	, d.StreetName, d.house, d.flat, d.entrance, d.floor, d.addresscomment
	,(SELECT dbo.rfn_GetFotmatedRemark(View_DeptRemarks.RemarkText) RemarkText
	  	   ,View_DeptRemarks.ShowOrder
		FROM View_DeptRemarks WHERE d.deptCode=View_DeptRemarks.deptCode 
		and  GETDATE() between ISNULL(View_DeptRemarks.validFrom,'1900-01-01') and ISNULL(View_DeptRemarks.validTo,'2079-01-01')
		AND View_DeptRemarks.displayInInternet =CAST(1 AS BIT) 
		FOR XML PATH ('Remark'),ROOT('Remarks'),type 
	) DeptRemarks
	,(select  DIC_PhoneTypes.PhoneTypeName [Type]        
			 ,case when DeptPhones.Preprefix = 2 
				   then '*' else CONVERT(varchar(10), DeptPhones.Preprefix) end as  Preprefix       
			 ,DIC_PhonePrefix.prefixValue Prefix       
			 ,DeptPhones.Phone Number        
			 ,DeptPhones.PhoneOrder [Order]        
			 ,DeptPhones.UpdateDate UpdateDate        
		from   dbo.deptPhones        
		inner join dbo.DIC_PhoneTypes        
		on DIC_PhoneTypes.phoneTypeCode=deptPhones.phoneType
		left join dbo.DIC_PhonePrefix   
		on DIC_PhonePrefix.prefixCode=deptPhones.prefix 
		where d.deptCode=deptPhones.DeptCode for xml path('Phone'),root('Phones'),type        
	) phones
	,(select receptiondayName Day, receptionDay DayCode,    
			(select OpeningHour 
					,ClosingHour
					,(select RemarkText         
						from DeptReceptionRemarks where DpRec.receptionID=DeptReceptionRemarks.ReceptionID   
						and  GETDATE() between ISNULL(DeptReceptionRemarks.validFrom,'1900-01-01') and ISNULL(deptreceptionremarks.validTo,'2079-01-01')  
						AND ISNULL(deptreceptionremarks.DisplayInInternet, 0) = CAST(1 AS BIT)
						for XML path ('Remark'),type)
				from DeptReception DpRec   
				left join DeptReceptionRemarks 
				on DpRec.ReceptionID = DeptReceptionRemarks.ReceptionID
				where DpRec.deptCode=Gdays.Deptcode and DpRec.receptionDay=Gdays.receptionDay  
				and DpRec.ReceptionHoursTypeID = 1 -- שעות קבלה
				and GETDATE() between ISNULL(DpRec.validFrom,'1900-01-01') and ISNULL(DpRec.validTo,'2079-01-01')     
				and (DeptReceptionRemarks.RemarkID is null or DeptReceptionRemarks.RemarkID <> 72) -- ישיבת צוות
				order by DpRec.receptionDay, DpRec.openingHour
				for XML path('Reception'),type) 
		from (select distinct Deptcode
					,receptiondayName
					,receptionDay 
				from dbo.DeptReception        
				inner join  dbo.DIC_ReceptionDays        
				on DIC_ReceptionDays.receptiondayCode=DeptReception.receptionDay         
				where d.Deptcode = DeptReception.deptCode  
				and DeptReception.ReceptionHoursTypeID = 1 -- שעות קבלה
				and GETDATE() between ISNULL(deptreception.validFrom,'1900-01-01') and ISNULL(deptreception.validTo,'2079-01-01')  
			) Gdays 
		for XML path ('DayInfo'),root('ReceptionHours'),type        
	) ReceptionHours
	, d.subUnitTypeCode        
	, sut.subUnitTypeName  
	, d.districtCode
	, xy.xcoord as xCoord
	, xy.ycoord as yCoord
	, xy.XLongitude as longCoord
	, xy.YLatitude as latCoord
from Dept d
join Cities c on d.cityCode = c.cityCode
join DIC_SubUnitTypes sut on sut.subUnitTypeCode = d.subUnitTypeCode
left join x_dept_XY xy on xy.deptCode = d.deptCode
where d.typeUnitCode = 401
and d.showUnitInInternet = 1
and d.status = 1
go


GRANT SELECT ON [dbo].[vPharmacyDeptData] TO [clalit\webuser] AS [dbo]
GO

GRANT SELECT ON [dbo].[vPharmacyDeptData] TO [clalit\Intranetdev] AS [dbo]
GO
