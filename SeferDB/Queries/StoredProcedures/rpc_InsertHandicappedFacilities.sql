IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertHandicappedFacilities')
	BEGIN
		DROP  Procedure  rpc_InsertHandicappedFacilities
	END

GO

CREATE Procedure rpc_InsertHandicappedFacilities

	(
		@FacilityCode int,
		@FacilityDescription varchar(150)
	)


AS

insert into DIC_HandicappedFacilities
(FacilityCode,FacilityDescription)
values(@FacilityCode,@FacilityDescription)

GO


GRANT EXEC ON rpc_InsertHandicappedFacilities TO PUBLIC

GO


