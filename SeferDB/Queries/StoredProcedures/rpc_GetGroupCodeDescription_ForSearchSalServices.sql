IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetGroupCodeDescription_ForSearchSalServices')
	BEGIN
		DROP  Procedure  rpc_GetGroupCodeDescription_ForSearchSalServices
	END
GO

Create Proc dbo.rpc_GetGroupCodeDescription_ForSearchSalServices
@GroupCode Int
As

Select tg.*
From MF_TariffGroups212 tg
Where tg.GroupCode = @GroupCode And tg.IsCanceled = 0

Go

GRANT EXEC ON rpc_GetGroupCodeDescription_ForSearchSalServices TO PUBLIC
GO
