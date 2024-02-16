IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderGroup')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderGroup
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderGroup] (@DeptEmployeeID int, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ESQOGroup varchar(50) SET @ESQOGroup = ''
	DECLARE @Temp int SET @Temp = 0
	DECLARE @TempStr varchar(50) SET @TempStr = ''
	DECLARE @EmptyGroup varchar(50) SET @EmptyGroup = '00000000000000'
	DECLARE @EmployeeIDPrefix varchar(50) SET @EmployeeIDPrefix = RIGHT('00000000000' + CAST(@DeptEmployeeID as varchar(11)), 11)
	DECLARE @ServicePhone varchar(50) SET @ServicePhone = '00000000000'
			
	IF(@ServiceCode <> 0)
	BEGIN
		SELECT @ESQOGroup = @ESQOGroup + CAST(IsNull(xdes.QueueOrder, 0) as varchar(1))
		FROM x_Dept_Employee_Service xdes 
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode

		IF( @ESQOGroup is null OR @ESQOGroup = '')
			SET @ESQOGroup = '0'
			
		SELECT @Temp = @Temp + (ESQOM.QueueOrderMethod * ESQOM.QueueOrderMethod)
		FROM EmployeeServiceQueueOrderMethod esqom
		INNER JOIN x_dept_employee_service xdes ON esqom.x_dept_employee_serviceID  = xdes.x_dept_employee_serviceID
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode
		
		
		SELECT TOP 1 @TempStr = --@TempStr +
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM EmployeeServiceQueueOrderPhones esqohp
		INNER JOIN DIC_PhonePrefix ON esqohp.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN EmployeeServiceQueueOrderMethod esqom ON esqohp.EmployeeServiceQueueOrderMethodID = esqom.EmployeeServiceQueueOrderMethodID
		INNER JOIN x_dept_employee_service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode

		IF( @TempStr is null OR @TempStr = '')
			SET @TempStr = '00000000000'

		SET @ESQOGroup = @ESQOGroup + RIGHT('00' + CAST(ISNULL(@Temp, 0) as varchar(2)), 2) + 
						ISNULL(@TempStr, '00000000000')

		SELECT TOP 1 @ServicePhone = 
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM EmployeeServicePhones esp
		INNER JOIN DIC_PhonePrefix ON esp.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN x_Dept_Employee_Service xdes ON esp.x_Dept_Employee_ServiceID = xdes.x_Dept_Employee_ServiceID
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode 

		IF( @ServicePhone is null OR @TempStr = '')
			SET @ServicePhone = '00000000000'

	END
	ELSE
	BEGIN
		SET @ESQOGroup = @EmptyGroup
	END
	
	-- if there's no queue order via employee service
	-- try to get queue order via employee
	IF(@ESQOGroup = @EmptyGroup) 
	BEGIN
		SET @ESQOGroup = ''
		SET @Temp = 0
		SET @TempStr = ''	
		
		SELECT @ESQOGroup = @ESQOGroup + CAST(IsNull(x_D_E.QueueOrder, 0) as varchar(1))
		FROM x_Dept_Employee x_D_E 
		WHERE x_D_E.DeptEmployeeID = @DeptEmployeeID
		
		IF( @ESQOGroup is null OR @ESQOGroup = '')
			SET @ESQOGroup = '0'
		
		SELECT @Temp = @Temp + (EQOM.QueueOrderMethod * EQOM.QueueOrderMethod)
		FROM EmployeeQueueOrderMethod eqom
		INNER JOIN x_dept_employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE xd.DeptEmployeeID = @DeptEmployeeID

		SELECT TOP 1 @TempStr = 
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM DeptEmployeeQueueOrderPhones DEQOPh
		INNER JOIN DIC_PhonePrefix ON DEQOPh.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN EmployeeQueueOrderMethod EQOM ON DEQOPh.QueueOrderMethodID = EQOM.QueueOrderMethodID
		INNER JOIN x_dept_employee xd ON EQOM.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE xd.DeptEmployeeID = @DeptEmployeeID

		IF( @TempStr is null OR @TempStr = '')
			SET @TempStr = '00000000000'

		SET @ESQOGroup = @ESQOGroup 
			+ RIGHT('00' + CAST(ISNULL(@Temp, 0) as varchar(2)), 2)
			+ @TempStr
		
	END

	RETURN @EmployeeIDPrefix + @ESQOGroup + @ServicePhone

END
GO

grant exec on fun_GetEmployeeServiceQueueOrderGroup to public 
go 
