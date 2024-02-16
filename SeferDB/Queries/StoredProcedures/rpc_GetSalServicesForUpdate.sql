IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServicesForUpdate')
	BEGIN
		DROP  Procedure  dbo.rpc_GetSalServicesForUpdate
	END

GO

CREATE Procedure [dbo].[rpc_GetSalServicesForUpdate]
(
@ServiceCode int,
@ServiceDescription varchar(200),
@ServiceStatus smallint,
@ExtensionExists smallint
)
as

DECLARE @Today date SET @Today = GETDATE()

SELECT ServiceCode, ServiceName, CONVERT(VARCHAR(11),CONVERT(DATE,DateUpdate)) as DateUpdate, 
	CASE ServiceReturnExist WHEN 1 THEN 'כן' ELSE 'לא' END as ServiceReturnExist,
	ServiceReturnExist as ServiceReturnExistBit,
	CASE WHEN (IsCanceled = 0 AND (ss.DEL_DATE Is Null OR ss.DEL_DATE > @Today))
		THEN 'כן' ELSE 'לא' END as Active
FROM MF_SalServices386 ss
WHERE 
(
	(@ServiceCode is null OR @ServiceCode = -1 )

	AND (@ServiceDescription is null OR ServiceName LIKE '%'+ @ServiceDescription + '%') 
	AND (@ServiceStatus is null OR @ServiceStatus = -1
		OR (@ServiceStatus = 0 AND (ss.IsCanceled = 1 OR ss.DEL_DATE Is NOT Null))
		OR (@ServiceStatus = 1 AND (ss.IsCanceled = 0 AND ss.DEL_DATE Is Null))
		)
	AND (@ExtensionExists is null OR @ExtensionExists = -1 OR ServiceReturnExist = @ExtensionExists)
)
OR ss.ServiceCode = @ServiceCode

GO


GRANT EXEC ON dbo.rpc_GetSalServicesForUpdate TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetSalServicesForUpdate TO [clalit\IntranetDev]
GO 