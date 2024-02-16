IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptReceptionRemarkForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptReceptionRemarkForUpdate
	END

GO

CREATE Procedure rpc_getDeptReceptionRemarkForUpdate
	(
		@DeptReceptionRemarkID int
	)

AS

SELECT
DeptReceptionRemarkID,
ReceptionID,
RemarkText,
ValidFrom,
ValidTo,
'DisplayInInternet' = CAST(DisplayInInternet as bit)

FROM DeptReceptionRemarks
WHERE DeptReceptionRemarkID = @DeptReceptionRemarkID


GO

GRANT EXEC ON rpc_getDeptReceptionRemarkForUpdate TO PUBLIC

GO

