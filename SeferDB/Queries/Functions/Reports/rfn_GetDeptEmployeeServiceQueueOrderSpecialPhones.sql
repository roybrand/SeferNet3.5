IF EXISTS (SELECT * FROM sysobjects WHERE type= 'FN'  and name = 'rfn_GetDeptEmployeeServiceQueueOrderSpecialPhones')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeServiceQueueOrderSpecialPhones
	END

GO

create function dbo.rfn_GetDeptEmployeeServiceQueueOrderSpecialPhones
(
	@QueueOrderMethodID int
)
RETURNS varchar(500)
WITH EXECUTE AS CALLER

as
begin

declare @specPhones varchar(200)
set @specPhones = ''

	SELECT 
	@specPhones = @specPhones  +
	dbo.fun_ParsePhoneNumberWithExtension(phones.preprefix, phones.prefix, phones.phone, phones.extension)+';' 
	FROM EmployeeServiceQueueOrderPhones phones where phones.EmployeeServiceQueueOrderMethodID = @QueueOrderMethodID
	IF len(@specPhones) > 1
	-- remove last separator
	BEGIN
		SET @specPhones = SUBSTRING(@specPhones, 0, len(@specPhones))
	END

return (@specPhones)
end

GO