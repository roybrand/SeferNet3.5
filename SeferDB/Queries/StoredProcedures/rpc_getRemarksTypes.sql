
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getRemarksTypes')
	BEGIN
		DROP  Procedure  rpc_getRemarksTypes
	END

GO

create Procedure [dbo].[rpc_getRemarksTypes]
as


SELECT ID , Remark
from RemarksTypes
order by ID
 
GO

GRANT EXEC ON rpc_getRemarksTypes TO PUBLIC

GO
