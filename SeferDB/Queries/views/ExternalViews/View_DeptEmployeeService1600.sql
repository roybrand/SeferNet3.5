/*

View for internal system - view not in use in SeferNet!
Do not change without Maria's permition!!!


מערכת מר"ע (רופאים עצמאיים) צריכה לקבל אינפורמציה באופן 
שוטף לגבי רופאים שנותנים שירות 1600 – רפואת ילדים בערב
יש להחזיר להם את הנתונים הבאים:
קוד סימול ישן, קוד סימול חדש, רישיון רופא
*/
/****** Object:  View [dbo].[View_DeptEmployeeService1600]    Script Date: 02/07/2011 15:35:01 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployeeService1600]'))
DROP VIEW [dbo].[View_DeptEmployeeService1600]
GO

/****** Object:  View [dbo].[View_DeptEmployeeService1600]    Script Date: 02/07/2011 15:35:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[View_DeptEmployeeService1600]
AS
SELECT     xd.deptCode, dbo.deptSimul.Simul228, dbo.Dept.districtCode, dbo.Employee.licenseNumber
FROM         dbo.x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN dbo.Employee ON xd.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.deptSimul ON dbo.deptSimul.deptCode = xd.deptCode 
AND dbo.deptSimul.openDateSimul <= GETDATE() 
AND (dbo.deptSimul.closingDateSimul > GETDATE() OR dbo.deptSimul.closingDateSimul IS NULL) 
INNER JOIN dbo.Dept ON dbo.deptSimul.deptCode = dbo.Dept.deptCode
WHERE     (xdes.serviceCode = 1600)


GO