IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertHandicappedFacility')
	BEGIN
		DROP  Procedure  rpc_insertHandicappedFacility
	END

GO

CREATE Procedure rpc_insertHandicappedFacility
(
		@newCode int ,	
		@newDescription  varchar(50),
		@active tinyint
	)


AS

INSERT INTO [dbo].[DIC_HandicappedFacilities]
          ( [FacilityCode], [FacilityDescription] , [Active])
     VALUES
           (
			@newCode            
           ,@newDescription
           ,@active
			)



GO


GRANT EXEC ON rpc_insertHandicappedFacility TO PUBLIC

GO


