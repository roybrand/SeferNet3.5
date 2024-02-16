 
IF EXISTS (SELECT * FROM sysobjects WHERE type= 'FN'  and name = 'rfn_GetDeptQueueOrderSpecialPhones')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptQueueOrderSpecialPhones
	END

GO

create function dbo.rfn_GetDeptQueueOrderSpecialPhones
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
	from DeptQueueOrderPhones phones where phones.QueueOrderMethodID = @QueueOrderMethodID

return (@specPhones)
end

