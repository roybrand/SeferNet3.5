IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeesDeadOrDeletedOnMF')
	BEGIN
		DROP  Procedure  rpc_GetEmployeesDeadOrDeletedOnMF
	END

GO

CREATE Procedure dbo.rpc_GetEmployeesDeadOrDeletedOnMF

AS

SELECT E.employeeID as 'קוד עובד', E.licenseNumber as 'מספר רשיון', E.lastName as 'שם משפחה', E.firstName as 'שם פרטי', TR226.DeadDate as 'תאריך מוות', TR226.DelFlag as 'מבוטל'
FROM employee E
INNER JOIN TR_DoctorsInfo226 TR226 ON E.employeeID = CAST( (CAST(TR226.PersonID as varchar(10)) + CAST(TR226.IDControlDigit as varchar(1)) ) as bigint)
WHERE (TR226.DeadDate is NOT null AND E.DeathDate is null)
OR (TR226.DelFlag = 1 AND TR226.DelFlag <> E.DelFlagIn226)
GO

GRANT EXEC ON rpc_GetEmployeesDeadOrDeletedOnMF TO PUBLIC

GO

