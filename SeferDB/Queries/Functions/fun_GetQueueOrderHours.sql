IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetQueueOrderHours]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetQueueOrderHours]
GO

CREATE FUNCTION [dbo].[fun_GetQueueOrderHours] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	--deptCode int,
	--serviceCode int,
	--employeeID bigint,
	--QueueOrderMethodID int,		
	receptionDay int,
	ReceptionDayName varchar(50),
	FromHour varchar(5),
	toHour varchar(5)
	
)
as
begin
/* 
   The first select is from the service hours,
   if it's empty the next select is from the employee hours.
   
*/



insert into @ResultTable
SELECT
--xDE.deptCode,
--xDES.serviceCode,
--xDE.employeeID,
--ESQOH.EmployeeServiceQueueOrderMethodID,
ESQOH.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
ESQOH.FromHour,
ESQOH.ToHour

FROM
EmployeeServiceQueueOrderHours ESQOH
JOIN vReceptionDaysForDisplay
	ON ESQOH.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
JOIN EmployeeServiceQueueOrderMethod SQOM ON ESQOH.EmployeeServiceQueueOrderMethodID = SQOM.EmployeeServiceQueueOrderMethodID
JOIN x_Dept_Employee_Service xDES ON SQOM.x_Dept_Employee_ServiceID = xDES.x_Dept_Employee_ServiceID
JOIN x_Dept_Employee xDE ON xDES.DeptEmployeeID = xDE.DeptEmployeeID

WHERE xDES.serviceCode = @serviceCode
and xDE.deptCode = @deptCode
and xDE.EmployeeID = @employeeID

insert into @ResultTable
SELECT 
--xDE.deptCode,
--'serviceCode' = @serviceCode,
--xDE.employeeID,
--EQOH.EmployeeQueueOrderMethodID,
EQOH.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
EQOH.FromHour,
EQOH.ToHour

FROM 
EmployeeQueueOrderHours EQOH
JOIN vReceptionDaysForDisplay
	ON EQOH.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode 
JOIN EmployeeQueueOrderMethod EQOM ON EQOM.queueOrderMethodID = EQOH.queueOrderMethodID	
JOIN x_Dept_Employee xDE ON EQOM.DeptEmployeeID = xDE.DeptEmployeeID
WHERE xDE.EmployeeID = @EmployeeID
AND xDE.DeptCode = @DeptCode
AND NOT EXISTS
(
	SELECT * FROM @ResultTable
)
return
end

GO


