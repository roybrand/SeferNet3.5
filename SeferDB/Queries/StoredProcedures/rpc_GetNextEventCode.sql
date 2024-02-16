IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetNextEventCode')
	BEGIN
		DROP  Procedure  rpc_GetNextEventCode
	END

GO

CREATE Procedure dbo.rpc_GetNextEventCode
(
	@eventCode INT OUTPUT
)

AS



SELECT TOP(1) @eventCode = EventCode 
FROM DIC_Events
WHERE DIC_Events.IsActive = 1
ORDER BY EventCode DESC
				  

SET @eventCode = @eventCode + 1			  





GO


GRANT EXEC ON rpc_GetNextEventCode TO PUBLIC

GO
