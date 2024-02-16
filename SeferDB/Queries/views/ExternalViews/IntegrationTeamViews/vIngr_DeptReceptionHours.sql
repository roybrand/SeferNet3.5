
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptReceptionHours]'))
	DROP VIEW [dbo].[vIngr_DeptReceptionHours]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
	Select Depts reception hours for specific dept types & only for 'regular' days of week 
	Owner : Integration Team
*/
CREATE VIEW [dbo].[vIngr_DeptReceptionHours]
AS
SELECT     deptCode,
                          (SELECT	SUM(dbo.rfn_TimeInterval_float(openingHour, closingHour)) AS Expr1
                            FROM	dbo.DeptReception AS dr
                            WHERE	(deptCode = d.deptCode) AND (receptionDay < 8)
                            and		GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')  
                            GROUP BY deptCode) AS ReceptionHours
FROM         dbo.Dept AS d
WHERE     ((typeUnitCode IN (102, 103, 104, 107, 101, 501, 502, 503)) OR
          (typeUnitCode IN (202, 203, 204, 205, 207, 208, 212) AND (subUnitTypeCode = 0)))
          AND (status = 1)

GO


GRANT SELECT ON [dbo].[vIngr_DeptReceptionHours] TO [public] AS [dbo]
GO
