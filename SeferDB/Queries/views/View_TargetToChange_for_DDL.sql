IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_TargetToChange_for_DDL')
BEGIN
	DROP  view  View_TargetToChange_for_DDL
END

GO

CREATE view [dbo].[View_TargetToChange_for_DDL] as

SELECT DISTINCT TargetCode, TargetName
FROM TargetToChange

GO

GRANT SELECT  ON View_TargetToChange_for_DDL TO PUBLIC
GO