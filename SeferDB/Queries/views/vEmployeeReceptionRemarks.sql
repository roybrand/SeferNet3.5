 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vEmployeeReceptionRemarks')
	BEGIN
		DROP  view  vEmployeeReceptionRemarks
	END

GO

create VIEW dbo.[vEmployeeReceptionRemarks]
AS
SELECT     ISNULL(REPLACE(dbo.DeptEmployeeReceptionRemarks.RemarkText, '#', ''), '') AS RemarkText,
 dbo.vEmployeeReceptionHours.EmployeeID, 
                      dbo.vEmployeeReceptionHours.EmployeeSectorCode,
                       dbo.vEmployeeReceptionHours.receptionID,
                        dbo.vEmployeeReceptionHours.deptCode
FROM         dbo.DeptEmployeeReceptionRemarks INNER JOIN
                      dbo.vEmployeeReceptionHours ON dbo.DeptEmployeeReceptionRemarks.EmployeeReceptionID = dbo.vEmployeeReceptionHours.receptionID
WHERE     (dbo.DeptEmployeeReceptionRemarks.ValidFrom IS NULL OR
                      dbo.DeptEmployeeReceptionRemarks.ValidFrom <= GETDATE()) AND (dbo.DeptEmployeeReceptionRemarks.ValidTo IS NULL OR
                      dbo.DeptEmployeeReceptionRemarks.ValidTo >= GETDATE())
GO
  
grant select on vEmployeeReceptionRemarks to public 

go