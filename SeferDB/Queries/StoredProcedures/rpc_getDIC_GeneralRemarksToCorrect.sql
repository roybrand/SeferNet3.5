IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDIC_GeneralRemarksToCorrect')
	BEGIN
		DROP  Procedure  rpc_getDIC_GeneralRemarksToCorrect
	END

GO

CREATE Procedure dbo.rpc_getDIC_GeneralRemarksToCorrect
	
	@linkedToDept bit = 0,
	@linkedToDoctor bit = 0,
	@linkedToDoctorInClinic bit = 0,
	@linkedToServiceInClinic bit = 0,
	@linkedToReceptionHours bit = 0,
	@userIsAdmin bit = 0,
	@RemarkCategoryID	int = -1 --  all Categories = -1 
	
AS

	Select
	remarkID,
	remark,
	active,
	EnableOverlappingHours,
	EnableOverMidnightHours,
	cat.RemarkCategoryName, 
	cat.RemarkCategoryID,
	rem.linkedToDept,
	rem.linkedToDoctor,
	rem.linkedToDoctorInClinic,
	rem.linkedToServiceInClinic,
	rem.linkedToReceptionHours,
	'InUseCount' = (SELECT COUNT(*) FROM DeptRemarks WHERE DicRemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeReceptionRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeServiceRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptReceptionRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeReceptionRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeServiceRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM EmployeeRemarks WHERE DicRemarkID = rem.remarkID)


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
	and(@RemarkCategoryID = -1 or rem.RemarkCategoryID = @RemarkCategoryID)
	and (@userIsAdmin = 1 or RelevantForSystemManager is null or RelevantForSystemManager <> 1)
	order by
	remarkID

GO

GRANT EXEC ON rpc_getDIC_GeneralRemarksToCorrect TO PUBLIC

GO


