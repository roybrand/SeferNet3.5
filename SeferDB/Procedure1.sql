IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Procedure1')
	BEGIN
		PRINT 'Dropping Procedure Procedure1'
		DROP  Procedure  [Procedure1]
	END
GO

PRINT 'Creating Procedure [Procedure1]'
GO

CREATE Procedure dbo.[Procedure1]
AS


GO


GRANT EXEC ON [Procedure1] TO PUBLIC
GO

