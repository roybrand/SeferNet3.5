IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteServiceSynonym')
    BEGIN
	    DROP  Procedure  rpc_DeleteServiceSynonym
    END

GO

CREATE Procedure dbo.rpc_DeleteServiceSynonym
(
	@synoymID INT
)

AS


DELETE ServiceSynonym
WHERE SynonymID = @synoymID

                
GO


GRANT EXEC ON rpc_DeleteServiceSynonym TO PUBLIC

GO            
