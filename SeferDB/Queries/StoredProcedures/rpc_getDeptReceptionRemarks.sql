IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptReceptionRemarks')
	BEGIN
		DROP  Procedure  rpc_getDeptReceptionRemarks
	END

GO

CREATE Procedure rpc_getDeptReceptionRemarks
	(
		@ReceptionID int
	)

AS

SELECT
DeptReceptionRemarkID,
ReceptionID,
RemarkText,
ValidFrom,
'ValidTo' = CASE isNull(CAST( ValidTo as integer),0) WHEN 0 THEN 'ללא הגבלה' else CONVERT(varchar(20), ValidTo, 103) end,
'DisplayInInternet'= CAST(DisplayInInternet as bit)

FROM DeptReceptionRemarks
WHERE ReceptionID = @ReceptionID

GO

GRANT EXEC ON rpc_getDeptReceptionRemarks TO PUBLIC

GO

