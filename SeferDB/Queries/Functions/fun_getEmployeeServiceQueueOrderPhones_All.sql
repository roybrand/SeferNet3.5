IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeServiceQueueOrderPhones_All')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeServiceQueueOrderPhones_All
	END
GO

CREATE FUNCTION [dbo].fun_getEmployeeServiceQueueOrderPhones_All(@EmployeeID bigint, @DeptCode int, @ServiceCode int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int
	SET @ThereIsQueueOrderViaClinicPhone = 0
	
	DECLARE @strPhones varchar(1000)
	SET @strPhones = ''
	
	
	DECLARE @employee_service_id INT
	SELECT @employee_service_id  =	x_dept_employee_serviceID
									FROM x_dept_employee xd 
									INNER JOIN x_dept_employee_service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
									WHERE xd.DeptCode = @deptCode
									AND xd.EmployeeID = @employeeID
									AND xdes.ServiceCode = @serviceCode

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones phones
	INNER JOIN EmployeeServiceQueueOrderMethod method ON phones.EmployeeServiceQueueOrderMethodID = method.EmployeeServiceQueueOrderMethodID
	WHERE method.x_dept_employee_serviceID  = @employee_service_id
	

SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM EmployeeServiceQueueOrderMethod method
	INNER JOIN DIC_QueueOrderMethod ON method.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE method.x_dept_employee_serviceID = @employee_service_id	
	AND ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0)
	
	IF(@ThereIsQueueOrderViaClinicPhone = 1)
	BEGIN
		SELECT TOP 1 @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
		FROM DeptPhones
		WHERE deptCode = @DeptCode 
		AND DeptPhones.phoneType = 1
		ORDER BY phoneOrder
		
	END
	
	
	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END
	RETURN( @strPhones )
	
END
GO 

grant exec on fun_getEmployeeServiceQueueOrderPhones_All to public 
GO