/*
דוח שעות קבלה של נותני שירות ביחידות עבור חברת ברלה
הדוח יכלול רק יחידות פעילות + נותני שירות פעילים, בכל המחוזות, סקטור רפואה + פארא רפואה, רק קהילה
השדות:
מחוז, 	קוד מחוז, מינהלת, קוד מינהלת, סוג יחידה, קוד סוג יחידה, 
שיוך, קוד שיוך, שם יחידה, קוד סימול, ישוב , קוד ישוב, כתובת, 
שם פרטי נותן שירות, שם משפחה נותן שירות, סקטור נותן שירות, קוד סקטור נותן שירות, 
מקצוע נותן שירות, קוד מקצוע נותן שירות, מקצוע מומחיות נותן שירות, 
שירותים נותן שירות, קוד שירותים נותן שירות, יום, משעה, עד שעה , סך שעות  

קובץ שנוצר הוא : EmployeeServicesReceptionForBerale.xls 
*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VBeraleDeptEmployeeServiceReceptions]'))
	DROP VIEW [dbo].VBeraleDeptEmployeeServiceReceptions
GO


CREATE VIEW [dbo].VBeraleDeptEmployeeServiceReceptions  
AS  
SELECT distinct
 isNull(dDistrict.deptCode , -1) as DeptCode  , dDistrict.DeptName as DistrictName
, isNull(dAdmin.DeptCode , -1) as AdminClinicCode , dAdmin.DeptName as AdminClinicName
, UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName 
, subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName 
, d.deptCode as ClinicCode ,d.DeptName as ClinicName 
--,deptSimul.Simul228 as Code228 
--,dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName 
, Cities.CityCode as CityCode, Cities.CityName as CityName
, dbo.GetAddress(d.deptCode) as ClinicAddress 
--, dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 
--, dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 
--, dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax 
--, d.Email as Email 
--, dbo.fun_getManagerName(d.deptCode) as MangerName 
--, dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName 
--, ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName
, Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName
--, Employee.EmployeeID as EmployeeID 
--, Employee.licenseNumber as EmployeeLicenseNumber 
--, Employee.email as EmployeeEmail
, Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription
--, DEPositions.PositionDescriptions as PositionDescription
--			 ,DEPositions.PositionCodes as PositionCode
--, DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
--			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode
--, DERemarks.RemarkDescriptions as EmployeeRemarkDescription
--			,DERemarks.RemarkCodes as EmployeeRemarkID
--,case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
--		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
--		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 
--,case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
--		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
--		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 
--,case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
--		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
--		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax 
--,DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
--		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription 
,[DeptReception].serviceDescription  as serviceDescription,
	 [DeptReception].serviceCode  as serviceCode  
,[DeptReception].ProfessionDescription  as ProfessionDescription,
	 [DeptReception].ProfessionCode  as ProfessionCode  
, [DeptReception].ReceptionDayName  as ReceptionDayName 
, [DeptReception].openingHour  as openingHour 
, [DeptReception].closingHour  as closingHour 
, [DeptReception].totalHours  as totalHours 
--, CONVERT(varchar(10), [DeptReception].validFrom, 103)  as  validFrom  
--, CONVERT(varchar(10), [DeptReception].validTo, 103) as  validTo 
--, [DeptReception].remarkText  as RecepRemark 
FROM Dept as d    
JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode 
 --JOIN DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID 
LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode 
LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode 
LEFT JOIN View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode	
LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode	 
		AND d.typeUnitCode = SubUnitType.UnitTypeCode 
LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode 
LEFT JOIN Cities on d.CityCode =  Cities.CityCode 
--LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
--cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails 
--LEFT JOIN DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
--		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
--	LEFT JOIN DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
--		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
--LEFT JOIN DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
--		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
-- LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 
-- LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
-- LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
-- LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 
-- LEFT JOIN [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
--		on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
--		and Employee.employeeID = DEExpProfessions.employeeID 
-- LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
--		on x_Dept_Employee.deptCode = DEPositions.deptCode
--		and Employee.employeeID = DEPositions.employeeID 
-- LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
--		on x_Dept_Employee.deptCode = DERemarks.deptCode
--		and Employee.employeeID = DERemarks.employeeID 
------------ Dept and services Reception --------------
LEFT JOIN dbo.View_DeptEmployeeReceptions AS DeptReception 
	on x_Dept_Employee.deptCode = DeptReception.deptCode
	and x_Dept_Employee.employeeID = DeptReception.employeeID 
	and x_Dept_Employee.AgreementType = DeptReception.AgreementType
 WHERE x_Dept_Employee.active = 1 
 AND d.status = 1
 and Employee.active = 1
 AND (x_Dept_Employee.AgreementType IN (1, 2)) 
 AND (Employee.EmployeeSectorCode IN (2, 5, 7))
 AND d.showUnitInInternet = 1

GO

GRANT SELECT ON [dbo].VBeraleDeptEmployeeServiceReceptions TO [public] AS [dbo]
GO
