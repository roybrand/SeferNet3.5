IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptReception')
	BEGIN
		DROP  Procedure  rpc_GetDeptReception
	END

GO

/*
**************
FOR INTERNET
**************
*/


CREATE Procedure dbo.rpc_GetDeptReception
(
	@deptCode INT
)

AS

-- if deot is not enabled, or not for display in internet - do nothing
IF @deptCode IN (SELECT DeptCode
				 FROM Dept
				 WHERE Dept.ShowUnitInInternet = 0 OR DeptCode IN	(SELECT DISTINCT DeptCode 
																	FROM DeptStatus 
																	WHERE Status = 0 AND DATEDIFF(dd,FromDate, GETDATE()) >= 0 
																	AND (ToDate IS NULL OR DATEDIFF(dd, ToDate, GETDATE()) <= 0 )
																	)
				)													
	RETURN
				 


SELECT  ReceptionDay, ReceptionDayName, OpeningHour, ClosingHour,
'remarks' = dbo.fun_getDeptReceptionRemarks(dr.ReceptionID, 1),  dr.ValidTo
FROM DeptReception dr
INNER JOIN DIC_ReceptionDays ON dr.receptionDay = DIC_ReceptionDays.ReceptionDayCode
WHERE DeptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) >=0 
AND (DATEDIFF(dd, ValidTo, GETDATE()) <= 0 OR ValidTo IS NULL)
ORDER BY ReceptionDayName



SELECT ReceptionDay, ReceptionDayName, OpeningHour, ClosingHour,
'remarks' = dbo.fun_GetDeptServiceReceptionRemarks(ReceptionID, 1), dsr.ValidTo
FROM DeptServiceReception dsr
INNER JOIN Service ON dsr.ServiceCode = service.ServiceCode
INNER JOIN DIC_ReceptionDays ON dsr.receptionDay = DIC_ReceptionDays.ReceptionDayCode
WHERE DeptCode = @deptCode 
AND Service.OfficeServices = 1 
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= 0 
AND (DATEDIFF(dd, ValidTo, GETDATE()) <= 0 OR ValidTo IS NULL)
ORDER BY ReceptionDayName


SELECT RemarkText
FROM Remarks
WHERE DeptCode = @deptCode
AND (DATEDIFF(dd, ValidFrom, GETDATE()) >= 0 OR ValidFrom IS NULL)
AND (DATEDIFF(dd, ValidTo, GETDATE()) <= 0 OR ValidTo IS NULL)
AND DisplayInInternet = 1

GO


GRANT EXEC ON rpc_GetDeptReception TO PUBLIC

GO

