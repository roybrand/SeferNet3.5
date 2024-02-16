IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClalitServiceDescription_ByClalitServiceCode')
	BEGIN
		DROP  Procedure  rpc_GetClalitServiceDescription_ByClalitServiceCode
	END
GO

CREATE Procedure [dbo].[rpc_GetClalitServiceDescription_ByClalitServiceCode]
(
	@ClalitServiceCode int
)

AS 

SELECT MF_SalServices386.ServiceName as ClalitServiceDescription
FROM MF_SalServices386
WHERE MF_SalServices386.ServiceCode = @ClalitServiceCode

GO

GRANT EXEC ON rpc_GetClalitServiceDescription_ByClalitServiceCode TO PUBLIC
GO

