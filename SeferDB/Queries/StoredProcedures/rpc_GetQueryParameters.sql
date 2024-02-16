IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetQueryParameters')
	BEGIN
		DROP  Procedure  rpc_GetQueryParameters
	END

GO

CREATE Procedure dbo.rpc_GetQueryParameters(@QueryNumber int)
AS

	SELECT 
	QueryNumber, ParameterID, ParameterName, ParameterType, LookupTable, LookupValueField,
	LookupDescriptionField, AppControlName, AppControlType, AppDefaultItemDescription,
	AppControlEnabled, DependsOnParam, ID, AppDefaultSelectedCodes, AppDefaultSelectedNames

	FROM ADM_QueriesParameters 
	Where QueryNumber = @QueryNumber
	and AppControlEnabled > 0

GO


GRANT EXEC ON [dbo].rpc_GetQueryParameters TO [clalit\webuser]
GO

GRANT EXEC ON [dbo].rpc_GetQueryParameters TO [clalit\IntranetDev]
GO

