IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionOldCodeData')
	BEGIN
		DROP  Procedure  rpc_getProfessionOldCodeData
	END

GO

/****** Object:  StoredProcedure [dbo].[rpc_getProfessionOldCodeData]    Script Date: 11/08/2009 16:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create Procedure [dbo].[rpc_getProfessionOldCodeData]
(		
	@ErrorStatus int output
)
AS

	
select professions.professionCode as 'Code', 
dbo.professions.professionDescription as 'Name',      
'Linked' = case      
when ( select count(OldCode) 
from  dbo.X_Professions_OldCodes
where professions.professionCode = X_Professions_OldCodes.OldCode and OldTable = 'profession') > 0 
or 
(
(select count(OldCode) 
from dbo.X_Services_OldCodes
where professions.professionCode = X_Services_OldCodes.OldCode and OldTable = 'profession') > 0

)
then 1  
else 0      
end , '' as TableName     
from dbo.professions      
order by dbo.professions.professionDescription   



GO


GRANT EXEC ON rpc_getProfessionOldCodeData TO PUBLIC

GO


