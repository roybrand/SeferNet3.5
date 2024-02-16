IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getCitiesByNameAndDistrict')
	BEGIN
		DROP  Procedure  rpc_getCitiesByNameAndDistrict
	END

GO

CREATE 
procedure [dbo].[rpc_getCitiesByNameAndDistrict]
(
	@DistrictCode varchar(100)
)

as


SELECT [cityCode], [cityName], [districtCode] ,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM [Cities]
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@DistrictCode)) as sel ON [Cities].[cityCode] = sel.IntField
WHERE ( [cityName] <> '')

ORDER BY cityName

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 9

GO
	
GRANT EXEC ON dbo.rpc_getCitiesByNameAndDistrict TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getCitiesByNameAndDistrict TO [clalit\IntranetDev]
GO  
