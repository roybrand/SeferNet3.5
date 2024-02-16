IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getAdminsExtended')
	BEGIN
		DROP  Procedure  rpc_getAdminsExtended
	END

GO

CREATE Procedure [dbo].[rpc_getAdminsExtended] 
	(
		@SelectedAdmins varchar(100),
		@DistrictCode varchar(100)
	)

AS

IF(@DistrictCode = '')
	BEGIN SET @DistrictCode = null END


SELECT
deptCode as adminCode,
deptName as adminName,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END

FROM
dept
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedAdmins)) as sel ON dept.deptCode = sel.IntField

WHERE deptType = 2
AND status = 1
AND (@DistrictCode is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCode)))
	
SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 10

GO


GRANT EXEC ON dbo.rpc_getAdminsExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getAdminsExtended TO [clalit\IntranetDev]
GO   

