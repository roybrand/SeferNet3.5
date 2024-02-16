IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_GetDeptQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_GetDeptQueueOrderMethods
(
	@deptCode INT
)

AS

SELECT  qo.QueueOrder, dqom.QueueOrderMethod,
'DeptPhone' = dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension),
queuePhones.prePrefix, dic.prefixCode, dic.prefixValue as PrefixText, queuePhones.phone, queuePhones.extension
 
FROM Dept 
LEFT JOIN Dic_QueueOrder qo ON Dept.QueueOrder = qo.QueueOrder
LEFT JOIN DeptQueueOrderMethod dqom ON Dept.deptCode = dqom.DeptCode 
LEFT JOIN DeptPhones ON dqom.deptCode =  deptPhones.DeptCode  AND PhoneType = 1 AND PhoneOrder = 1 AND dqom.QueueOrderMethod = 1
LEFT JOIN DeptQueueOrderPhones queuePhones ON dqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
LEFT JOIN DIC_PhonePrefix dic ON queuePhones.Prefix = dic.prefixCode
WHERE Dept.deptCode = @deptCode





SELECT DeptQueueOrderHoursID AS QueueOrderHoursID, receptionDay, FromHour as OpeningHour, ToHour as ClosingHour, 
'NumOfSessionsPerDay' = (
			SELECT count(*)
			FROM DeptQueueOrderMethod dqom2
			INNER JOIN DeptQueueOrderHours hours2 ON dqom2.QueueOrderMethodID = hours2.QueueOrderMethodID 
			AND hours.ReceptionDay = hours2.ReceptionDay
			GROUP BY receptionDay
		)
FROM DeptQueueOrderMethod dqom
INNER JOIN DeptQueueOrderHours hours ON dqom.QueueOrderMethodID = hours.QueueOrderMethodID
WHERE dqom.DeptCode = @DeptCode 
ORDER BY FromHour,ToHour




GO


GRANT EXEC ON rpc_GetDeptQueueOrderMethods TO PUBLIC

GO


