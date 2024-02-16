IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Positions')
	BEGIN
		DROP  view  View_Positions
	END
GO

create VIEW [dbo].[View_Positions]
AS
SELECT     positionCode, positionDescription, relevantSector
FROM         dbo.position
WHERE     (useInSearches = 1) AND (IsActive = 1)


GO 