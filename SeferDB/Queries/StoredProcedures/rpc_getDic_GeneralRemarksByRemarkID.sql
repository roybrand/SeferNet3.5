IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDic_GeneralRemarksByRemarkID')
	BEGIN
		DROP  Procedure  rpc_getDic_GeneralRemarksByRemarkID
	END

GO

CREATE Procedure [dbo].[rpc_getDic_GeneralRemarksByRemarkID]
(
	@remarkID int
)

AS
Select 
remarkID,
remark,
active,
RemarkCategoryID,
EnableOverlappingHours,
linkedToDept,
linkedToDoctor,
linkedToDoctorInClinic,
linkedToServiceInClinic,
linkedToReceptionHours,
Factor,
OpenNow,
ShowForPreviousDays
From 
DIC_GeneralRemarks
where
remarkID = @remarkID

GO


GRANT EXEC ON dbo.rpc_getDic_GeneralRemarksByRemarkID TO PUBLIC

GO


