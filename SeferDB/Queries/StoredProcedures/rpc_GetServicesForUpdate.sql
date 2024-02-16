IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesForUpdate')
    BEGIN
	    DROP  Procedure  rpc_GetServicesForUpdate
    END

GO

CREATE Procedure [dbo].[rpc_GetServicesForUpdate]
(
	@serviceCode INT, 
	@serviceName VARCHAR(50),
	@serviceCategory INT, 
	@sectorCode INT,
	@requireQueueOrder INT,	 
	@isCommunity BIT, 
	@isMushlam BIT, 
	@isHospital BIT
)

AS


SELECT DISTINCT ser.ServiceCode, ser.ServiceDescription, ser.IsService, ser.IsProfession, 
		Isnull(ser.isInCommunity,0) as isInCommunity, Isnull(ser.isInMushlam,0) as isInMushlam, 
		Isnull(ser.isInHospitals,0) as isInHospitals, Isnull(ser.ShowExpert,'') as ShowExpert,
		CASE ISNull(t606.tatHitmahutCode, 0) WHEN 0 then 601 else 606 END as SourceTable, dbo.fun_getSectorsForService(ser.ServiceCode) as Sector
		,ser.displayServiceInInternet as displayInInternet, ser.RequiresQueueOrder
		,ISNULL(ser.ShowExpert, ' ') as Expert
		,[dbo].[fun_GetServiceCategories](ser.ServiceCode) as ServiceCategories
FROM [Services] ser
LEFT JOIN MF_TatHitmahutZimun606 t606 ON ser.ServiceCode = t606.tatHitmahutCode
LEFT JOIN x_ServiceCategories_Services xCat ON ser.serviceCode = xCat.ServiceCode
LEFT JOIN x_Services_EmployeeSector xSec ON ser.serviceCode = xSec.ServiceCode

WHERE	(ser.ServiceCode = @serviceCode OR @serviceCode IS NULL)
AND		(xCat.ServiceCategoryID = @serviceCategory OR @serviceCategory IS NULL)	
AND		(xSec.EmployeeSectorCode = @sectorCode OR @sectorCode IS NULL)
AND		(@requireQueueOrder IS NULL OR ser.RequiresQueueOrder = @requireQueueOrder )
AND		(	
			(@isCommunity IS NULL AND @isMushlam IS NULL AND @isHospital IS NULL)
			OR (IsInCommunity = @isCommunity)  OR (IsInMushlam = @isMushlam) OR (IsInHospitals = @isHospital)
		)
AND (ServiceDescription like '%' + @serviceName + '%' OR @serviceName IS NULL )
ORDER BY ServiceDescription 

GO


GRANT EXEC ON rpc_GetServicesForUpdate TO [clalit\webuser]
GO

GRANT EXEC ON rpc_GetServicesForUpdate TO [clalit\IntranetDev]
GO
