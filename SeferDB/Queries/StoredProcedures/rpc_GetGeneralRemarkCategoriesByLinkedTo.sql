IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetGeneralRemarkCategoriesByLinkedTo')
	BEGIN
		DROP  Procedure  rpc_GetGeneralRemarkCategoriesByLinkedTo
	END

GO

CREATE Procedure dbo.rpc_GetGeneralRemarkCategoriesByLinkedTo
	
	@linkedToDept bit = 0,
	@linkedToDoctor bit = 0,
	@linkedToDoctorInClinic bit = 0,
	@linkedToServiceInClinic bit = 0,
	@linkedToReceptionHours bit = 0,
	@userIsAdmin bit = 0
	
AS

	Select distinct 
	cat.RemarkCategoryID,
	cat.RemarkCategoryName

	from 
	DIC_GeneralRemarks as rem
	left join DIC_RemarkCategory  as cat
	on rem.RemarkCategoryID =  cat.RemarkCategoryID

	where
	(
		(@linkedToDept = 0 and @linkedToDoctor = 0 and @linkedToDoctorInClinic = 0 and
		 @linkedToServiceInClinic= 0 and @linkedToReceptionHours = 0)
		 or
		(@linkedToDept = 1 and linkedToDept=1) or
		(@linkedToDoctor = 1 and linkedToDoctor=1) or
		(@linkedToDoctorInClinic = 1 and linkedToDoctorInClinic=1) or
		(@linkedToServiceInClinic= 1 and linkedToServiceInClinic= 1) or
		(@linkedToReceptionHours = 1 and linkedToReceptionHours = 1)
	)
	and (@userIsAdmin = 1 or RelevantForSystemManager is null or RelevantForSystemManager <> 1)
	order by
	cat.RemarkCategoryName

GO

GRANT EXEC ON rpc_GetGeneralRemarkCategoriesByLinkedTo TO PUBLIC

GO


