IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptEmployeeReceptionProfessions')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEmployeeReceptionProfessions
	END

GO

CREATE Procedure rpc_deleteDeptEmployeeReceptionProfessions
	(
		@DeptEmployeeReceptionProfessionsID int,
		@outputMessage varchar(500) OUTPUT
	)

AS

DECLARE @Count int

SET @outputMessage = ''

SET @Count =
	(SELECT COUNT(receptionID) FROM deptEmployeeReceptionProfessions
	WHERE receptionID = (SELECT receptionID FROM deptEmployeeReceptionProfessions WHERE deptEmployeeReceptionProfessionsID = @DeptEmployeeReceptionProfessionsID))
	
IF(IsNull(@Count, 0) < 2)
BEGIN
	SET @outputMessage = 'אי אפשר למחוק את המקצוע כי זאת המקצוע היחידה לתקופת שעות קבלה האלה'
	RETURN
END

DELETE FROM deptEmployeeReceptionProfessions
WHERE deptEmployeeReceptionProfessionsID = @DeptEmployeeReceptionProfessionsID

GO

GRANT EXEC ON rpc_deleteDeptEmployeeReceptionProfessions TO PUBLIC

GO

