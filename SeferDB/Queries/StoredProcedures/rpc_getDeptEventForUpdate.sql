IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptEventForUpdate
	END

GO

CREATE Procedure dbo.rpc_getDeptEventForUpdate
	(
		@DeptEventID int
	)

AS


SELECT
DeptEventID, DeptCode, DeptEvent.EventCode, EventName, EventDescription, MeetingsNumber,
'RepeatingEvent' = CAST(RepeatingEvent as bit), FromDate, ToDate, 
RegistrationStatus, PayOrder, CommonPrice, MemberPrice, FullMemberPrice,
TargetPopulation, Remark, 
'displayInInternet' = CAST(displayInInternet as bit),
CascadeUpdatePhonesFromClinic as 'ShowPhonesFromDept'
FROM DeptEvent
INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
WHERE DeptEventID = @DeptEventID


SELECT DeptEventParticularsID, OrderNumber, ReceptionDayName as 'Day', Date, OpeningHour, ClosingHour, Duration
FROM DeptEventParticulars
LEFT JOIN DIC_ReceptionDays ON DeptEventParticulars.Day = DIC_ReceptionDays.ReceptionDayCode
WHERE DeptEventID = @DeptEventID
ORDER BY Date


SELECT 
DeptEventPhones.phoneType, phoneOrder, prePrefix, prefixCode, prefixValue as PrefixText, phone, extension
FROM DeptEventPhones
INNER JOIN DIC_PhonePrefix dic ON DeptEventPhones.prefix = dic.prefixCode
WHERE DeptEventID = @DeptEventID


exec rpc_GetDeptEventFiles @deptEventID

GO

GRANT EXEC ON rpc_getDeptEventForUpdate TO PUBLIC

GO

