
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_UpdateProfessionForInternet')
BEGIN
	DROP  Procedure  rpc_UpdateProfessionForInternet
END

GO

CREATE Proc [dbo].[rpc_UpdateProfessionForInternet]
@ProfessionCode Int, 
@ProfessionDescriptionForInternet NVarChar(255),
@ProfessionExtraData varchar(max),
@ShowProfessionInInternet TinyInt

As

Update ProfessionDetailsForInternet 
Set ProfessionDescriptionForInternet = @ProfessionDescriptionForInternet, 
	ShowProfessionInInternet = @ShowProfessionInInternet,
	ProfessionExtraData	= @ProfessionExtraData
Where ProfessionCode = @ProfessionCode

GO


GRANT EXEC ON dbo.rpc_UpdateProfessionForInternet TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_UpdateProfessionForInternet TO [clalit\IntranetDev]
GO 
   