IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getErrorsListSimulVcSefer')
	BEGIN
		DROP  Procedure  rpc_getErrorsListSimulVcSefer
	END

GO

CREATE Procedure rpc_getErrorsListSimulVcSefer
	(
		@ErrorCode int
	)

AS

IF(@ErrorCode = -1)
BEGIN
	SET @ErrorCode = null
END

SELECT
InterfaceErrorCodes.ErrorCode,
InterfaceErrorCodes.ErrorDesc,
'deptCode' = key_dept,
'deptName' = dept_name,
districtName,
InterfaceDate
FROM InterfaceToSimulErrors
INNER JOIN dept ON InterfaceToSimulErrors.key_dept = dept.deptCode
INNER JOIN View_AllDistricts ON dept.districtCode = View_AllDistricts.districtCode
INNER JOIN InterfaceErrorCodes ON InterfaceToSimulErrors.ErrorCode = InterfaceErrorCodes.ErrorCode
WHERE (@ErrorCode is null OR InterfaceToSimulErrors.ErrorCode = @ErrorCode)

GO

GRANT EXEC ON rpc_getErrorsListSimulVcSefer TO PUBLIC

GO

