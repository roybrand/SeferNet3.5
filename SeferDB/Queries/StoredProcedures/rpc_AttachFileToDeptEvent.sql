IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_AttachFileToDeptEvent')
	BEGIN
		DROP  Procedure  rpc_AttachFileToDeptEvent
	END

GO

PRINT 'Creating rpc_AttachFileToDeptEvent '
GO 

CREATE Procedure dbo.rpc_AttachFileToDeptEvent
(
	@deptEventID INT,
	@fileDisplayName VARCHAR(100),
	@fileName VARCHAR(250)
)

AS


IF NOT EXISTS
(
SELECT * 
FROM DeptEventFiles
WHERE DeptEventID = @deptEventID
AND [FileName] = @fileName
)

INSERT INTO DeptEventFiles (DeptEventID, [FileName], FileDescription)
VALUES (@deptEventID, @fileName, @fileDisplayName)



GO


GRANT EXEC ON rpc_AttachFileToDeptEvent TO PUBLIC

GO


