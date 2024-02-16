IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateHandicappedFacility')
	BEGIN
		DROP  Procedure  rpc_updateHandicappedFacility
	END

GO

CREATE Procedure rpc_updateHandicappedFacility
(
		@code int, 	
		@name varchar(100),
		@active tinyint		
)
as
  

UPDATE [DIC_HandicappedFacilities]       
      SET  [FacilityDescription] = @name 	,
      		[Active]= @active
       WHERE [FacilityCode] =@code  

GO


GRANT EXEC ON rpc_updateHandicappedFacility TO PUBLIC

GO


