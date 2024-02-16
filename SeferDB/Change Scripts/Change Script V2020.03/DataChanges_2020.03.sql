UPDATE DeptRemarks
SET ActiveFrom = DATEADD(dd, - DIC_GeneralRemarks.ShowForPreviousDays, DeptRemarks.validFrom)
FROM DeptRemarks
JOIN DIC_GeneralRemarks ON DeptRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID

GO

UPDATE EmployeeRemarks
SET ActiveFrom = DATEADD(dd, - DIC_GeneralRemarks.ShowForPreviousDays, EmployeeRemarks.validFrom)
FROM EmployeeRemarks
JOIN DIC_GeneralRemarks ON EmployeeRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID

GO	

UPDATE DeptEmployeeServiceRemarks
SET ActiveFrom = DATEADD(dd, - DIC_GeneralRemarks.ShowForPreviousDays, DeptEmployeeServiceRemarks.validFrom)
FROM DeptEmployeeServiceRemarks
JOIN DIC_GeneralRemarks ON DeptEmployeeServiceRemarks.RemarkID = DIC_GeneralRemarks.remarkID

GO

UPDATE DeptReceptionRemarks
SET ActiveFrom = DATEADD(dd, - DIC_GeneralRemarks.ShowForPreviousDays, DeptReceptionRemarks.validFrom)
FROM DeptReceptionRemarks
JOIN DIC_GeneralRemarks ON DeptReceptionRemarks.RemarkID = DIC_GeneralRemarks.remarkID

GO
