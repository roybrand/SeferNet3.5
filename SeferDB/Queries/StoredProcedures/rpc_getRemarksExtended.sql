IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getRemarksExtended')
	BEGIN
		DROP  Procedure  dbo.rpc_getRemarksExtended
	END

GO

CREATE Procedure [dbo].[rpc_getRemarksExtended]
	(
		@SelectedRemarks varchar(100),
		@linkedToDept bit = 0,
		@linkedToServiceInClinic bit = 0,
		@linkedToDoctor bit = 0,
		@linkedToDoctorInClinic bit = 0,
		@linkedToReceptionHours bit = 0
	)

AS

SELECT
DIC_GeneralRemarks.remarkID as RemarkCode,
DIC_GeneralRemarks.Remark as RemarkDescription,
'selected' = CASE IsNull(selected.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
,DIC_GeneralRemarks.linkedToDept,DIC_GeneralRemarks.linkedToServiceInClinic

FROM DIC_GeneralRemarks
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedRemarks)) as selected ON DIC_GeneralRemarks.remarkID = selected.IntField
where DIC_GeneralRemarks.active = 1
and ((@linkedToDept = 1 and DIC_GeneralRemarks.linkedToDept=1) or
	(@linkedToDoctor = 1 and DIC_GeneralRemarks.linkedToDoctor=1) or
	(@linkedToDoctorInClinic = 1 and DIC_GeneralRemarks.linkedToDoctorInClinic=1) or
	(@linkedToServiceInClinic= 1 and DIC_GeneralRemarks.linkedToServiceInClinic= 1) or
	(@linkedToReceptionHours = 1 and DIC_GeneralRemarks.linkedToReceptionHours = 1))

ORDER BY DIC_GeneralRemarks.Remark

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 13

GO


GRANT EXEC ON dbo.rpc_getRemarksExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getRemarksExtended TO [clalit\IntranetDev]
GO

