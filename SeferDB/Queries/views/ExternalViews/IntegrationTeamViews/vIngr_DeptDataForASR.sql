/*
	לצורך עדכון נתוני מרפאות באופן שוטף לצורף הקלטתן למערכת זימון תורים בזיהוי דיבור (ASR)
	נבקש גזירה יומית של נתוני מרפאות ראשוניות, משולבות, יועצות, כפריות ועצמאיות

	Owner : Integration Team
*/


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptDataForASR]'))
	DROP VIEW [dbo].[vIngr_DeptDataForASR]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vIngr_DeptDataForASR]
AS
SELECT d.deptCode, ds.Simul228 as oldDeptCode, deptName, d.cityCode, c.cityName, streetName, house, addressComment
FROM dbo.Dept AS d
join Cities c
on d.cityCode = c.cityCode
join deptSimul ds
on d.deptCode = ds.deptCode
WHERE	typeUnitCode IN (101, 102, 103, 104, 112)
		AND (status = 1)

GO


GRANT SELECT ON [dbo].[vIngr_DeptDataForASR] TO [public] AS [dbo]
GO
