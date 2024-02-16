IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventForPopUp')
	BEGIN
		DROP  Procedure  rpc_getDeptEventForPopUp
	END

GO

PRINT 'Creating rpc_getDeptEventForPopUp '
GO

CREATE Procedure dbo.rpc_getDeptEventForPopUp
	(
		@DeptEventID int
	)

AS
----- deptEvent -----------
SELECT
DeptEventID,
DIC_Events.EventName,
EventDescription,
MeetingsNumber,
'RepeatingEvent' = CAST(RepeatingEvent as bit),
'RegistrationStatus' = 
	CASE CAST(isNull(RegistrationStatus,-1) as varchar(2)) WHEN '-1' THEN 'לא מוגדר' WHEN '0' THEN 'בעיצומה' WHEN '1' THEN 'נסגרה' END,
DIC_DeptEventPayOrder.PayOrderDescription,
DIC_DeptEventPayOrder.Free,
CommonPrice,
MemberPrice,
FullMemberPrice,
TargetPopulation,
Remark,
Dept.deptName,
'address' = dbo.GetAddress(Dept.deptCode),
CascadeUpdatePhonesFromClinic as 'ShowPhonesFromDept'

FROM DeptEvent
INNER JOIN Dept ON DeptEvent.deptCode = Dept.deptCode
INNER JOIN DIC_DeptEventPayOrder ON DeptEvent.PayOrder = DIC_DeptEventPayOrder.PayOrder
INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode

WHERE DeptEventID = @DeptEventID
AND IsActive = 1

------- deptEventMeetings --------------
SELECT 
DeptEventParticularsID,
DeptEventID,
'OrderNumber' = ROW_NUMBER() over(ORDER BY Date),
'Day'= DIC_ReceptionDays.ReceptionDayName,
Date,
OpeningHour,
ClosingHour,
'Duration' = CASE IsNull(ClosingHour, '') WHEN '' THEN '&nbsp;' ELSE
	LEFT(CAST( 
		CAST(LEFT(ClosingHour,2) as float) - CAST(LEFT(OpeningHour,2) as float)
		+ (CAST(RIGHT(ClosingHour,2) as float) - CAST(RIGHT(OpeningHour,2) as float))/60
	as varchar(30)), 3) + ' ש`' END
FROM DeptEventParticulars
LEFT JOIN DIC_ReceptionDays ON DeptEventParticulars.Day = DIC_ReceptionDays.ReceptionDayCode
WHERE DeptEventID = @DeptEventID 

------- deptEventPhones ----------------
SELECT
DeptEventID,
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptEventPhones
WHERE DeptEventID = @DeptEventID
AND phoneType <> 2 -- not fax

------- deptPhones ----------------
SELECT
DeptEventID,
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptPhones
INNER JOIN DeptEvent ON DeptPhones.deptCode = DeptEvent.deptCode
WHERE DeptEventID = @DeptEventID
AND phoneType <> 2 -- not fax
	
------ DeptEventHandicappedFacilities ----------------
SELECT
DeptEventHandicappedFacilitiesID,
DeptEventID,
FacilityDescription
FROM DeptEventHandicappedFacilities
INNER JOIN DIC_HandicappedFacilities 
	ON DeptEventHandicappedFacilities.FacilityCode = DIC_HandicappedFacilities.FacilityCode
WHERE DeptEventID = @DeptEventID


SELECT FileName, FileDescription
FROM DeptEventfiles 
WHERE DeptEventID = @DeptEventID

UNION

SELECT FileName, FileDescription
FROM DeptEvent de 
INNER JOIN EventFiles ef ON de.EventCode = ef.EventCode
WHERE DeptEventID = @DeptEventID

GO

GRANT EXEC ON rpc_getDeptEventForPopUp TO PUBLIC

GO

