IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceByNameOrCode')
    BEGIN
	    DROP  Procedure  rpc_getServiceByNameOrCode
    END

GO

CREATE Procedure dbo.rpc_getServiceByNameOrCode
(
	@prefixText VARCHAR(10)
)

AS


SELECT ServiceCode, ServiceDescription
FROM [Services]
WHERE ServiceDescription like  @prefixText + '%'
OR ServiceCode like @prefixText  + '%' 

UNION 

SELECT ServiceCode, ServiceDescription
FROM [Services]
WHERE ServiceDescription like '%' + @prefixText + '%'
OR ServiceCode like '%' + @prefixText  + '%' 



                
GO


GRANT EXEC ON rpc_getServiceByNameOrCode TO PUBLIC

GO            
