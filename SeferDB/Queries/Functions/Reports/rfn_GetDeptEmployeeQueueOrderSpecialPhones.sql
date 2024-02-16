 
IF EXISTS (SELECT * FROM sysobjects WHERE type= 'FN'  and name = 'rfn_GetDeptEmployeeQueueOrderSpecialPhones')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderSpecialPhones
	END

GO

create function dbo.rfn_GetDeptEmployeeQueueOrderSpecialPhones
(
	@QueueOrderMethodID int
)
RETURNS varchar(500)
WITH EXECUTE AS CALLER

as
begin

declare @specPhones varchar(200)
set @specPhones = ''

	select 
	@specPhones = @specPhones  +
	dbo.fun_ParsePhoneNumberWithExtension(phones.preprefix, phones.prefix, phones.phone, phones.extension)+';  ' 
	from DeptEmployeeQueueOrderPhones phones where phones.QueueOrderMethodID = @QueueOrderMethodID

return (@specPhones)
end

