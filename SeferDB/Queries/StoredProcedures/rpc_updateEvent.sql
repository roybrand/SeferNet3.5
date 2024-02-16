IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEvent')
	BEGIN
		DROP  Procedure  rpc_updateEvent
	END

GO

CREATE Procedure dbo.rpc_updateEvent
(
	@eventCode INT, 
	@eventDescription VARCHAR(500),
	@isActive BIT,
	@updateUser VARCHAR(50)
)

AS


UPDATE DIC_Events
SET EventName = @eventDescription, 
	IsActive = @isActive,
	UpdateUser = @updateUser,
	UpdateDate = GETDATE()
WHERE EventCode = @eventCode


GO


GRANT EXEC ON rpc_updateEvent TO PUBLIC

GO


