IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetTreeViewEvents')
	BEGIN
		DROP  Procedure  rpc_GetTreeViewEvents
	END

GO

PRINT 'Creating rpc_GetTreeViewEvents'
GO

CREATE Procedure dbo.rpc_GetTreeViewEvents

AS

SELECT EventCode, 
EventName , 
IsActive 
FROM dbo.DIC_Events


SELECT EventCode, EventFileID, FileName, FileDescription
FROM EventFiles
ORDER BY EventCode





GO

GRANT EXEC ON rpc_GetTreeViewEvents TO PUBLIC

GO


