IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptRemark')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptRemark
	END

GO

CREATE PROCEDURE [dbo].[rpc_UpdateDeptRemark]
(
	@remarkID int,
	@remarkText varchar(500),
	@validFrom datetime,
	@validTo datetime,
	@ActiveFrom datetime,
	@displayInInternet int,
	@showOrder INT,
	@updateUser varchar(50),
	@ErrCode int OUTPUT
)


AS
	
	UPDATE DeptRemarks
	SET RemarkText = @remarkText,
	validFrom = @validFrom,
	validTo = @validTo,
	displayInInternet = @displayInInternet,
	showOrder = @showOrder,
	ActiveFrom = @ActiveFrom,
	updateUser = @updateUser,
	updateDate = getdate()
	FROM DeptRemarks
	WHERE DeptRemarkID = @remarkID
	
	SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_UpdateDeptRemark TO PUBLIC

GO