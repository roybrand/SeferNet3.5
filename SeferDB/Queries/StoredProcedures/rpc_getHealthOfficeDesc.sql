IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHealthOfficeDesc')
	BEGIN
		DROP  Procedure  rpc_getHealthOfficeDesc
	END
GO

Create Procedure [dbo].[rpc_getHealthOfficeDesc]
(
	@SearchString varchar(50)
)

AS

Select Top 10 GoVCode +  + ';' + [Description] As Code , [Description]
From MF_HealthGov478
Where ([Description] Like '%'+ @SearchString +'%' Or Len(@SearchString)<=0 ) AND DELFL = 0

Go

GRANT EXEC ON rpc_getHealthOfficeDesc TO PUBLIC
GO
