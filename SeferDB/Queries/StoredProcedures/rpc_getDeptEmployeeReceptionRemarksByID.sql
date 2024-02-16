IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeReceptionRemarksByID')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeReceptionRemarksByID
	END

GO

CREATE Procedure rpc_getDeptEmployeeReceptionRemarksByID
	(
		@DeptEmployeeReceptionRemarkID int	
	)

AS

SELECT 
DeptEmployeeReceptionRemarkID,
EmployeeReceptionID,
RemarkText,
'EnableOverlappingHours' = CAST(EnableOverlappingHours as bit),
'displayInInternet' = CAST(displayInInternet as bit)

FROM DeptEmployeeReceptionRemarks
WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID


GO

GRANT EXEC ON rpc_getDeptEmployeeReceptionRemarksByID TO PUBLIC

GO

