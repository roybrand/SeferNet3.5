IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_mytestproc')
	BEGIN
		PRINT 'Dropping Procedure rpc_mytestproc'
		DROP  Procedure  [rpc_mytestproc]
	END
GO

PRINT 'Creating Procedure [rpc_mytestproc]'
GO

CREATE Procedure dbo.[rpc_mytestproc]
AS


GO


GRANT EXEC ON [rpc_mytestproc] TO PUBLIC
GO

