IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetQueryFields')
	BEGIN
		DROP  Procedure  dbo.rpc_GetQueryFields
	END

GO

CREATE Procedure dbo.rpc_GetQueryFields(@QueryNumber int)
AS

	Select FieldName, FieldTitle, Mandatory, FieldOrder 
	from ADM_QueriesFields
	Where QueryNumber = @QueryNumber and Visible = 1
	Order By FieldOrder, Mandatory desc 

GO

GRANT EXEC ON dbo.rpc_GetQueryFields TO PUBLIC

GO



