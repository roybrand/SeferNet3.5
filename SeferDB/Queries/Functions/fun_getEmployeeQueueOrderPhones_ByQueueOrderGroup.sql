IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup
	END
GO

CREATE FUNCTION [dbo].[fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup] (@DeptEmployeeID int, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strPhones varchar(1000) SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones phones
	INNER JOIN EmployeeServiceQueueOrderMethod method ON phones.EmployeeServiceQueueOrderMethodID = method.EmployeeServiceQueueOrderMethodID
	INNER JOIN x_dept_employee_service xdes ON method.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID 
	WHERE xdes.DeptEmployeeID  = @DeptEmployeeID	
	AND xdes.serviceCode = @ServiceCode


	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = '' 
		END

	RETURN( @strPhones )

END
GO

grant exec on fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup to public 
go 