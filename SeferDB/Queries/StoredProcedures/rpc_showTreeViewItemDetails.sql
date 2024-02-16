IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showTreeViewItemDetails')
	BEGIN
		DROP  Procedure  rpc_showTreeViewItemDetails
	END

GO

CREATE  PROCEDURE [dbo].[rpc_showTreeViewItemDetails]
(
		@treeViewItem int ,
		@category varchar(50)
	)
AS

SELECT  'MF_Zimun601' as tableName , 
       MF_Zimun601.ProfessionCode as Code ,     	
      MF_Zimun601.ProfessionDesc as Name,     
          'NameR' = Case     
           when professions.professionCode IS  NOT  NULL then  professions.professionDescription     
        when  dbo.service.serviceCode IS  NOT  NULL  then dbo.service.serviceDescription     
       end ,    
         MF_Zimun601.ProfessionDesc as TableDescription ,     
       professions.professionCode,dbo.service.serviceCode,     
       'Category' = Case     
       when professions.professionCode IS  NOT  NULL and  @category = 'מקצוע'  then 'מקצוע' 
       when dbo.service.serviceCode IS  NOT  NULL and  @category = 'שירות' then 'שירות'     
       end ,
        'ParentCode' = case               
        when  (professionsParentChild.parentCode IS  NOT  NULL) then professionsParentChild.parentCode 
		 when (serviceParentChild.parentCode IS  NOT  NULL) then serviceParentChild.parentCode     
        end ,    
       'ParentCodeName' = case     
         when  (professionsParentChild.parentCode IS  NOT  NULL)and (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode ) is not null then (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode )     
		 when  (serviceParentChild.parentCode IS  NOT  NULL) and (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode) is not null then (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode)     
        end ,               
        'Sector' = dbo.fun_GetSectorsCodesForProfession(professions.ProfessionCode),
        'SectorDescription' =  dbo.fun_GetSectorsForProfession(professions.ProfessionCode),
        professions.ShowExpert,
		'Relation' = case
		when @category = 'מקצוע' and (select count (parentCode) from dbo.professionsParentChild where parentCode = MF_Zimun601.ProfessionCode) > 0 then 'parent'
		when @category = 'מקצוע' and (select count (childCode) from dbo.professionsParentChild where  childCode= MF_Zimun601.ProfessionCode) > 0 then 'child'

		when @category = 'שירות' and (select count (parentCode) from dbo.serviceParentChild where parentCode = MF_Zimun601.ProfessionCode) > 0 then 'parent'
		when @category = 'שירות' and (select count (childCode) from dbo.serviceParentChild where childCode = MF_Zimun601.ProfessionCode) > 0 then 'child'
		else ''
		end    
        from  dbo.MF_Zimun601      
        LEFT OUTER JOIN professions ON MF_Zimun601.ProfessionCode = professions.professionCode     
        LEFT OUTER JOIN service ON MF_Zimun601.ProfessionCode = service.serviceCode     
        LEFT join serviceParentChild on MF_Zimun601.ProfessionCode = dbo.serviceParentChild.childCode      
        LEFT join professionsParentChild on MF_Zimun601.ProfessionCode = dbo.professionsParentChild.childCode                    
         where DELFL=0   and (MF_Zimun601.ProfessionCode = @treeViewItem ) 
         

UNION 

         
SELECT  'MF_TatHitmahutZimun606' as tableName , 
MF_TatHitmahutZimun606.TatHitmahutCode  as Code ,      
MF_TatHitmahutZimun606.TatHitmahutDesc  as Name ,     
'NameR' = Case      
	when professions.professionCode IS  NOT  NULL then  professions.professionDescription      
	when service.serviceCode IS  NOT  NULL  then service.serviceDescription      
	end ,      
MF_TatHitmahutZimun606.TatHitmahutDesc as TableDescription ,      
professions.professionCode,service.serviceCode,     
'Category' = Case     
       when professions.professionCode IS  NOT  NULL and  @category = 'מקצוע'  then 'מקצוע' 
       when dbo.service.serviceCode IS  NOT  NULL and  @category = 'שירות' then 'שירות'     
       end ,     
'ParentCode' = case               
	when   (professionsParentChild.parentCode IS  NOT  NULL) then professionsParentChild.parentCode 
	when  (serviceParentChild.parentCode IS  NOT  NULL) then serviceParentChild.parentCode     
	end ,    
'ParentCodeName' = case     
	when  (professionsParentChild.parentCode IS  NOT  NULL)and (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode ) is not null then (select professionDescription from  dbo.professions where professionCode = professionsParentChild.parentCode )     
	when  (serviceParentChild.parentCode IS  NOT  NULL) and (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode) is not null then (select serviceDescription from dbo.service where serviceCode = serviceParentChild.parentCode)     
	end ,   
'Sector' = dbo.fun_GetSectorsCodesForProfession(professions.ProfessionCode),
'SectorDescription' =  dbo.fun_GetSectorsForProfession(professions.ProfessionCode),
professions.ShowExpert,   
'Relation' = case
	when @category = 'מקצוע' and (select count (parentCode) from dbo.professionsParentChild where parentCode = MF_TatHitmahutZimun606.TatHitmahutCode) > 0 then 'parent'
	when @category = 'מקצוע' and (select count (childCode) from dbo.professionsParentChild where  childCode= MF_TatHitmahutZimun606.TatHitmahutCode) > 0 then 'child'
	when @category = 'שירות' and (select count (parentCode) from dbo.serviceParentChild where parentCode = MF_TatHitmahutZimun606.TatHitmahutCode) > 0 then 'parent'
	when @category = 'שירות' and (select count (childCode) from dbo.serviceParentChild where childCode = MF_TatHitmahutZimun606.TatHitmahutCode) > 0 then 'child'
	else ''
	end 
  
   
FROM  MF_TatHitmahutZimun606      
LEFT OUTER JOIN professions ON MF_TatHitmahutZimun606.TatHitmahutCode = professions.professionCode      
LEFT OUTER JOIN service ON MF_TatHitmahutZimun606.TatHitmahutCode = service.serviceCode      
LEFT JOIN serviceParentChild on MF_TatHitmahutZimun606.TatHitmahutCode = serviceParentChild.childCode       
LEFT JOIN professionsParentChild on MF_TatHitmahutZimun606.TatHitmahutCode = dbo.professionsParentChild.childCode      
WHERE DELFL=0   AND 
( MF_TatHitmahutZimun606.TatHitmahutCode = @treeViewItem) 

GO

GRANT EXEC ON [dbo].rpc_showTreeViewItemDetails TO PUBLIC

GO

