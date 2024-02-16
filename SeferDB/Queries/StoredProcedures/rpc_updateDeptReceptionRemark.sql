IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptReceptionRemark')
	BEGIN
		DROP  Procedure  rpc_updateDeptReceptionRemark
	END

GO

CREATE Procedure rpc_updateDeptReceptionRemark
	(
		@DeptReceptionRemarkID int,
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

UPDATE DeptReceptionRemarks
SET 
RemarkText = @RemarkText,
ValidFrom = @ValidFrom,
ValidTo = @ValidTo,
DisplayInInternet = @DisplayInInternet,
UpdateUser = @UpdateUser
WHERE 
DeptReceptionRemarkID = @DeptReceptionRemarkID
GO

GRANT EXEC ON rpc_updateDeptReceptionRemark TO PUBLIC

GO

