IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDic_GeneralRemark')
	BEGIN
		DROP  Procedure  rpc_InsertDic_GeneralRemark
	END

GO

CREATE Procedure [dbo].[rpc_InsertDic_GeneralRemark]
(
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
		@openNow bit,
		@showForPreviousDays int,
		@UserName varchar(50)
	)
AS
	insert into
	DIC_GeneralRemarks
	(remark,
	RemarkCategoryID,
	active,
	linkedToDept,
	linkedToDoctor,
	linkedToDoctorInClinic,
	linkedToServiceInClinic,
	linkedToReceptionHours,
	EnableOverlappingHours,
	factor,
	OpenNow,
	ShowForPreviousDays,
	UpdateUser,
	UpdateDate)
	VALUES
	(@remark,
	@remarkCategoryID,
	@active,
	@linkedToDept,
	@linkedToDoctor,
	@linkedToDoctorInClinic,
	@linkedToServiceInClinic,
	@linkedToReceptionHours,
	@EnableOverlappingHours,
	@factor,
	@openNow,
	@showForPreviousDays,
	@UserName,
	getdate())

	GO

GRANT EXEC ON dbo.rpc_InsertDic_GeneralRemark TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_InsertDic_GeneralRemark TO [clalit\IntranetDev]
GO


