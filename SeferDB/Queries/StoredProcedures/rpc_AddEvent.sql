IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_AddEvent')
	BEGIN
		DROP  Procedure  rpc_AddEvent
	END

GO

CREATE Procedure dbo.rpc_AddEvent
(
		@eventCode INT,
		@desc VARCHAR(500),
		@isActive BIT,
		@updateUser VARCHAR(30)
)

AS

INSERT INTO DIC_Events(EventCode, EventName, IsActive, UpdateUser, UpdateDate)
VALUES (@eventCode, @desc, @isActive, @updateUser, GETDATE())


GO


GRANT EXEC ON rpc_AddEvent TO PUBLIC

GO

