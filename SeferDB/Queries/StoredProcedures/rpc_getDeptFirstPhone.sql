IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptFirstPhone')
	BEGIN
		DROP  Procedure  rpc_getDeptFirstPhone
	END

GO

CREATE Procedure rpc_getDeptFirstPhone
	(
		@DeptCode int
	)

AS

SELECT TOP 1
prePrefix,
prefix,
phone,
extension

FROM DeptPhones
WHERE deptCode = @DeptCode
AND phoneType = 1 
ORDER BY phoneOrder

GO

GRANT EXEC ON rpc_getDeptFirstPhone TO PUBLIC

GO

