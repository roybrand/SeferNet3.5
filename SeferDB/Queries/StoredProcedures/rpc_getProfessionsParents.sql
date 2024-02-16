IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsParents')
	BEGIN
		DROP  Procedure  rpc_getProfessionsParents
	END

GO


/****** Object:  StoredProcedure [dbo].[rpc_getProfessionsParents]    Script Date: 11/08/2009 16:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create Procedure [dbo].[rpc_getProfessionsParents]
	(
		@childServiceID    int, 			
		@oldCode   int,		
		@ErrorStatus int output
	)

AS
DECLARE @Err int, @Count int
SET @Err = 0
SET @Count = 0
SET @ErrorStatus = 0

IF @oldCode = -1
	BEGIN
		SET @oldCode = null
	END

   
  select  professions.professionCode as 'Code',      
                       professionDescription as 'Name',       
                       'Linked' = case      
                       when (       
                       select count(professionsParentChild.parentCode) from dbo.professionsParentChild       
                       where childCode= professions.professionCode) > 0 then 1      
                       else 0      
                       end , '' as TableName     
                       from professions        
                       where professionCode <>  @childServiceID   
                       and  professionCode not in (select distinct childCode from professionsParentChild) 
               
                   and ((@oldCode is null) or (professionCode <>@oldCode))
                  order by professionDescription  


GRANT EXEC ON rpc_getProfessionsParents TO PUBLIC

GO


