IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptEventFiles')
	BEGIN
		DROP  Procedure  rpc_GetDeptEventFiles
	END

GO

CREATE Procedure dbo.rpc_GetDeptEventFiles
(
	@deptEventID INT
)

AS

SELECT *
FROM DeptEventFiles
WHERE DeptEventID = @deptEventID


GO


GRANT EXEC ON rpc_GetDeptEventFiles TO PUBLIC

GO


