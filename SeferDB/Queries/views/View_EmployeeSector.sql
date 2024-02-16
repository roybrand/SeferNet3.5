IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeSector')
	BEGIN
		DROP  View View_EmployeeSector
	END
GO

create VIEW [dbo].[View_EmployeeSector]
AS
SELECT  TOP 100   EmployeeSectorCode, EmployeeSectorDescription, RelevantForProfession, IsDoctor, EmployeeSectorDescriptionForCaption
FROM         dbo.EmployeeSector
WHERE     (EmployeeSectorCode <> 3)
ORDER BY OrderToShow 

GO