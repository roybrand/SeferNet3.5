IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getServiceForPopUp_ViaEmployee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getServiceForPopUp_ViaEmployee]
GO

CREATE Procedure [dbo].[rpc_getServiceForPopUp_ViaEmployee]
(
	@DeptCode int,
	@EmployeeID int,
	@AgreementType int,
	@ServiceCode int,
	@ExpirationDate datetime,
	@RemarkCategoriesForAbsence varchar(50),
	@RemarkCategoriesForClinicActivity varchar(50)
)

AS

DECLARE @deptEmployeeID INT
SET @deptEmployeeID = ( SELECT DeptEmployeeID
						FROM x_Dept_Employee xd
						WHERE deptCode = @DeptCode
						AND employeeID = @EmployeeID
						AND AgreementType = @AgreementType)

IF (@ExpirationDate is null OR @ExpirationDate <= cast('1/1/1900 12:00:00 AM' as datetime))
	BEGIN
		SET  @ExpirationDate = getdate()
	END	

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForAbsence
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForAbsence)

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForClinicActivity
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForClinicActivity)

----- clinic -----------
SELECT
Dept.deptName,
'address' = dbo.GetAddress(Dept.deptCode),
cityName

FROM Dept
INNER JOIN Cities ON Dept.cityCode = Cities.cityCode
WHERE dept.deptCode = @DeptCode

---- service -----------
--SELECT serviceDescription FROM [Services] WHERE ServiceCode = @ServiceCode
  select [Services].ServiceDescription,
  CASE WHEN DIC_QO_S.QueueOrderDescription is null 
	   THEN 
			CASE WHEN DIC_QO_E.QueueOrderDescription is null THEN '' ELSE DIC_QO_E.QueueOrderDescription END
	   ELSE DIC_QO_S.QueueOrderDescription END
	   as QueueOrderDescription,
  CASE WHEN DIC_QO_S.PermitOrderMethods is null 
		THEN 	   
			CASE WHEN DIC_QO_E.PermitOrderMethods is null THEN -1 ELSE DIC_QO_E.PermitOrderMethods END
		ELSE DIC_QO_S.PermitOrderMethods END
		as PermitOrderMethods,
	dbo.fun_GetEmployeeServiceQueueOrderPhones(x_DES.DeptEmployeeID, x_DES.serviceCode)
	as ServiceQueueOrderPhones
			
  FROM x_Dept_Employee x_DE
  JOIN Employee ON x_DE.employeeID = Employee.employeeID
  LEFT JOIN x_Dept_Employee_Service x_DES ON x_DE.DeptEmployeeID = x_DES.DeptEmployeeID
  LEFT JOIN [Services] ON x_DES.serviceCode = [Services].serviceCode
  LEFT JOIN DIC_QueueOrder DIC_QO_E ON x_DE.QueueOrder = DIC_QO_E.QueueOrder
  LEFT JOIN DIC_QueueOrder DIC_QO_S ON x_DES.QueueOrder = DIC_QO_S.QueueOrder  
  where deptCode = @DeptCode 
  and x_DE.employeeID = @EmployeeID
  and x_DES.serviceCode = @ServiceCode  

------- deptPhones ----------------
SELECT
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptPhones
WHERE deptCode = @DeptCode
AND phoneType <> 2 -- not fax

----DoctorReceptions------------------------
SELECT
dER.receptionID,
xd.EmployeeID,
xd.deptCode,
IsNull(ders.serviceCode, 0) as professionOrServiceCode,
IsNull(serviceDescription, 'NoData') as professionOrServiceDescription,
dER.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
DER.validFrom,
'expirationDate' = DER.validTo,
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		ELSE openingHour END,
'closingHour' =
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END,

'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID),
'serviceCodes' = dbo.fun_GetServiceCodesForEmployeeReception(dER.receptionID),
CASE WHEN (dERS.serviceCode = 2 OR dERS.serviceCode = 40) 
	 THEN der.ReceiveGuests
	 ELSE 0
	 END AS ReceiveGuests
FROM deptEmployeeReception as der
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
LEFT JOIN deptEmployeeReceptionServices as ders ON der.receptionID = ders.receptionID
LEFT JOIN [Services] ON ders.serviceCode = [Services].serviceCode
INNER JOIN DIC_ReceptionDays on dER.receptionDay = DIC_ReceptionDays.ReceptionDayCode
WHERE xd.deptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID
AND dERS.serviceCode = @ServiceCode
AND (
	(validFrom is null OR @ExpirationDate >= validFrom )
	and 
	(validTo is null OR validTo >= @ExpirationDate) 
	)

ORDER BY EmployeeID, receptionDay, openingHour


-- closest reception add date within 14 days
SELECT MIN(ValidFrom)
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
WHERE der.DeptEmployeeID = @deptEmployeeID 
AND ders.serviceCode = @ServiceCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14


-- remarks
SELECT  
deptCode,
employeeID,
serviceCode,
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as Remark,
DisplayInInternet
,GenRem.RemarkCategoryID

FROM DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks GenRem ON desr.RemarkID = GenRem.remarkID
INNER JOIN  x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE deptCode = @DeptCode 
AND employeeID = @EmployeeID
AND ServiceCode = @serviceCode
AND	(GETDATE() between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))

UNION

SELECT distinct
v_DE_ER.DeptCode,
v_DE_ER.EmployeeID,
0 as serviceCode,
dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark,
v_DE_ER.displayInInternet
,GenRem.RemarkCategoryID
from View_DeptEmployee_EmployeeRemarks as v_DE_ER
JOIN DIC_GeneralRemarks GenRem ON v_DE_ER.DicRemarkID = GenRem.remarkID
where v_DE_ER.employeeID = @EmployeeID
AND v_DE_ER.DeptCode = @DeptCode
AND	(GETDATE() between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))	


-- Dept faxes --------------------------
SELECT
phoneOrder,
'fax' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptPhones
WHERE deptCode = @DeptCode
AND phoneType = 2 -- fax

-- Queue order for methods, phones and hours
select * from dbo.fun_GetQueueOrderMethods(@DeptCode,@EmployeeID,@ServiceCode)
select * from dbo.fun_GetQueueOrderPhones(@DeptCode,@EmployeeID,@ServiceCode)
select * from dbo.fun_GetQueueOrderHours(@DeptCode,@EmployeeID,@ServiceCode)


-- Service phones and faxes -----------------------------
select * from [fun_GetServicePhoneAndFaxes](@DeptCode,@EmployeeID,@ServiceCode)

-- Employee name and degree
select firstName + ' ' + lastName as employeeName,DegreeName from Employee
join DIC_EmployeeDegree on Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
and Employee.employeeID = @EmployeeID

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
JOIN #RemarkCategoriesForClinicActivity REMACT ON GenRem.RemarkCategoryID = REMACT.RemarkCategoryID
WHERE deptCode = @deptCode
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY REMACT.RemarkCategoryID DESC, IsSharedRemark DESC, validFrom, View_DeptRemarks.updateDate

GO

GRANT EXEC ON rpc_getServiceForPopUp_ViaEmployee TO [clalit\webuser]
GO

GRANT EXEC ON rpc_getServiceForPopUp_ViaEmployee TO [clalit\IntranetDev]
GO