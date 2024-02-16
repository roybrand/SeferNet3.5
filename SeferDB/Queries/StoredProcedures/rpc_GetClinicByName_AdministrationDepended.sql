IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClinicByName_AdministrationDepended')
	BEGIN
		DROP  Procedure  rpc_GetClinicByName_AdministrationDepended
	END

GO

CREATE Procedure [dbo].[rpc_GetClinicByName_AdministrationDepended]
(
	@searchText VARCHAR(30),
	@administrationCode INT
)

AS

SELECT DeptCode, CAST(DeptCode as varchar(10)) + ' - ' + DeptName  as DeptName 
FROM Dept
WHERE (deptName like '%'+ @searchText+'%' OR CAST(dept.deptCode as varchar(10)) like '%'+ @searchText+'%')
AND DeptType = 3
AND (AdministrationCode = @administrationCode OR @administrationCode = -1)

GO


GRANT EXEC ON dbo.rpc_GetClinicByName_AdministrationDepended TO PUBLIC

GO


