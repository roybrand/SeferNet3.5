IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceParents')
	BEGIN
		DROP  Procedure  rpc_getServiceParents
	END

GO


create Procedure [dbo].[rpc_getServiceParents]
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


   select  service.serviceCode as 'Code',      
   serviceDescription  as 'Name',      
   'Linked' = case     
   when (      
   select count(serviceParentChild.parentCode) from serviceParentChild      
   where childCode=service.serviceCode) > 0 then 1      
   else 0      
   end , 
	'' as TableName      
   from dbo.service        
   where serviceCode <> @childServiceID  
   and  serviceCode not in (select distinct childCode from dbo.serviceParentChild)     
   and ((@oldCode is null) or (serviceCode <>@oldCode))
   order by serviceDescription 
	
	

GRANT EXEC ON rpc_getServiceParents TO PUBLIC

GO


