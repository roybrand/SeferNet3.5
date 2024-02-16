IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetCurrentStatusForEmployee')
	BEGIN
		DROP  Procedure  rpc_GetCurrentStatusForEmployee
	END

GO

CREATE PROCEDURE dbo.rpc_GetCurrentStatusForEmployee
 	@employeeID BIGINT
AS
SELECT es.StatusID, StatusDescription, dic.[status]
FROM EmployeeStatus es
INNER JOIN DIC_ActivityStatus dic
ON es.status = dic.status
WHERE DATEDIFF(dd, GETDATE(), es.FromDate) <= 0 
AND (DATEDIFF(dd, GETDATE(), es.ToDate) >= 0  OR ToDate IS NULL)
AND EmployeeID = @employeeID


GRANT EXEC ON rpc_GetCurrentStatusForEmployee TO PUBLIC

GO


