IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetOmriReturnsByName')
	BEGIN
		DROP Procedure rpc_GetOmriReturnsByName
	END

GO

CREATE Procedure dbo.rpc_GetOmriReturnsByName
@SearchString varchar(50) 
As

SELECT ReturnCode , ReturnDescription
FROM [dbo].MF_OmriReturns536 p
Where	DelFlg = 0 And (AscriptionToCodeTariff > 0 And AscriptionToCodeTariff Is Not Null)
		And ReturnDescription Like '%'+ @SearchString +'%'

GO

GRANT EXEC ON rpc_GetOmriReturnsByName TO PUBLIC

GO