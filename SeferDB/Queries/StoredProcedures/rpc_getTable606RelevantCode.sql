IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getTable606RelevantCode')
	BEGIN
		DROP  Procedure  rpc_getTable606RelevantCode
	END

GO

Create Procedure [dbo].[rpc_getTable606RelevantCode]
	(		
		@ErrorStatus int output
	)
AS

	
select  TatHitmahutCode as 'Code' ,      
 TatHitmahutDesc as 'Name' ,      
 'Linked' = case      
 when (select count(serviceCode) from dbo.service where serviceCode = dbo.MF_TatHitmahutZimun606.TatHitmahutCode) > 0 then 1   
 when (select count(professions.professionCode) from dbo.professions 
 where  professions.professionCode = dbo.MF_TatHitmahutZimun606.TatHitmahutCode) > 0 then 1      
 else  0 end  , '606' as TableName ,
'Category' = case
			when (select count(serviceCode) from dbo.service 
					where serviceCode = MF_TatHitmahutZimun606.TatHitmahutCode) > 0 
			then 'שירות'
			when (select count(professions.professionCode) from dbo.professions 
					where  professions.professionCode = MF_TatHitmahutZimun606.TatHitmahutCode) > 0
			then 'מקצוע'
end ,
		'ParentCode' = case               
				when  (professionsParentChild.parentCode IS  NOT  NULL) then professionsParentChild.parentCode 
				when (serviceParentChild.parentCode IS  NOT  NULL) then serviceParentChild.parentCode     
		end ,    
       'ParentCodeName' = case     
				when  (professionsParentChild.parentCode IS  NOT  NULL)and (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode ) is not null then (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode )     
				when  (serviceParentChild.parentCode IS  NOT  NULL) and (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode) is not null then (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode)     
       end    
   
 from  dbo.MF_TatHitmahutZimun606  
LEFT OUTER JOIN professions ON MF_TatHitmahutZimun606.TatHitmahutCode = professions.professionCode     
LEFT OUTER JOIN service ON MF_TatHitmahutZimun606.TatHitmahutCode = service.serviceCode  
LEFT join serviceParentChild on MF_TatHitmahutZimun606.TatHitmahutCode = dbo.serviceParentChild.childCode      
LEFT join professionsParentChild on MF_TatHitmahutZimun606.TatHitmahutCode = dbo.professionsParentChild.childCode 
    
 where Delfl = 0 order by TatHitmahutDesc  

	

GO


GRANT EXEC ON rpc_getTable606RelevantCode TO PUBLIC

GO


