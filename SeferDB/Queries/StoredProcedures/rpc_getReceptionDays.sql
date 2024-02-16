IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getReceptionDays')
	BEGIN
		DROP  Procedure  rpc_getReceptionDays
	END

GO

CREATE Procedure [dbo].[rpc_getReceptionDays]
	(
		-- If byDisplay = false it will return all days
		@byDisplay tinyint
	)

AS

IF @byDisplay = 0
	select * from DIC_ReceptionDays
ELSE
	select * from DIC_ReceptionDays where Display=1
GO

GRANT EXEC ON rpc_getReceptionDays TO PUBLIC
GO