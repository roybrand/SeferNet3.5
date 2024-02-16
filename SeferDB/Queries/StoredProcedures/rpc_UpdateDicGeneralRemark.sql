IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDicGeneralRemark')
	BEGIN
		DROP  Procedure  rpc_UpdateDicGeneralRemark
	END

GO

CREATE Procedure [dbo].[rpc_UpdateDicGeneralRemark]
	(
		@remarkID int,
		@remark varchar(500),
		@remarkCategoryID int,
		@active bit,
		@linkedToDept bit = 0,
		@linkedToDoctor bit = 0,
		@linkedToDoctorInClinic bit = 0,
		@linkedToServiceInClinic bit = 0,
		@linkedToReceptionHours bit = 0,
		@EnableOverlappingHours bit = 0,
		@factor float = 1,
		@UserName varchar(50)
	)
AS
	
	UPDATE DIC_GeneralRemarks
	
	SET
	remark = @remark,
	RemarkCategoryID = @remarkCategoryID,
	active = @active,
	linkedToDept =@linkedToDept,
	linkedToDoctor = @linkedToDoctor,
	linkedToDoctorInClinic = @linkedToDoctorInClinic,
	linkedToServiceInClinic = @linkedToServiceInClinic,
	linkedToReceptionHours = @linkedToReceptionHours,
	EnableOverlappingHours = @EnableOverlappingHours,
	factor = @factor,
	UpdateUser = @UserName,
	UpdateDate = getdate()
	WHERE remarkID = @remarkID
GO


GRANT EXEC ON dbo.rpc_UpdateDicGeneralRemark TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_UpdateDicGeneralRemark TO [clalit\IntranetDev]
GO



