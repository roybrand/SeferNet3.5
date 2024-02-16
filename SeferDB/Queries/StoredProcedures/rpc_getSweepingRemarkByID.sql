IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSweepingRemarkByID')
	BEGIN
		DROP  Procedure  rpc_getSweepingRemarkByID
	END

GO

CREATE Procedure [dbo].[rpc_getSweepingRemarkByID]
(
	@RemarkID int
)

AS

SELECT DISTINCT r.RemarkText, r.DicRemarkID, 
convert(varchar, r.ValidFrom, 103) as ValidFrom, convert(varchar, r.ValidTo, 103) as ValidTo,
r.displayInInternet as Internetdisplay, r.DeptRemarkID as RelatedRemarkID,
ISNULL(DIC_GeneralRemarks.RelevantForSystemManager, 0) as RelevantForSystemManager
FROM DeptRemarks as r
JOIN DIC_GeneralRemarks ON r.DicRemarkID = DIC_GeneralRemarks.remarkID

WHERE DeptRemarkID = @RemarkID

GO

GRANT EXEC ON dbo.rpc_getSweepingRemarkByID TO PUBLIC

GO

