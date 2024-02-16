IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesAndEvents')
	BEGIN
		DROP  Procedure  rpc_GetServicesAndEvents
	END

GO

CREATE Procedure dbo.rpc_GetServicesAndEvents
(
	@selectedValues VARCHAR(100)
)

AS


SELECT
ServiceCode as Code,
ServiceDescription as Description,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM Services s
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedValues)) as sel ON s.serviceCode = sel.IntField


UNION 


SELECT
Eventcode as Code,
EventName as Description,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM DIC_Events e
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedValues)) as sel ON e.EventCode = sel.IntField


ORDER BY Description



GO


GRANT EXEC ON rpc_GetServicesAndEvents TO PUBLIC

GO


