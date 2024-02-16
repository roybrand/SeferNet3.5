IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateService')
    BEGIN
	    DROP  Procedure  rpc_UpdateService
    END

GO

ALTER Procedure [dbo].[rpc_UpdateService]
(
	@serviceCode INT,  
	@serviceDesc VARCHAR(100),  
	@isService BIT,  
	@isProfession BIT,  
	@sectors VARCHAR(100), 
	@isCommunity BIT,  
	@isMushlam BIT,  
	@isHospitals BIT,  
	@categories VARCHAR(100),  
	@enableExpert BIT,  
	@showExpert VARCHAR(50),
	@SectorToShowWith int,
	@displayInInternet BIT,
	@requiresQueueOrder BIT
)

AS


UPDATE [Services]
SET ServiceDescription = @serviceDesc, 
IsService = @isService, 
IsProfession = @isProfession,
IsInCommunity = @isCommunity,
IsInMushlam = @isMushlam,
IsInHospitals = @isHospitals,
EnableExpert = @enableExpert,
ShowExpert = @showExpert,
SectorToShowWith = @SectorToShowWith,
displayServiceInInternet = @displayInInternet,
RequiresQueueOrder = @requiresQueueOrder

WHERE ServiceCode = @serviceCode

-- Sectors
DELETE x_Services_EmployeeSector
WHERE ServiceCode = @serviceCode

INSERT INTO x_Services_EmployeeSector
SELECT @serviceCode, IntField
FROM dbo.SplitString(@sectors)


-- Categories
DELETE x_ServiceCategories_Services
WHERE ServiceCode = @serviceCode

INSERT INTO x_ServiceCategories_Services
SELECT IntField, @serviceCode
FROM dbo.splitString(@categories)
         
GO


GRANT EXEC ON rpc_UpdateService TO PUBLIC

GO            
