IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_GetPivotedDeptReceptionHours]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_GetPivotedDeptReceptionHours]
GO

CREATE FUNCTION [dbo].[fun_GetPivotedDeptReceptionHours]
(
	@DeptCode int
)
RETURNS 
@ReceptionPVT TABLE ([1] varchar(500), [2] varchar(500), [3] varchar(500), [4] varchar(500), [5] varchar(500), [6] varchar(500), [7] varchar(500), [8] varchar(500), [9] varchar(500))

AS
BEGIN
	DECLARE @Reception TABLE ([day] int, openingHour varchar(500))
	DECLARE @maxCount int SET @maxCount = 0

INSERT INTO @Reception
SELECT receptionDay, openingHour FROM
(SELECT TOP 100 
DeptReception.receptionDay,
--DIC_ReceptionDays.ReceptionDayName,
'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24 ' WHEN '01:00' THEN '24 ' WHEN '00:00' THEN '24 ' ELSE openingHour + '-' END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24 ' WHEN '01:00' THEN '24 ' WHEN '00:00' THEN '24 ' ELSE openingHour + '-' END
		ELSE openingHour + '-' END  +
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END + 
	CASE dbo.fun_getDeptReceptionRemarksValid(receptionID)
		WHEN '' THEN '' ELSE '<br>' + dbo.fun_getDeptReceptionRemarksValid(receptionID) END
FROM DeptReception
inner join DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
where deptCode=@DeptCode
and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
order by receptionDay, openingHour) as innerTable

	SET @maxCount = 
	(SELECT MAX(maxCount) FROM 
	(SELECT [day], COUNT([day]) as [maxCount] FROM @Reception
	GROUP BY [day]) as T)

	WHILE @maxCount > 0
	BEGIN
		INSERT INTO @ReceptionPVT
		([1],[2],[3],[4],[5],[6],[7],[8],[9])
		VALUES
		(
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 1 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [1]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 2 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [2]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 3 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [3]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 4 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [4]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 5 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [5]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 6 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [6]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 7 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [7]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 8 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [8]) ),
			(SELECT TOP 1 openingHour
			FROM @Reception WHERE [day] = 9 AND NOT exists (SELECT * FROM @ReceptionPVT WHERE openingHour = [9]) )
		)
		SET @maxCount = @maxCount - 1
	END
	
	UPDATE @ReceptionPVT SET [1] = '&nbsp;' WHERE [1] is null
	UPDATE @ReceptionPVT SET [2] = '&nbsp;' WHERE [2] is null
	UPDATE @ReceptionPVT SET [3] = '&nbsp;' WHERE [3] is null
	UPDATE @ReceptionPVT SET [4] = '&nbsp;' WHERE [4] is null
	UPDATE @ReceptionPVT SET [5] = '&nbsp;' WHERE [5] is null
	UPDATE @ReceptionPVT SET [6] = '&nbsp;' WHERE [6] is null
	UPDATE @ReceptionPVT SET [7] = '&nbsp;' WHERE [7] is null
	UPDATE @ReceptionPVT SET [8] = '&nbsp;' WHERE [8] is null
	UPDATE @ReceptionPVT SET [9] = '&nbsp;' WHERE [9] is null
	
	
	RETURN
END