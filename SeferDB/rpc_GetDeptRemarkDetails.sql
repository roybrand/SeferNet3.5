IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptRemarkDetails')
	BEGIN
		DROP  Procedure  rpc_GetDeptRemarkDetails
	END

GO

CREATE Procedure rpc_GetDeptRemarkDetails
@DeptRemarkId Int
As

Select DR.* , GR.remark as RemarkFormat
From DeptRemarks DR
Join DIC_GeneralRemarks GR On GR.remarkID = DR.DicRemarkID
Where DR.DeptRemarkID = @DeptRemarkId

GO

GRANT EXEC ON rpc_GetDeptRemarkDetails TO PUBLIC

GO


