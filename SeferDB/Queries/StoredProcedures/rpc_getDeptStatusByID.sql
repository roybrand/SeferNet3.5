IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptStatusByID')
	BEGIN
		DROP  Procedure  rpc_getDeptStatusByID
	END

GO

CREATE Procedure dbo.rpc_getDeptStatusByID
	(
		@StatusID int
	)

AS

DECLARE @deptCode int
SET @deptCode = (SELECT deptCode FROM DeptStatus WHERE StatusID = @StatusID)

SELECT
StatusID,
DeptCode,
DeptStatus.Status,
statusDescription,
FromDate,
ToDate,
'hasActiveSubClinics' = 
	(SELECT COUNT(*) FROM dept WHERE subAdministrationCode = DeptCode AND status = 1),
	
'FromDateMin' = IsNull((SELECT TOP 1 DATEADD(d, 1, FromDate) 
						FROM DeptStatus 
						WHERE deptCode = @deptCode 
						AND StatusID < @StatusID
						ORDER BY StatusID DESC ), '01/01/1900'),
						
'ToDateMax' = IsNull((SELECT TOP 1 DATEADD(d, -1, ToDate)
				FROM DeptStatus
				WHERE deptCode = @deptCode 
				AND StatusID > @StatusID), '01/01/2050')
	
FROM DeptStatus
INNER JOIN DIC_ActivityStatus ON DeptStatus.Status = DIC_ActivityStatus.status
WHERE StatusID = @StatusID


GO

GRANT EXEC ON rpc_getDeptStatusByID TO PUBLIC

GO

