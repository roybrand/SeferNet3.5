IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetFileNameByDeptEventFileID')
	BEGIN
		DROP  Procedure  rpc_GetFileNameByDeptEventFileID
	END

GO

CREATE Procedure dbo.rpc_GetFileNameByDeptEventFileID
(
	@deptEventFileID INT
)

AS


SELECT FileName
FROM deptEventFiles
WHERE DeptEventFileID = @deptEventFileID


GO

GRANT EXEC ON rpc_GetFileNameByDeptEventFileID TO PUBLIC

GO


