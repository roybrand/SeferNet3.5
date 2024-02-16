IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMainDeptPhoneByDeptEmployeeID')
	BEGIN
		DROP  Procedure  rpc_GetMainDeptPhoneByDeptEmployeeID
	END
GO

CREATE Procedure dbo.rpc_GetMainDeptPhoneByDeptEmployeeID
(
		@DeptEmployeeID INT,
		@phoneNumber VARCHAR(30) OUTPUT
)

AS

SET @phoneNumber = ''

SELECT TOP 1 @phoneNumber = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
FROM DeptPhones
JOIN x_Dept_Employee ON x_Dept_Employee.deptCode = DeptPhones.deptCode
WHERE x_Dept_Employee.DeptEmployeeID = @DeptEmployeeID 
ORDER BY PhoneOrder

GO


GRANT EXEC ON rpc_GetMainDeptPhoneByDeptEmployeeID TO PUBLIC

GO
