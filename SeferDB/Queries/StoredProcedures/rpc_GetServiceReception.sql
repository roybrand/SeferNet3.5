IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServiceReception')
	BEGIN
		DROP  Procedure  rpc_GetServiceReception
	END

GO

CREATE Procedure rpc_GetServiceReception
(
	@deptCode INT,
	@serviceCode INT
)

AS


SELECT rec.receptionDay, days.receptionDayName,openingHour, closingHour, remarkText, rec.ValidTo
FROM DeptServiceReception rec
LEFT JOIN DeptServiceReceptionRemarks rem
ON rec.ReceptionId = rem.ServiceReceptionId
INNER JOIN DIC_ReceptionDays days
ON rec.ReceptionDay = days.receptionDayCode
WHERE ( (Datediff(dd,GetDate(),rec.ValidFrom) <= 0 OR rec.ValidFrom IS NULL )
	    OR
	    (Datediff(dd,GetDate(),rec.ValidTo) >= 0 OR rec.ValidTo IS NULL )
	  )
	  AND DeptCode = @deptCode 
	  AND ServiceCode = @serviceCode


SELECT * FROM DeptServiceRemarks
WHERE DeptCode = @deptCode 
AND ServiceCode = @serviceCode



GO


GRANT EXEC ON rpc_GetServiceReception TO PUBLIC

GO


