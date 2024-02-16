IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeReceptionRemarks')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeReceptionRemarks
	END

GO

CREATE Procedure rpc_getDeptEmployeeReceptionRemarks
	(
		@EmployeeReceptionID int
	)

AS

SELECT 
DeptEmployeeReceptionRemarkID,
EmployeeReceptionID,
RemarkText,
'EnableOverlappingHours' = CAST(EnableOverlappingHours as bit),
'displayInInternet' = CAST(displayInInternet as bit)

FROM DeptEmployeeReceptionRemarks
WHERE EmployeeReceptionID = @EmployeeReceptionID

GO

GRANT EXEC ON rpc_getDeptEmployeeReceptionRemarks TO PUBLIC

GO

