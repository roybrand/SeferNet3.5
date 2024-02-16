/****** Object:  View [dbo].[VFastDeptEnqripted]    Script Date: 11/06/2011 08:47:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VFastDeptEnqripted]'))
	DROP VIEW [dbo].[VFastDeptEnqripted]
GO

/*
	Select all Depts data that needed for Fast engine 
	Owner : Internet Team
*/
CREATE view [dbo].[VFastDeptEnqripted]        
as   

SELECT uniqueKey, deptCode, deptName, cityCode, cityName, StreetName, house, flat, 
		entrance, floor, parkingInClinic, addresscomment, typeUnitCode, UnitTypeName, 
		administrationCode, SubAdministrationCode, showUnitInInternet, ShowInInternet, 
		email, IsCommunity, IsMushlam, IsHospital, deptType, deptLevel, deptLevelDescription, 
		subUnitTypeCode, subUnitTypeName, managerName, administrativemanagerName, FacilityDescription, 
		FacilityDescription as FacilityDescriptionList,
		Transportation, DeptRemarks, updatedate, phones, ReceptionHours, shift, serviceCode, 
		replace(replace(serviceDescription,'"','``'), '''', '`') as serviceDescription, 
		isInCommunity, isInMushlam, IsInHospitals, DeptServiceRemarks, 
		CASE WHEN showPhonesFromDept=1 THEN phones else servicePhones END servicePhones, 
		ServiceReceptionHours, Serviceshift, showPhonesFromDept, ReceptionServiceHours, 
		ServiceQueueOrders,	replace(replace(ServiceList,'"','``'), '''', '`') as ServiceList, DeptDistinct, 
		replace(replace(ProfessionList,'"','``'), '''', '`') as ProfessionList,
		EmployeeListDept, UnitListDept, XCoord, YCoord
	FROM
	(select 
		ISNULL(right('0000000'+cast(dept.deptCode as varchar(20)),7)+right('0000000'+cast(ISNULL(services.serviceCode,'') as varchar(20)),7),'0') uniqueKey        
		,dept.deptCode  
		,dept.deptName        
		,dept.cityCode        
		,cities.cityName        
		,dept.StreetName        
		,dept.house        
		,dept.flat        
		,dept.entrance        
		,dept.floor        
		,dept.addresscomment        
		,dept.typeUnitCode        
		,UnitType.UnitTypeName   
		,dept.administrationCode 
		,dept.SubAdministrationCode  
		,dept.showUnitInInternet
		,UnitType.ShowInInternet
		,CASE WHEN dept.showEmailInInternet=1 THEN dept.email ELSE '' END email
		,dept.IsCommunity
		,dept.IsMushlam
		,dept.IsHospital
		,dept.deptType
		,dept.deptLevel
		,DIC_deptLevel.deptLevelDescription
		,dept.subUnitTypeCode
		,DIC_SubUnitTypes.subUnitTypeName
		,DIC_ParkingInClinic.parkingInClinicDescription as parkingInClinic
		,ISNULL((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
					from employee  
					INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode  
					INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID  
					INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID  
					and x_Dept_Employee.deptCode = dept.deptCode
					INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode  
					WHERE mappingPositions.mappedToManager = 1 AND employee.active = 1 AND x_dept_employee.active = 1
					and dept.showUnitInInternet =1 and UnitType.ShowInInternet=1
				) ,dept.managerName 
		) managerName  
		,ISNULL((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName  
					from employee  
					INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode  
					INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID  
					INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID  
					and x_Dept_Employee.deptCode = dept.deptCode
					INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode  
					WHERE mappingPositions.mappedToAdministrativeManager = 1 AND employee.active = 1 AND x_dept_employee.active = 1
					and dept.showUnitInInternet = 1 and UnitType.ShowInInternet= 1 
				) ,dept.administrativemanagerName 
		) administrativemanagerName   
		,case when 0 < (select count(*) from DeptHandicappedFacilities 
						join DIC_HandicappedFacilities
						on DeptHandicappedFacilities.FacilityCode = DIC_HandicappedFacilities.FacilityCode
						and DIC_HandicappedFacilities.Active = 1
						where DeptHandicappedFacilities.DeptCode=dept.deptCode) then 
			 stuff((select ';'+DIC_HandicappedFacilities.FacilityDescription         
					from dbo.DeptHandicappedFacilities        
					inner join dbo.DIC_HandicappedFacilities        
					on  DIC_HandicappedFacilities.FacilityCode=DeptHandicappedFacilities.FacilityCode        
					where DeptHandicappedFacilities.DeptCode=dept.deptCode and DIC_HandicappedFacilities.active=1       
					for xml path('')),1,1,'')
			else 'ללא' end 
		FacilityDescription        
		,(SELECT REPLACE( dept.Transportation,'#','')) Transportation
		,(SELECT dbo.rfn_GetFotmatedRemarkForInternet(View_DeptRemarks.RemarkText) RemarkText
		  	   ,View_DeptRemarks.ShowOrder
			FROM View_DeptRemarks WHERE dept.deptCode=View_DeptRemarks.deptCode 
			and  GETDATE() between ISNULL(View_DeptRemarks.validFrom,'1900-01-01') and ISNULL(View_DeptRemarks.validTo,'2079-01-01')
			AND View_DeptRemarks.displayInInternet =CAST(1 AS BIT)
			AND View_DeptRemarks.RemarkCategoryID <> 12			 
			FOR XML PATH ('Remark'),ROOT('Remarks'),type 
		) DeptRemarks
		,dept.updatedate      
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
			where dept.deptCode=deptPhones.DeptCode for xml path('Phone'),root('Phones'),type        
		) phones
		,(select receptiondayName Day, receptionDay DayCode,    
				(select OpeningHour 
						,ClosingHour
						,(select RemarkText as Text
							from DeptReceptionRemarks where DpRec.receptionID=DeptReceptionRemarks.ReceptionID   
							and  GETDATE() between ISNULL(DeptReceptionRemarks.validFrom,'1900-01-01') and ISNULL(deptreceptionremarks.validTo,'2079-01-01')  
							--AND ISNULL(deptreceptionremarks.DisplayInInternet, 0) = CAST(1 AS BIT)
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
					where dept.Deptcode = DeptReception.deptCode  
					and DeptReception.ReceptionHoursTypeID = 1 -- שעות קבלה
					and GETDATE() between ISNULL(deptreception.validFrom,'1900-01-01') and ISNULL(deptreception.validTo,'2079-01-01')  
				) Gdays 
			for XML path ('DayInfo'),root('ReceptionHours'),type        
		) ReceptionHours
		,VFastDeptShift.shift as shift
		,ISNULL(x_Dept_Employee_Service.serviceCode,0) serviceCode
		,services.serviceDescription
		,ISNULL(services.isInCommunity, 0) isInCommunity
		,ISNULL(services.isInMushlam, 0) isInMushlam
		,ISNULL(services.IsInHospitals, 0) IsInHospitals
		,(SELECT REPLACE(DeptEmployeeServiceRemarks.RemarkText,'#','') RemarkText	
			FROM DeptEmployeeServiceRemarks
			where x_Dept_Employee_Service.DeptEmployeeServiceRemarkID=DeptEmployeeServiceRemarks.DeptEmployeeServiceRemarkID 
			and GETDATE() between ISNULL(DeptEmployeeServiceRemarks.ValidFrom,'1900-01-01') and ISNULL(DeptEmployeeServiceRemarks.ValidTo,'2079-01-01')  
			AND DeptEmployeeServiceRemarks.displayInInternet=CAST(1 AS BIT)
			for XML path ('Remark'),root('Remarks'),type
		) DeptServiceRemarks
		,(select DIC_PhoneTypes.PhoneTypeName Type,        
				case when EmployeeServicePhones.Preprefix = 2 then '*' 
					 else CONVERT(varchar(10), EmployeeServicePhones.Preprefix) end as  Preprefix,
				DIC_PhonePrefix.prefixValue Prefix,        
				EmployeeServicePhones.Phone Number,        
				EmployeeServicePhones.PhoneOrder [Order],        
				EmployeeServicePhones.UpdateDate        
			from dbo.EmployeeServicePhones         
			inner join DIC_PhoneTypes         
			on DIC_PhoneTypes.phoneTypeCode=EmployeeServicePhones.phoneType  
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=EmployeeServicePhones.prefix
			where x_Dept_Employee_Service.x_Dept_Employee_ServiceID=EmployeeServicePhones.x_Dept_Employee_ServiceID  
			for xml path('Phone'),root('Phones'),type
		) servicePhones 
		,(select Gdays.ReceptionDayName Day, 
				Gdays.receptionDay DayCode,
				(select OpeningHour ,ClosingHour        
						,(select REPLACE(derr.RemarkText,'#','') as Text       
							from DeptEmployeeReceptionRemarks derr      
							where derr.EmployeeReceptionID= der2.receptionID     
							and GETDATE() between ISNULL(derr.ValidFrom,'1900-01-01') and ISNULL(derr.ValidTo,'2079-01-01')       
							for XML path ('Remark'),type )        
					from deptEmployeeReception der2          
					where der2.receptionID = Gdays.receptionID   
					and GETDATE() between ISNULL(der2.validFrom,'1900-01-01') and ISNULL(der2.validTo,'2079-01-01')      
					order by Gdays.receptionDay, OpeningHour
					for XML path('Reception'),type 
				)
			from
				(select distinct DIC_ReceptionDays.ReceptionDayName, der.ReceptionDay,
								der.receptionID,der.DeptEmployeeID        
				from deptEmployeeReception  der
				join deptEmployeeReceptionServices ders
				on der.receptionID = ders.receptionID
				and ders.serviceCode = x_Dept_Employee_Service.serviceCode
				join DIC_ReceptionDays
				on der.receptionDay = DIC_ReceptionDays.ReceptionDayCode
				where der.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
				and ders.serviceCode = x_Dept_Employee_Service.serviceCode
			) Gdays        
			order by receptionDay
			for XML path ('DayInfo'),root('ReceptionHours') ,type 
		) ServiceReceptionHours  
		,VFastDeptServiceShift.shift as Serviceshift   
		,ISNULL(x_Dept_Employee_Service.CascadeUpdateEmployeeServicePhones, 1) as showPhonesFromDept		
		,(select receptiondayName Day, receptionDay DayCode,    
				(select OpeningHour 
						,ClosingHour
						,(select RemarkText         
							from DeptReceptionRemarks where DpRec.receptionID=DeptReceptionRemarks.ReceptionID   
							and  GETDATE() between ISNULL(DeptReceptionRemarks.validFrom,'1900-01-01') and ISNULL(deptreceptionremarks.validTo,'2079-01-01')  
							AND deptreceptionremarks.DisplayInInternet=CAST(1 AS BIT)
							for XML path ('Remark'),type)
					from DeptReception DpRec   
					left join DeptReceptionRemarks 
					on DpRec.ReceptionID = DeptReceptionRemarks.ReceptionID
					where DpRec.deptCode=Gdays.Deptcode and DpRec.receptionDay=Gdays.receptionDay  
					and DpRec.ReceptionHoursTypeID = 2 -- שעות משרד
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
					where dept.Deptcode = DeptReception.deptCode  
					and DeptReception.ReceptionHoursTypeID = 2 -- שעות משרד
					and GETDATE() between ISNULL(deptreception.validFrom,'1900-01-01') and ISNULL(deptreception.validTo,'2079-01-01')  
				) Gdays 
			order by receptionDay
			for XML path ('DayInfo'),root('ReceptionHours'),type        
		) ReceptionServiceHours
		,(SELECT DIC_QueueOrder.QueueOrder QueueOrderCode,DIC_QueueOrder.QueueOrderDescription QueueOrderDesc,
				(select DIC_QueueOrderMethod.QueueOrderMethod,DIC_QueueOrderMethod.QueueOrderMethodDescription,
						case when EmployeeServiceQueueOrderPhones.Preprefix = 2 then '*' 
							 else CONVERT(varchar(10), EmployeeServiceQueueOrderPhones.Preprefix) end as  PrePrefix,
						DIC_PhonePrefix.prefixValue Prefix,
						EmployeeServiceQueueOrderPhones.phone Phone,
						(select receptiondayName DAY        
						,(select DpRec.FromHour ,DpRec.ToHour
							from EmployeeServiceQueueOrderHours DpRec          
							where DpRec.EmployeeServiceQueueOrderMethodID=Gdays.EmployeeServiceQueueOrderMethodID 
							and DpRec.receptionDay=Gdays.receptionDay     
							for XML path('Reception'),type) 
						from (select distinct EmployeeServiceQueueOrderMethodID,receptiondayName,receptionDay 
								from dbo.EmployeeServiceQueueOrderHours        
								inner join  dbo.DIC_ReceptionDays        
								on DIC_ReceptionDays.receptiondayCode=dbo.EmployeeServiceQueueOrderHours.receptionDay         
								where EmployeeServiceQueueOrderHours.EmployeeServiceQueueOrderMethodID=dbo.EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
								) Gdays for XML path ('DayInfo'),root('ReceptionHours'),type  )
					FROM EmployeeServiceQueueOrderMethod 
					INNER JOIN dbo.DIC_QueueOrderMethod ON dbo.EmployeeServiceQueueOrderMethod.QueueOrderMethod = dbo.DIC_QueueOrderMethod.QueueOrderMethod
					LEFT JOIN dbo.EmployeeServiceQueueOrderPhones 
					ON EmployeeServiceQueueOrderPhones.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
					left JOIN dbo.DIC_PhonePrefix ON EmployeeServiceQueueOrderPhones.prefix = dbo.DIC_PhonePrefix.prefixCode
						and DIC_PhonePrefix.phoneType=EmployeeServiceQueueOrderPhones.phoneType 
					WHERE x_Dept_Employee_Service.x_Dept_Employee_ServiceID = EmployeeServiceQueueOrderMethod.x_dept_employee_serviceID
					AND DIC_QueueOrder.PermitOrderMethods=1
					FOR XML path ('QueueOrderMethod'),root('QueueOrderMethods'),type    )
			FROM dbo.DIC_QueueOrder
			WHERE x_Dept_Employee_Service.QueueOrder=DIC_QueueOrder.QueueOrder
			FOR XML path ('QueueOrder'),root('QueueOrders'),type    
		) ServiceQueueOrders
		,stuff((select ';' + serviceDescription
					from dbo.vDeptServices        
					where vDeptServices.DeptCode = Dept.deptCode
					and (vDeptServices.IsService = 1
						or 
						not exists (select * from x_Dept_Employee_Service xdes2
										join x_Dept_Employee xde2
										on xdes2.DeptEmployeeID = xde2.DeptEmployeeID
										and vDeptServices.DeptCode = xde2.deptCode
										and xde2.employeeID not in (select top 1 employeeID from Employee where IsMedicalTeam = 1)
										and xde2.active = 1
										where xdes2.serviceCode = vDeptServices.serviceCode))
				for xml path('')),1,1,''
		) ServiceList
		, case when (ROW_NUMBER() OVER(PARTITION BY Dept.deptCode order by Dept.deptCode) = 1)
				then isnull(stuff((select distinct ';'+ s.ServiceDescription
						from x_Dept_Employee_Service xdes
						join x_Dept_Employee xde
						on xdes.DeptEmployeeID = xde.DeptEmployeeID
						and xde.active = 1
						join Services s
						on xdes.serviceCode = s.ServiceCode
						and s.IsProfession = 1
						join Employee e
						on xde.employeeID = e.employeeID
						where xde.deptCode = Dept.deptCode
						and xdes.Status = 1
						and e.IsMedicalTeam = 0 and e.IsVirtualDoctor = 0
						for xml path('')),1,1,''
				), '')
				else '' end as ProfessionList 
		, case when (ROW_NUMBER() OVER(PARTITION BY Dept.deptCode order by Dept.deptCode) = 1)
				then 1
				else 0 end as DeptDistinct 
		, case when (ROW_NUMBER() OVER(PARTITION BY Dept.deptCode order by Dept.deptCode) = 1)
				then (select 
						CONVERT(CHAR(32), HASHBYTES('MD5', CAST(e.employeeID AS VARCHAR(MAX))), 2) AS EmployeeID
						,case when DIC_EmployeeDegree.DegreeName is null 
							then e.firstName + ' ' + e.lastName
							else DIC_EmployeeDegree.DegreeName + ' ' + e.firstName + ' ' + e.lastName
							end as EmployeeName
						,s.ServiceDescription as 'ServiceName'
						,xdes.serviceCode as 'ServiceID'
						from x_Dept_Employee_Service xdes
						join x_Dept_Employee xde
						on xdes.DeptEmployeeID = xde.DeptEmployeeID
						join Services s
						on xdes.serviceCode = s.ServiceCode
						join Employee e
						on xde.employeeID = e.employeeID
						and e.EmployeeSectorCode in (2, 7)
						join DIC_EmployeeDegree 
						on e.degreeCode = DIC_EmployeeDegree.DegreeCode
						where xde.deptCode = Dept.deptCode
						and xde.active = 1
						and xdes.Status = 1
						and e.IsMedicalTeam = 0
						and e.IsVirtualDoctor = 0
						order by e.lastName, e.firstName
						for xml path('Employee'), root('EmployeeListDept'), type)
		else NULL end as EmployeeListDept  
		, case when (ROW_NUMBER() OVER(PARTITION BY Dept.deptCode order by Dept.deptCode) = 1)
				then (select deptCode as 'DeptCode', dsub.deptName as 'DeptName', 
						dsub.typeUnitCode as 'UnitTypeCode',
						ut.UnitTypeName as 'UnitTypeName'
						from Dept dsub
						join UnitType ut
						on dsub.typeUnitCode = ut.UnitTypeCode
						where dsub.subAdministrationCode = Dept.deptCode
						and dsub.status = 1
						order by dsub.deptName
						for xml path('Unit'), root('UnitListDept'), type)
		else NULL end as UnitListDept,
		dxy.xcoord as XCoord,
		dxy.ycoord as YCoord
	from dbo.Dept         
	inner join  dbo.cities        
		on cities.cityCode=dept.cityCode        
	inner join dbo.UnitType        
		on dept.typeUnitCode =UnitType.UnitTypeCode        
	left join x_Dept_Employee
		on x_Dept_Employee.deptCode = Dept.deptCode     
		and x_Dept_Employee.active = 1   
		and exists (select employeeID from dbo.Employee 
					where employeeID = x_Dept_Employee.employeeID
					and IsMedicalTeam = 1)
	left join Employee
		on x_Dept_Employee.employeeID = Employee.employeeID
		and Employee.IsMedicalTeam = 1
	left join x_Dept_Employee_Service
		on x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID
		and (exists (select serviceCode from dbo.Services 
					where serviceCode = x_Dept_Employee_Service.serviceCode 
					and Services.IsService = 1)
			or
			(		exists (select serviceCode from dbo.Services 
							where serviceCode = x_Dept_Employee_Service.serviceCode 
							and Services.IsService = 0)
					and not exists (select * from x_Dept_Employee_Service xdes2
												join x_Dept_Employee xde2
												on xdes2.DeptEmployeeID = xde2.DeptEmployeeID
												and x_Dept_Employee.DeptCode = xde2.deptCode
												and xde2.employeeID not in (select top 1 employeeID from Employee where IsMedicalTeam = 1)
												and xde2.active = 1
												where xdes2.serviceCode = x_Dept_Employee_Service.serviceCode)
			)
		)
	left join dbo.Services        
		on x_Dept_Employee_Service.serviceCode=Services.serviceCode 
	left join dbo.VFastDeptShift       
		on dept.deptCode=VFastDeptShift.deptCode      
	left join VFastDeptServiceShift      
		on x_Dept_Employee.deptCode=VFastDeptServiceShift.deptCode      
		and x_Dept_Employee_Service.serviceCode=VFastDeptServiceShift.servicecode      
	LEFT JOIN  dbo.DIC_deptLevel
		ON dept.deptLevel=DIC_deptLevel.deptLevelCode
	LEFT JOIN DIC_SubUnitTypes
		ON dept.SubUnitTypeCode=DIC_SubUnitTypes.SubUnitTypeCode
	LEFT JOIN DIC_ParkingInClinic
		ON dept.parking=DIC_ParkingInClinic.parkingInClinicCode
	left join x_dept_xy dxy on Dept.deptCode = dxy.deptCode
	WHERE  dept.showUnitInInternet=1  
	and dept.status=1 
	and UnitType.ShowInInternet=1
	and (Dept.IsCommunity = 1 or Dept.IsMushlam = 1)
	--and dept.deptCode in (21100, 122381)
   )  
a

GO


GRANT SELECT ON [dbo].[VFastDeptEnqripted] TO [public] AS [dbo]
GO

