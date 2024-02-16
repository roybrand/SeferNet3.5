IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CheckIfDeptHasFutureNotActiveStatus')
	BEGIN
		DROP  Procedure  rpc_CheckIfDeptHasFutureNotActiveStatus
	END

GO

CREATE Procedure dbo.rpc_CheckIfDeptHasFutureNotActiveStatus
(
	@deptCode INT,
	@startDate DATETIME
)

AS


SELECT TOP 1 FromDate
FROM DeptStatus ds
INNER JOIN DIC_ActivityStatus st 
ON ds.status = st.status
WHERE StatusDescription = 'לא פעיל'
AND DATEDIFF(dd, ds.FromDate, @startDate) <= 0 
AND DeptCode = @deptCode
ORDER BY FromDate



GO


GRANT EXEC ON rpc_CheckIfDeptHasFutureNotActiveStatus TO PUBLIC

GO

