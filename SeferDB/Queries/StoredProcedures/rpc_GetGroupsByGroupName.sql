IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetGroupsByGroupName')
	BEGIN
		DROP Procedure rpc_GetGroupsByGroupName
	END

GO

CREATE Procedure dbo.rpc_GetGroupsByGroupName
@SearchString varchar(50) 
As

Select	tg.* 
From MF_TariffGroups212 tg
Where tg.IsCanceled = 0 And tg.GroupSubCode = 0 And tg.GroupDesc Like '%'+ @SearchString +'%'
Order By GroupDesc 

GO

GRANT EXEC ON rpc_GetGroupsByGroupName TO PUBLIC

GO