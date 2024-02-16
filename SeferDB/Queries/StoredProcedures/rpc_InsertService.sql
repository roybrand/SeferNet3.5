IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertService')
    BEGIN
	    DROP  Procedure  rpc_InsertService
    END

GO

CREATE Procedure [dbo].[rpc_InsertService]
(
	@serviceCode INT,  
	@serviceDesc VARCHAR(100),  
	@isService BIT,  
	@isProfession BIT,  
	@sectors VARCHAR(30),
	@isCommunity BIT,  
	@isMushlam BIT,  
	@isHospitals BIT,  
	@categories VARCHAR(100),  
	@enableExpert BIT,  
	@showExpert VARCHAR(100),
	@SectorToShowWith int,
	@displayInInternet BIT
)

AS

INSERT INTO [Services] (ServiceCode,  ServiceDescription, IsService, IsProfession, IsInMushlam, IsInCommunity, 
									IsInHospitals, ShowExpert, EnableExpert, SectorToShowWith, displayInInternet)
VALUES (@serviceCode,  @serviceDesc, @isService, @isProfession, @isMushlam, @isCommunity, @isHospitals, @showExpert, @enableExpert, @SectorToShowWith, @displayInInternet)


INSERT INTO x_Services_EmployeeSector
SELECT @serviceCode, IntField
FROM dbo.SplitString(@sectors)


INSERT INTO x_ServiceCategories_Services
SELECT IntField, @serviceCode
FROM dbo.SplitString(@categories)
                
GO


GRANT EXEC ON rpc_InsertService TO PUBLIC

GO            
