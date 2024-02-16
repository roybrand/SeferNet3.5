IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptReceptionHoursForTekenVeSivug]'))
DROP VIEW [dbo].[vIngr_DeptReceptionHoursForTekenVeSivug]
GO

/*
	Select Depts reception hours for specific dept types & only for 'regular' days of week 
	Owner : Integration Team
*/
CREATE VIEW [dbo].[vIngr_DeptReceptionHoursForTekenVeSivug]
AS
SELECT TOP 100000 deptCode, ReceptionHoursTypeID, ReceptionTypeDescription,
                          (SELECT SUM(dbo.rfn_TimeInterval_float(openingHour, closingHour)) AS Expr1
                            FROM dbo.DeptReception AS dr
                            WHERE	(deptCode = T.deptCode) 
                            AND		(receptionDay < 8)
                            AND		GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')
                            AND		dr.ReceptionHoursTypeID = T.ReceptionHoursTypeID
                            GROUP BY deptCode) AS ReceptionHours
FROM
(
	SELECT d.deptCode, dr.ReceptionHoursTypeID, DIC_ReceptionHoursTypes.ReceptionTypeDescription
	FROM DeptReception dr
	JOIN DIC_ReceptionHoursTypes ON dr.ReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
	JOIN Dept d ON dr.deptCode = d.deptCode
		and (d.typeUnitCode IN (102, 103, 104, 107, 101, 501, 502, 503)
				OR 
			(typeUnitCode IN (202, 203, 204, 205, 207, 208, 212) AND (subUnitTypeCode = 0))
			)
		and d.status = 1
	GROUP BY d.deptCode, dr.ReceptionHoursTypeID, DIC_ReceptionHoursTypes.ReceptionTypeDescription
) T
ORDER BY deptCode, ReceptionHoursTypeID

GO

GRANT SELECT ON [dbo].[vIngr_DeptReceptionHoursForTekenVeSivug] TO [public] AS [dbo]
GO
