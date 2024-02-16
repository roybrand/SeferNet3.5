IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeePhones')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeePhones
	END

GO

CREATE Procedure [dbo].[rpc_getDeptEmployeePhones]
	(
		@deptEmployeeID int
	)

AS


DECLARE @deptPhone BIT

SELECT @deptPhone = CascadeUpdateDeptEmployeePhonesFromClinic 
FROM x_Dept_Employee
WHERE DeptEmployeeID = @deptEmployeeID

IF @deptPhone = 0

	SELECT 1 AS PhoneID,  dep.phoneType, phoneOrder,prePrefix, prefixCode, dic.prefixValue as prefixText,  
																									phone, extension, 0 as 'IsOriginalDeptPhone'
	FROM DeptEmployeePhones dep
	INNER JOIN DIC_PhoneTypes phoneTypes ON dep.phoneType = phoneTypes.phoneTypeCode
	LEFT JOIN DIC_PhonePrefix dic ON dep.prefix = dic.prefixCode
	WHERE DeptEmployeeID = @deptEmployeeID	
	ORDER BY dep.phoneType, phoneOrder

ELSE

	SELECT 1 AS PhoneID, DeptPhones.phoneType,phoneOrder,prePrefix, prefixCode, dic.prefixValue as prefixText,
																									 phone, extension, 1 as 'IsOriginalDeptPhone'
	FROM DeptPhones
	INNER JOIN x_dept_employee xd ON DeptPhones.DeptCode = xd.DeptCode
	INNER JOIN DIC_PhonePrefix dic ON DeptPhones.prefix = dic.prefixCode
	--WHERE phoneOrder = 1 AND @deptEmployeeID = xd.DeptEmployeeID
	WHERE @deptEmployeeID = xd.DeptEmployeeID
	ORDER BY DeptPhones.phoneType, DeptPhones.phoneOrder

GO

GRANT EXEC ON rpc_getDeptEmployeePhones TO PUBLIC

GO

