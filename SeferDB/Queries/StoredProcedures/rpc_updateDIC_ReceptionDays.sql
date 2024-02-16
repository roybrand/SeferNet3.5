IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDIC_ReceptionDays')
	BEGIN
		DROP  Procedure  rpc_updateDIC_ReceptionDays
	END

GO

CREATE Procedure [dbo].[rpc_updateDIC_ReceptionDays]
	(
		@receptionDayCode int,
		@byDisplay tinyint,
		@UseInSearch tinyint
	)

AS

	update DIC_ReceptionDays 
	set Display = @byDisplay,
	UseInSearch = @UseInSearch
	where ReceptionDayCode = @receptionDayCode
GO

GRANT EXEC ON rpc_updateDIC_ReceptionDays TO PUBLIC
GO