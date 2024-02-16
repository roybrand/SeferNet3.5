IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeStatus')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeStatus
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeStatus
(
	@employeeID BIGINT
)

AS

SELECT es.Status,DIC_ActivityStatus.StatusDescription, FromDate,ToDate
FROM EmployeeStatus es
INNER JOIN DIC_ActivityStatus ON es.Status = DIC_ActivityStatus.status
WHERE EmployeeID = @employeeID
ORDER BY fromDate


GO


GRANT EXEC ON rpc_GetEmployeeStatus TO PUBLIC

GO

