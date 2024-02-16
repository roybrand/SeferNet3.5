IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetOmriReturnCodeDescription_ForSearchSalServices')
	BEGIN
		DROP  Procedure  rpc_GetOmriReturnCodeDescription_ForSearchSalServices
	END
GO

Create Proc [dbo].[rpc_GetOmriReturnCodeDescription_ForSearchSalServices]
@ReturnCode Int
As

Select * 
From MF_OmriReturns536
Where	ReturnCode = @ReturnCode And 
		DelFlg = 0 And 
		(AscriptionToCodeTariff > 0 And AscriptionToCodeTariff Is Not Null)

GO

GRANT EXEC ON rpc_GetOmriReturnCodeDescription_ForSearchSalServices TO PUBLIC
GO
