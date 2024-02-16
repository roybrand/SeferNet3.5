
/****** Object:  View [dbo].[VFastEmployee]    Script Date: 12/15/2011 08:33:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VFastEmployee]'))
DROP VIEW [dbo].[VFastEmployee]
GO

/****** Object:  View [dbo].[VFastEmployee]    Script Date: 12/15/2011 08:33:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VFastEmployee]  
AS  

SELECT 	RIGHT('0000000000' + cast(employee.employeeID AS varchar(20)), 10) 
			+ RIGHT('0000000' + ISNULL(cast(x_Dept_Employee.deptCode AS varchar(10)), ''), 7)   
			+ RIGHT('0000' + cast(ISNULL(services.serviceCode, 0) AS varchar(10)), 4) DoctoRKey
		,employee.employeeID
		,DIC_EmployeeDegree.DegreeName
		,employee.firstName
		,employee.lastName
		,DIC_Gender.sexDescription
		,STUFF ((SELECT ';' + languages.languageDescription  
					FROM dbo.EmployeeLanguages 
					JOIN dbo.languages 
					ON EmployeeLanguages.languagecode = languages.languagecode
					WHERE     employee.employeeID = EmployeeLanguages.EmployeeID FOR XML path('')), 1, 1, ''
		) AS Languages
		,cast(employee.IsInCommunity AS char(1)) as empIsInCommunity
        ,cast(employee.IsInMushlam AS char(1)) as empIsInMushlam
		,employee.IsInHospitals as empIsInHospitals
		,employee.IsSurgeon as empIsSurgeon
		,case when (x_Dept_Employee.AgreementType in (1,2) and employee.IsInCommunity = 1) then 'community'
				when (x_Dept_Employee.AgreementType in (3,4) and employee.IsInMushlam = 1) then 'mushlam'
				else 'community' end as empAgreement
		,case when (x_Dept_Employee.AgreementType in (1,2) and employee.IsInCommunity = 1) then 'קהילה'
				when (x_Dept_Employee.AgreementType in (3,4) and employee.IsInMushlam = 1) then 'מושלם'
				else 'מרפאות חוץ בתי חולים' end as empAgreementHeb
		,employee.IsVirtualDoctor
		,employee.IsMedicalTeam
		,employee.PrivateHospitalPosition as empPrivateHospitalPosition
		,employee.PrivateHospital as empPrivateHospital
		,dept.deptCode
		,services.serviceCode
		,dept.deptName
		,dept.administrationCode as AdministrationCode
		,(SELECT	dbo.rfn_GetFotmatedRemark(x_Employee_EmployeeRemarks.RemarkText) [Text]
					,x_Employee_EmployeeRemarks.ValidFrom
					,x_Employee_EmployeeRemarks.ValidTo  
			FROM (SELECT EmployeeRemarks.EmployeeID,
						x_Dept_Employee_EmployeeRemarks.DeptEmployeeID,
						 EmployeeRemarks.RemarkText
						,EmployeeRemarks.validFrom
						,EmployeeRemarks.ValidTo
						,AttributedToAllClinicsInCommunity
						,AttributedToAllClinicsInMushlam
						,AttributedToAllClinicsInHospitals
					FROM x_Dept_Employee_EmployeeRemarks 
					JOIN EmployeeRemarks ON x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
					WHERE GETDATE() BETWEEN ISNULL(EmployeeRemarks.validFrom, '1900-01-01') AND ISNULL(EmployeeRemarks.validTo, '2079-01-01') 
					AND   EmployeeRemarks.displayInInternet = 1
			) x_Employee_EmployeeRemarks
			WHERE      x_Employee_EmployeeRemarks.EmployeeID = Employee.employeeID 
			AND ((x_Employee_EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 and x_Dept_Employee.AgreementType in (1, 2))
					OR (x_Employee_EmployeeRemarks.AttributedToAllClinicsInMushlam = 1 and x_Dept_Employee.AgreementType in (3, 4))
					OR (x_Employee_EmployeeRemarks.AttributedToAllClinicsInHospitals = 1 and x_Dept_Employee.AgreementType > 4)
					OR (x_Employee_EmployeeRemarks.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID)
				) FOR XML path('Remark'), root('Remarks'), type
		) Remarks
		,stuff ((SELECT ',' + position.positionDescription  
					FROM x_Dept_Employee_Position 
					INNER JOIN position 
					ON position.positionCode = x_Dept_Employee_Position.positionCode
					WHERE     x_Dept_Employee_Position.DeptEmployeeID = x_dept_employee.DeptEmployeeID
					AND position.gender = Employee.sex 
					--AND x_Dept_Employee_Position.deptCode = dept.deptCode 
					FOR XML path('')), 1, 1, ''
		) Position
		,(SELECT	DIC_PhoneTypes.PhoneTypeName Type
					,case when DeptEmployeePhones.Preprefix = 2 
							then '*' else CONVERT(varchar(10), DeptEmployeePhones.Preprefix) end as  Preprefix
					,DIC_PhonePrefix.prefixValue as [Prefix]
					,DeptEmployeePhones.Phone Number
					,DeptEmployeePhones.PhoneOrder[Order]
					,DeptEmployeePhones.UpdateDate
			FROM dbo.DeptEmployeePhones 
			INNER JOIN dbo.DIC_PhoneTypes 
			ON DIC_PhoneTypes.phoneTypeCode = DeptEmployeePhones.phoneType
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=DeptEmployeePhones.prefix 
			WHERE DeptEmployeePhones.DeptEmployeeID = x_dept_employee.DeptEmployeeID			
			FOR xml path('Phone'), root('Phones'), type
		) Phones
		,services.serviceDescription
		,services.isInCommunity
		,services.isInMushlam
		,EmployeeServices.expProfession
		,case when EmployeeServices.expProfession = 1 
				then 'מומחה' else 'לא מומחה' end as ExpProfessionDesc
		,(SELECT	DIC_ReceptionDays.ReceptionDayName[Day]
					,DIC_ReceptionDays.ReceptionDayCode[DayCode]
					,(SELECT	DeptEmployeeReception.openingHour[OpeningHour] 
								,DeptEmployeeReception.closingHour[ClosingHour]
								,DeptEmployeeReception.ValidFrom
								,DeptEmployeeReception.ValidTo
								,(SELECT	DeptEmployeeReceptionRemarks.RemarkText [Text]
											,DeptEmployeeReceptionRemarks.ValidFrom
											,DeptEmployeeReceptionRemarks.ValidTo  
									FROM DeptEmployeeReceptionRemarks  
									WHERE DeptEmployeeReceptionremarks.EmployeeReceptionID = DeptEmployeeReception.receptionID 
									AND GETDATE() BETWEEN ISNULL(DeptEmployeeReceptionremarks.validFrom, '1900-01-01') AND ISNULL(DeptEmployeeReceptionremarks.validTo, '2079-01-01') 
									FOR XML path('Remark'), type
								)
						FROM deptEmployeeReception
						WHERE deptEmployeeReception.receptionID = receptionDay.receptionID 
						AND deptEmployeeReception.receptionDay = receptionDay.receptionDay 
						AND GETDATE() BETWEEN ISNULL(deptEmployeeReception.validFrom,'1900-01-01') AND ISNULL(deptEmployeeReception.validTo, '2079-01-01') 
						order by DeptEmployeeReception.openingHour
						FOR XML PATH('Reception'), type
					)  
			FROM (SELECT DISTINCT receptionDay
								, receptionID  
					FROM deptEmployeeReception
					WHERE deptEmployeeReception.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 					
					AND GETDATE() BETWEEN ISNULL(deptEmployeeReception.validFrom,'1900-01-01') AND ISNULL(deptEmployeeReception.validTo, '2079-01-01') 
			) receptionDay 
			JOIN DIC_ReceptionDays 
			ON DIC_ReceptionDays.receptiondayCode = receptionDay.ReceptionDay
			JOIN deptEmployeeReceptionServices ders
			on receptionDay.receptionID = ders.receptionID
			and ders.serviceCode = emp_Service.serviceCode
			--WHERE EXISTS (SELECT 1 FROM x_Dept_Employee_Service  
			--				WHERE x_Dept_Employee_Service.DeptEmployeeID = dbo.x_Dept_Employee.DeptEmployeeID							
			--				AND x_Dept_Employee_Service.serviceCode = emp_Service.serviceCode
			--			)  
			order by receptionDay.receptionDay
			FOR XML PATH('DayInfo'), ROOT('ReceptionHours'), TYPE
		) ReceptionHours
		,(SELECT	DIC_QueueOrder.QueueOrder QueueOrderCode
					,DIC_QueueOrder.QueueOrderDescription QueueOrderDesc
					,(select DIC_QueueOrderMethod.QueueOrderMethod
							,DIC_QueueOrderMethod.QueueOrderMethodDescription
							,case when DeptEmployeeQueueOrderPhones.Preprefix = 2 
									then '*' else CONVERT(varchar(10), DeptEmployeeQueueOrderPhones.Preprefix) end as  Preprefix
							,DIC_PhonePrefix.prefixValue as [Prefix]
							,DeptEmployeeQueueOrderPhones.phone Phone
							,(select receptiondayName DAY        
									,(select EmpRec.FromHour ,EmpRec.ToHour
										from EmployeeQueueOrderHours EmpRec          
										where EmpRec.QueueOrderMethodID=Gdays.QueueOrderMethodID 
										and EmpRec.receptionDay=Gdays.receptionDay
										for XML path('Reception'),type
									) 
								from (select distinct QueueOrderMethodID
													,ReceptiondayName
													,ReceptionDay 
										from dbo.EmployeeQueueOrderHours        
										inner join  dbo.DIC_ReceptionDays        
										on DIC_ReceptionDays.receptiondayCode=dbo.EmployeeQueueOrderHours.receptionDay         
										where EmployeeQueueOrderHours.QueueOrderMethodID=dbo.EmployeeQueueOrderMethod.QueueOrderMethodID
								) Gdays for XML path ('DayInfo'),root('ReceptionHours'),type  
							)
						FROM EmployeeQueueOrderMethod 
						INNER JOIN dbo.DIC_QueueOrderMethod 
						ON dbo.EmployeeQueueOrderMethod.QueueOrderMethod = dbo.DIC_QueueOrderMethod.QueueOrderMethod
						LEFT JOIN dbo.DeptEmployeeQueueOrderPhones 
						ON DeptEmployeeQueueOrderPhones.QueueOrderMethodID=EmployeeQueueOrderMethod.QueueOrderMethodID
						left join dbo.DIC_PhonePrefix   
						on DIC_PhonePrefix.prefixCode=DeptEmployeeQueueOrderPhones.prefix 
						WHERE EmployeeQueueOrderMethod.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						AND DIC_QueueOrder.PermitOrderMethods=1
						FOR XML path ('QueueOrderMethod'),root('QueueOrderMethods'),type    
					)
			FROM dbo.DIC_QueueOrder
			WHERE x_Dept_Employee.QueueOrder=DIC_QueueOrder.QueueOrder
			FOR XML path ('QueueOrder'),root('QueueOrders'),type    
		) QueueOrderMethodHours
		,VFastDeptEmployeeProfessionShift.shift
		,cities.cityName
		,cities.cityCode 
		,dept.StreetName
		,dept.house
		,dept.flat
		,dept.entrance
		,dept.FLOOR
		,dept.addresscomment
		, dept.transportation
		,stuff((select ';'+DIC_HandicappedFacilities.FacilityDescription
					from dbo.DeptHandicappedFacilities
					inner join dbo.DIC_HandicappedFacilities
					on DIC_HandicappedFacilities.FacilityCode=DeptHandicappedFacilities.FacilityCode
					where DeptHandicappedFacilities.DeptCode=dept.deptCode
					for xml path('')),1,1,''
		) FacilityDescription
		,(select DIC_PhoneTypes.PhoneTypeName [Type]
				,case when DeptPhones.Preprefix = 2 
					   then '*' else CONVERT(varchar(10), DeptPhones.Preprefix) end as  Preprefix
				,DIC_PhonePrefix.prefixValue [Prefix]
				,DeptPhones.Phone Number    
				,DeptPhones.PhoneOrder [Order]       
				,DeptPhones.UpdateDate UpdateDate
			from dbo.deptPhones
			inner join dbo.DIC_PhoneTypes
			on DIC_PhoneTypes.phoneTypeCode=deptPhones.phoneType
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=deptPhones.prefix 
			where dept.deptCode=deptPhones.DeptCode for xml path('Phone'),root('Phones'),type
	) Deptphones
	,UnitType.UnitTypeName
	,UnitType.UnitTypeCode
	,DIC_AgreementTypes.AgreementTypeID as AgreementType
	,DIC_AgreementTypes.AgreementTypeDescription
	,EmployeeSector.EmployeeSectorCode
	,EmployeeSector.EmployeeSectorDescriptionForCaption as  EmployeeSectorDescription
	,x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic as CascadePhonesFromDept
	,(select xde2.deptCode as DeptCode
			, d2.deptName as DeptName
			, xdes2.serviceCode as ServiceID
			, s2.ServiceDescription
			from dbo.x_Dept_Employee xde2
			inner join dbo.Dept d2
			on xde2.deptCode = d2.deptCode
			and d2.status = 1 and d2.showUnitInInternet = 1
			join x_Dept_Employee_Service xdes2
			on xde2.DeptEmployeeID = xdes2.DeptEmployeeID
			and xde2.active = 1
			join Services s2
			on xdes2.serviceCode = s2.ServiceCode
			where xde2.deptCode <> x_Dept_Employee.deptCode 
			and xde2.employeeID = x_Dept_Employee.employeeID
			and xde2.active = 1
			order by d2.deptName, s2.ServiceDescription
			for xml path('Dept'),root('DeptList'),type
	) DeptListForEmployee
FROM dbo.employee 
INNER JOIN dbo.DIC_EmployeeDegree ON DIC_EmployeeDegree.DegreeCode = employee.DegreeCode 
LEFT JOIN DIC_Gender ON employee.sex = DIC_Gender.sex 
LEFT JOIN dbo.x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID and x_dept_employee.active=1 
LEFT JOIN dbo.DIC_AgreementTypes on x_Dept_Employee.AgreementType=DIC_AgreementTypes.AgreementTypeID 
LEFT JOIN dbo.dept ON x_Dept_Employee.deptCode = dept.deptCode 
LEFT JOIN x_Dept_Employee_Service as emp_Service ON x_Dept_Employee.DeptEmployeeID = emp_Service.DeptEmployeeID
LEFT JOIN services ON emp_Service.serviceCode = services.serviceCode 
LEFT JOIN EmployeeServices 
	ON emp_Service.serviceCode = EmployeeServices.serviceCode
	AND employee.employeeID = EmployeeServices.EmployeeID 
LEFT JOIN dbo.VFastDeptEmployeeProfessionShift 
	ON emp_Service.DeptEmployeeID = VFastDeptEmployeeProfessionShift.DeptEmployeeID 
	AND emp_Service.serviceCode = VFastDeptEmployeeProfessionShift.ServiceCode
LEFT JOIN dbo.cities ON cities.cityCode=dept.cityCode 
LEFT JOIN dbo.UnitType on dept.typeUnitCode =UnitType.UnitTypeCode  
LEFT JOIN dbo.EmployeeSector on Employee.EmployeeSectorCode =EmployeeSector.EmployeeSectorCode
LEFT JOIN dbo.x_Services_EmployeeSector ON  EmployeeSector.EmployeeSectorCode=x_Services_EmployeeSector.EmployeeSectorCode and x_Services_EmployeeSector.ServiceCode=Services.serviceCode 
LEFT JOIN dbo.VFastDept ON VFastDept.deptCode = dept.deptCode AND VFastDept.serviceCode = ISNULL(emp_Service.serviceCode, 0)    
WHERE	Employee.EmployeeSectorCode IN (2, 7)  and Employee.active = 1
		and dept.showUnitInInternet = 1  and dept.status = 1
		and UnitType.ShowInInternet = 1 and UnitType.IsActive = 1
		and IsVirtualDoctor <> 1 and IsMedicalTeam <> 1
		and x_Dept_Employee.AgreementType <> 4
		and (Dept.IsCommunity = 1 or Dept.IsMushlam = 1)

GO


GRANT SELECT ON [dbo].[VFastEmployee] TO [public] AS [dbo]
GO
