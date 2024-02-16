IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptNameForNewDept')
	BEGIN
		DROP  Procedure  rpc_insertDeptNameForNewDept
	END

GO

CREATE Procedure [dbo].[rpc_insertDeptNameForNewDept]
(
	@DeptCode int,
	@UpdateUser varchar(50),
	@ErrorCode int = 0 output
)

AS

SET @ErrorCode = 0

INSERT INTO DeptNames
(deptCode, deptName, deptNameFreePart, fromDate, updateDate, updateUser)
SELECT
SimulDeptId, SimulDeptName + ' - ' + UT.UnitTypeName + ' - ' + Cities.cityName as deptName,
CASE WHEN (Key_typUnit = 112 OR Key_typUnit = 101) THEN '' ELSE SimulDeptName END as deptNameFreePart,  
getdate(), getdate(), @UpdateUser
FROM InterfaceFromSimulNewDepts IFS
LEFT JOIN Cities ON IFS.City = Cities.cityCode
LEFT JOIN UnitType UT ON IFS.Key_typUnit = UT.UnitTypeCode
WHERE SimulDeptId = @DeptCode

SET @ErrorCode = @@ERROR

GO

GRANT EXEC ON rpc_insertDeptNameForNewDept TO PUBLIC

GO

