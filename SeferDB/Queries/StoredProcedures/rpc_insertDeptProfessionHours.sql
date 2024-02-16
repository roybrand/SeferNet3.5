IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptProfessionHours')
	BEGIN
		DROP  Procedure  rpc_insertDeptProfessionHours
	END

GO

CREATE Procedure rpc_insertDeptProfessionHours

	(
		@deptCode int,
		@professionCode int,
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

INSERT INTO DeptProfessionReception
(
	deptCode,
	professionCode,
	receptionDay,
	openingHour,
	closingHour,
	receptionTypeCode,
	validFrom,
	validTo,
	updateUserName
)
VALUES
(
	@deptCode,
	@professionCode,
	@receptionDay,
	@openingHour,
	@closingHour,
	@receptionTypeCode,
	@validFrom,
	@validTo,
	@updateUserName
)

GO


GRANT EXEC ON rpc_insertDeptProfessionHours TO PUBLIC

GO


