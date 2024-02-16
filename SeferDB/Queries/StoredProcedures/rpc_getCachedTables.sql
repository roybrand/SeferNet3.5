IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getCachedTables')
	BEGIN
		DROP  Procedure  rpc_getCachedTables
	END

GO

create procedure [dbo].[rpc_getCachedTables] 
as
select TableCode,TableName from CachedTables

GO


GRANT EXEC ON rpc_getCachedTables TO PUBLIC

GO


