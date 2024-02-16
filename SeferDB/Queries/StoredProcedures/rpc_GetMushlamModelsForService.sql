IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamModelsForService')
    BEGIN
	    DROP  Procedure  rpc_GetMushlamModelsForService
    END

GO

CREATE Procedure dbo.rpc_GetMushlamModelsForService
(
	@serviceCode INT
)

AS

SELECT models.GroupCode, models.SubGroupCode, models.ModelDescription, models.Remark, 
		models.ParticipationAmount, IsNull(models.WaitingPeriod, 0) as WaitingPeriod
FROM MushlamModels models
INNER JOIN MushlamServicesInformation msi 
ON models.GroupCode = msi.GroupCode AND models.SubGroupCode = msi.SubGroupCode
WHERE msi.ServiceCode = @serviceCode
AND msi.HasModels <> 0
AND ServiceType <> 4

                
GO


GRANT EXEC ON rpc_GetMushlamModelsForService TO PUBLIC

GO            
