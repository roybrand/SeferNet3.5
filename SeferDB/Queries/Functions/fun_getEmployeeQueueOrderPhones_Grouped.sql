IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeQueueOrderPhones_Grouped')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_Grouped
	END
GO


CREATE FUNCTION [dbo].fun_getEmployeeQueueOrderPhones_Grouped(@DeptEmployeeID int, @DeptCode int, @EmployeeServiceQueueOrderGroup varchar(50))
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int SET @ThereIsQueueOrderViaClinicPhone = 0
	DECLARE @strPhones varchar(1000) SET @strPhones = ''
	DECLARE @PhoneTable as Table
	(
		Phone varchar(20),
		ShowPhonePicture int,
		SpecialPhoneNumberRequired int
	)
	
	INSERT INTO @PhoneTable
	SELECT 
	'Phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),-- + '<br>'
	ShowPhonePicture, SpecialPhoneNumberRequired
	FROM EmployeeServiceQueueOrderMethod ESQOM
	JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	LEFT JOIN EmployeeServiceQueueOrderPhones ON ESQOM.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderPhones.EmployeeServiceQueueOrderMethodID
	JOIN x_Dept_Employee_Service x_DES ON ESQOM.x_dept_employee_serviceID = x_DES.x_dept_employee_serviceID
	JOIN x_dept_employee x_DE ON x_DES.DeptEmployeeID = x_DE.DeptemployeeID
	WHERE x_DE.DeptEmployeeID = @DeptEmployeeID	
	AND dbo.fun_GetEmployeeServiceQueueOrderGroup(x_DE.DeptEmployeeID, x_DES.serviceCode ) = @EmployeeServiceQueueOrderGroup
	
	UNION
	
	SELECT 'Phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),-- + '<br>'
	ShowPhonePicture, SpecialPhoneNumberRequired	
	FROM EmployeeQueueOrderMethod
	JOIN DIC_QueueOrderMethod ON EmployeeQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	LEFT JOIN DeptEmployeeQueueOrderPhones ON EmployeeQueueOrderMethod.QueueOrderMethodID = DeptEmployeeQueueOrderPhones.QueueOrderMethodID
	INNER JOIN x_dept_employee x_DE ON EmployeeQueueOrderMethod.DeptEmployeeID = x_DE.DeptemployeeID
	WHERE x_DE.DeptEmployeeID  = @DeptEmployeeID
	AND dbo.fun_GetEmployeeServiceQueueOrderGroup(x_DE.DeptEmployeeID, 0 ) = @EmployeeServiceQueueOrderGroup

	SELECT @strPhones = @strPhones + CASE WHEN Phone = '' THEN '' ELSE Phone + '<br>' END
	FROM @PhoneTable
		
	SET @ThereIsQueueOrderViaClinicPhone = 
		(SELECT Count(*)
		FROM @PhoneTable
		WHERE ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0
		)
	
	IF(@ThereIsQueueOrderViaClinicPhone > 0)
	BEGIN
		SELECT TOP 1 @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
		FROM DeptPhones
		WHERE deptCode = @DeptCode AND DeptPhones.phoneType = 1
		ORDER BY phoneOrder
		
	END
	
	
	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END
	RETURN( @strPhones )
	
END
GO 

grant exec on fun_getEmployeeQueueOrderPhones_Grouped to public 
GO
