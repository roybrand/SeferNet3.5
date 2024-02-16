IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsNames')
	BEGIN
		DROP  Procedure  rpc_GetDeptsNames
	END

GO

CREATE Procedure dbo.rpc_GetDeptsNames
(
	@deptName VARCHAR(30),
	@searchExtended BIT
)

AS


SELECT DeptCode, DeptName
FROM Dept
WHERE (DeptName LIKE @deptName + '%') OR (DeptName LIKE '%' + @deptName + '%' AND @searchExtended = 1)
ORDER BY DeptName





GO


GRANT EXEC ON rpc_GetDeptsNames TO PUBLIC

GO


