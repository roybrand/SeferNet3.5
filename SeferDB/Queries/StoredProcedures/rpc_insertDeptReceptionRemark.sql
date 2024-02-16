IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptReceptionRemark')
	BEGIN
		DROP  Procedure  rpc_insertDeptReceptionRemark
	END

GO

CREATE Procedure rpc_insertDeptReceptionRemark
	(
		@ReceptionID int,
		@RemarkText varchar(500),
		@ValidFrom datetime,
		@ValidTo datetime,
		@DisplayInInternet int,
		@UpdateUser varchar(50)
)

AS

IF @ValidFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @ValidFrom = null
	END	

IF @ValidTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @ValidTo = null
	END		

INSERT INTO DeptReceptionRemarks
(ReceptionID, RemarkText, ValidFrom, ValidTo, DisplayInInternet, UpdateUser)
VALUES
(@ReceptionID, @RemarkText, @ValidFrom, @ValidTo, @DisplayInInternet, @UpdateUser)


GO

GRANT EXEC ON rpc_insertDeptReceptionRemark TO PUBLIC

GO

