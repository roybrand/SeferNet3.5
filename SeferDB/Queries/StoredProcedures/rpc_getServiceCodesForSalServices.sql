IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceCodesForSalServices')
	BEGIN
		DROP  Procedure  rpc_getServiceCodesForSalServices
	END

GO

Create Proc [dbo].[rpc_getServiceCodesForSalServices] ( @SearchString VarChar(50) )
As

Select Top 10 ServiceCode , ServiceName 
From MF_SalServices386
Where ( ServiceName Like '%'+ @SearchString +'%' Or LEN(@SearchString)<=0 )

Go

GRANT EXEC ON rpc_getServiceCodesForSalServices TO PUBLIC

GO