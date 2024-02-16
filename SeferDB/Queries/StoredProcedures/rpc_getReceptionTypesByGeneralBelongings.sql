IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getReceptionTypesByGeneralBelongings')
	BEGIN
		DROP  Procedure  rpc_getReceptionTypesByGeneralBelongings
	END

GO

CREATE Procedure [dbo].[rpc_getReceptionTypesByGeneralBelongings]
	(
		@IsCommunity bit,
		@IsMushlam bit,
		@IsHospital bit
	)

AS

SELECT ReceptionHoursTypeID, ReceptionTypeDescription, EnumName
FROM DIC_ReceptionHoursTypes
WHERE (@IsCommunity = 1 AND IsCommunity = @IsCommunity)
OR (@IsMushlam = 1 AND IsMushlam = @IsMushlam)
OR (@IsHospital = 1 AND IsHospital = @IsHospital)
ORDER BY OrderNumber

GO

GRANT EXEC ON rpc_getReceptionTypesByGeneralBelongings TO PUBLIC
GO

