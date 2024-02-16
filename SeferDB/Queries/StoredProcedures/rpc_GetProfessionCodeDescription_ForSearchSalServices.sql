IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetProfessionCodeDescription_ForSearchSalServices')
	BEGIN
		DROP  Procedure  rpc_GetProfessionCodeDescription_ForSearchSalServices
	END
GO

Create Proc [dbo].rpc_GetProfessionCodeDescription_ForSearchSalServices
@Code Int
As

Select * 
From MF_Professions
Where Code = @Code and LogicalDelete = 0

Go

GRANT EXEC ON rpc_GetProfessionCodeDescription_ForSearchSalServices TO PUBLIC
GO

