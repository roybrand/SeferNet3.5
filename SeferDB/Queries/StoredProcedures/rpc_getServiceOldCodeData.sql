IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceOldCodeData')
	BEGIN
		DROP  Procedure  rpc_getServiceOldCodeData
	END

GO


/****** Object:  StoredProcedure [dbo].[rpc_getServiceOldCodeData]    Script Date: 11/08/2009 16:43:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create Procedure [dbo].[rpc_getServiceOldCodeData]
	(		
		@ErrorStatus int output
	)
AS


select  service.serviceCode as 'Code', service.serviceDescription as 'Name', 
'Linked' = case        
when ( select count(OldCode) 
from  dbo.X_Professions_OldCodes
where service.serviceCode = X_Professions_OldCodes.OldCode and OldTable = 'service') > 0 
or 
(
(select count(OldCode) 
from dbo.X_Services_OldCodes
where service.serviceCode = X_Services_OldCodes.OldCode and OldTable = 'service') > 0

)

then 1     
else 0     
end , '' as TableName     
from dbo.service      
order by service.serviceDescription 
	

GO

GRANT EXEC ON rpc_getServiceOldCodeData TO PUBLIC

GO


