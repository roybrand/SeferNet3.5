IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptProfessionHours')
	BEGIN
		DROP  Procedure  rpc_updateDeptProfessionHours
	END

GO

CREATE Procedure rpc_updateDeptProfessionHours

	(
		@receptionID int,
		@receptionTypeCode int,
		@receptionDay int,
		@openingHour varchar(5),
		@closingHour varchar(5),
		@validFrom smalldatetime = null,
		@validTo smalldatetime = null,
		@updateUserName varchar(50)
	)

AS

IF @validFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @validFrom=null
	END	

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo=null
	END		

UPDATE DeptProfessionReception
SET 
receptionDay = @receptionDay,
openingHour = @openingHour,
closingHour = @closingHour,
receptionTypeCode = @receptionTypeCode,
validFrom = @validFrom,
validTo = @validTo,
updateDate = getDate(),
updateUserName = @updateUserName

WHERE receptionID = @receptionID


GO


GRANT EXEC ON rpc_updateDeptProfessionHours TO PUBLIC

GO

