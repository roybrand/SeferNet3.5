IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getAllServicesExtended')
	BEGIN
		DROP  Procedure  rpc_getAllServicesExtended
	END

GO

CREATE Procedure rpc_getAllServicesExtended

	(
		@ServiceCode varchar(100)
		
	)


AS
SELECT 
s.serviceCode,
s.serviceDescription,
dbo.serviceParentChild.parentCode,
'GroupName' = IsNull(s2.serviceDescription,s.serviceDescription),
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM dbo.service  as  s 
LEFT JOIN serviceParentChild ON s.serviceCode = serviceParentChild.childCode  
LEFT JOIN service s2 ON serviceParentChild.parentCode = s2.serviceCode
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) as sel ON s.serviceCode = sel.IntField
			

UNION
SELECT 
s.serviceCode,
s.serviceDescription,
null as ParentCode,
'GroupName' = s.serviceDescription,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM dbo.service  as  s 
LEFT JOIN serviceParentChild ON s.serviceCode = serviceParentChild.parentCode 
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) as sel ON s.serviceCode = sel.IntField

ORDER BY groupName, parentCode
GO


GRANT EXEC ON rpc_getAllServicesExtended TO PUBLIC

GO


