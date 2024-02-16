CREATE Procedure [dbo].[rpc_getDicQueueOrderMethodsAndOptionsCombined]
(@selectedValues varchar(50))

AS

SELECT QueueOrderCode, QueueOrderDescription, CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as selected
FROM
(
	SELECT (QueueOrder - 2) as QueueOrderCode, QueueOrderDescription as QueueOrderDescription
	FROM DIC_QueueOrder
	WHERE PermitOrderMethods = 0

	UNION

	SELECT QueueOrderMethod as QueueOrderCode, QueueOrderMethodDescription as QueueOrderDescription
	FROM DIC_QueueOrderMethod
) innerSelect
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedValues)) as sel
	ON innerSelect.QueueOrderCode = sel.IntField
ORDER BY QueueOrderCode

GO