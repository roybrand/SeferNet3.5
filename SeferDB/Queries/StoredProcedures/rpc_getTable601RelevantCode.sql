IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getTable601RelevantCode')
	BEGIN
		DROP  Procedure  rpc_getTable601RelevantCode
	END

GO


/****** Object:  StoredProcedure [dbo].[rpc_getTable601RelevantCode]    Script Date: 11/08/2009 16:37:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create Procedure [dbo].[rpc_getTable601RelevantCode]
	(		
		@ErrorStatus int output
	)
AS

		
select	MF_Zimun601.ProfessionCode as 'Code' , 
		MF_Zimun601.ProfessionDesc as 'Name' ,      
		'Linked' = case      
			when (select count(serviceCode) from dbo.service 
						where serviceCode = MF_Zimun601.ProfessionCode) > 0 
					then 1 
			when (select count(professions.professionCode) from dbo.professions 
						where  professions.professionCode = MF_Zimun601.ProfessionCode) > 0 
					then 1      
					else  0 
		end , 
		'601' as TableName 	,
		'Category' = case
			when (select count(serviceCode) from dbo.service 
						where serviceCode = MF_Zimun601.ProfessionCode) > 0 
					then 'שירות'
			when (select count(professions.professionCode) from dbo.professions 
				where  professions.professionCode = dbo.MF_Zimun601.ProfessionCode) > 0
					then 'מקצוע'
		end,
		'ParentCode' = case               
				when  (professionsParentChild.parentCode IS  NOT  NULL) then professionsParentChild.parentCode 
				when (serviceParentChild.parentCode IS  NOT  NULL) then serviceParentChild.parentCode     
		end ,    
       'ParentCodeName' = case     
				when  (professionsParentChild.parentCode IS  NOT  NULL)and (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode ) is not null then (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode )     
				when  (serviceParentChild.parentCode IS  NOT  NULL) and (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode) is not null then (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode)     
       end    
from  dbo.MF_Zimun601 
LEFT OUTER JOIN professions ON MF_Zimun601.ProfessionCode = professions.professionCode     
LEFT OUTER JOIN service ON MF_Zimun601.ProfessionCode = service.serviceCode  
LEFT join serviceParentChild on MF_Zimun601.ProfessionCode = dbo.serviceParentChild.childCode      
LEFT join professionsParentChild on MF_Zimun601.ProfessionCode = dbo.professionsParentChild.childCode 
where Delfl = 0 
order by ProfessionDesc



GO


GRANT EXEC ON rpc_getTable601RelevantCode TO PUBLIC

GO


