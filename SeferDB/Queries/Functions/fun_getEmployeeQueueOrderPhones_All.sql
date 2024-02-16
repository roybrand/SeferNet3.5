IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeQueueOrderPhones_All')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_All
	END
GO

CREATE FUNCTION [dbo].fun_getEmployeeQueueOrderPhones_All(@EmployeeID int, @DeptCode int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int SET @ThereIsQueueOrderViaClinicPhone = 0
	DECLARE @strPhones varchar(1000) SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM DeptEmployeeQueueOrderPhones
	INNER JOIN EmployeeQueueOrderMethod ON DeptEmployeeQueueOrderPhones.QueueOrderMethodID = EmployeeQueueOrderMethod.QueueOrderMethodID
	INNER JOIN x_dept_employee xd ON EmployeeQueueOrderMethod.DeptemployeeID = xd.DeptemployeeID
	WHERE xd.deptCode  = @DeptCode
	AND xd.employeeID = @EmployeeID

SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM EmployeeQueueOrderMethod eqom
	INNER JOIN x_dept_employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID
	INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE deptCode = @DeptCode
	AND employeeID = @EmployeeID
	AND ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0)
	
	IF(@ThereIsQueueOrderViaClinicPhone = 1)
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

grant exec on fun_getEmployeeQueueOrderPhones_All to public 
GO

 