
/*-------------------------------------------------------------------------
Get all doctors receptions data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DoctorLanguages]'))
	DROP VIEW [dbo].vIngr_DoctorLanguages
GO


CREATE VIEW [dbo].vIngr_DoctorLanguages
AS
select el.EmployeeID as DoctorID, el.languageCode, l.languageDescription
from EmployeeLanguages el
join languages l
on el.languageCode = l.languageCode

GO

GRANT SELECT ON [dbo].vIngr_DoctorLanguages TO [public] AS [dbo]
GO
