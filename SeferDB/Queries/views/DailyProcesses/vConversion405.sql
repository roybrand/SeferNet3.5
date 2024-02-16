IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vConversion405')
	BEGIN
		DROP  View vConversion405
	END
GO

create VIEW [dbo].[vConversion405]
AS

SELECT
C405.*
FROM Conversion405 C405 
JOIN
( 
	SELECT SimulId, SystemId, InActive, MAX(UpdateDate) as MAX_DATE
	FROM Conversion405
	GROUP BY SimulId, SystemId, InActive
) T ON C405.SimulId = T.SimulId AND C405.SystemId = T.SystemId AND T.MAX_DATE = C405.UpdateDate

GO