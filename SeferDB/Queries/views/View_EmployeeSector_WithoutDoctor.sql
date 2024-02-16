IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeSector_WithoutDoctor')
	BEGIN
		DROP  View View_EmployeeSector_WithoutDoctor
	END
GO

CREATE VIEW [dbo].[View_EmployeeSector_WithoutDoctor]
AS
SELECT     EmployeeSectorCode, EmployeeSectorDescription
FROM         dbo.EmployeeSector
WHERE     (IsDoctor = 0)

GO
