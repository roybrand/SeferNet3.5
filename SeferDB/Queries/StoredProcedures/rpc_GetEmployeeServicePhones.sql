IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServicePhones
	END
GO

CREATE PROCEDURE [dbo].[rpc_GetEmployeeServicePhones]
	@x_Dept_Employee_ServiceID int, 
	@phoneType int,
	@SimulateCascadeUpdate bit

AS
	DECLARE @GetCascade BIT

	IF(@SimulateCascadeUpdate is null OR @SimulateCascadeUpdate = 0)
		SELECT @GetCascade = ISNULL(CascadeUpdateEmployeeServicePhones, 0) 
		FROM x_Dept_Employee_Service
		WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
	ELSE
		SET @GetCascade = @SimulateCascadeUpdate

	IF @GetCascade = 0
		BEGIN
			SELECT EmployeeServicePhones.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
				0 as 'GetCascade'
			FROM EmployeeServicePhones
			INNER JOIN DIC_PhonePrefix ON EmployeeServicePhones.prefix = DIC_PhonePrefix.prefixCode
			WHERE (@x_Dept_Employee_ServiceID is null OR x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
			AND (@phoneType is null OR EmployeeServicePhones.phoneType = @phoneType)
			ORDER BY phoneOrder
		END
	ELSE
		BEGIN
			SELECT @GetCascade = ISNULL(CascadeUpdateDeptEmployeePhonesFromClinic, 0) 
			FROM x_Dept_Employee xd
			INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID				
			WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

			IF @GetCascade = 0
				BEGIN
					SELECT dep.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
						1 as 'GetCascade'
					FROM DeptEmployeePhones dep
					INNER JOIN DIC_PhoneTypes phoneTypes ON dep.phoneType = phoneTypes.phoneTypeCode
					INNER JOIN DIC_PhonePrefix dic ON dep.prefix = dic.prefixCode
					INNER JOIN x_Dept_Employee_Service xdes ON dep.DeptEmployeeID = xdes.DeptEmployeeID						
					WHERE xdes.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
					AND dep.phoneType <> 2
					ORDER BY dep.phoneType, phoneOrder
				END
			ELSE
				BEGIN
					SELECT dp.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
																													  1 as 'GetCascade'
					FROM DeptPhones dp
					INNER JOIN DIC_PhonePrefix dic ON dp.prefix = dic.prefixCode
					INNER JOIN x_Dept_Employee xd ON dp.deptCode = xd.deptCode
					INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
					WHERE xdes.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
					AND dp.phoneType <> 2
								
				END	
		END
		
		SELECT CASE ISNULL(@SimulateCascadeUpdate, 0) 
			WHEN 0 THEN ISNULL(CascadeUpdateEmployeeServicePhones, 0) ELSE ISNULL(@SimulateCascadeUpdate, 0) END as CascadeUpdateEmployeeServicePhones
		FROM x_Dept_Employee_Service
		WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

GO


GRANT EXEC ON dbo.rpc_GetEmployeeServicePhones TO PUBLIC
GO