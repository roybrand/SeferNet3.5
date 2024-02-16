IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeReceptionProfessions_Attributed')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeReceptionProfessions_Attributed
	END

GO

CREATE Procedure rpc_getDeptEmployeeReceptionProfessions_Attributed
	(
		@receptionID int
	)

AS

SELECT
receptionID,
deptEmployeeReceptionProfessions.professionCode,
deptEmployeeReceptionProfessions.subProfessionCode,
deptEmployeeReceptionProfessions.professionServiceCode,
professionDescription,
subProfessionDescription,
professionServiceDescription

FROM deptEmployeeReceptionProfessions
INNER JOIN professions ON deptEmployeeReceptionProfessions.professionCode = professions.professionCode
INNER JOIN subProfessions ON deptEmployeeReceptionProfessions.professionCode = subProfessions.professionCode
	AND deptEmployeeReceptionProfessions.subProfessionCode = subProfessions.subProfessionCode
INNER JOIN professionServices ON deptEmployeeReceptionProfessions.professionCode = professionServices.professionCode
	AND deptEmployeeReceptionProfessions.professionServiceCode = professionServices.professionServiceCode
WHERE receptionID = @receptionID

GO

GRANT EXEC ON rpc_getDeptEmployeeReceptionProfessions_Attributed TO PUBLIC

GO

