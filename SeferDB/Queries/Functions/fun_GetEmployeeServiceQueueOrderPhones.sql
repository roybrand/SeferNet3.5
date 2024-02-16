IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderPhones')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderPhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderPhones] (@DeptEmployeeID int, @ServiceCode int)
RETURNS VARCHAR(100)
WITH EXECUTE AS CALLER
AS
BEGIN

	DECLARE @phones VARCHAR(100)  SET @phones = ''
	DECLARE @phones1 VARCHAR(100) SET @phones1 = ''	
	DECLARE @ServiceQueueOrder int

	SELECT @ServiceQueueOrder = QueueOrder 
	FROM x_Dept_Employee_Service x_DES
	WHERE x_DES.DeptEmployeeID = @DeptEmployeeID AND x_DES.serviceCode = @ServiceCode

	IF(@ServiceQueueOrder is not null)
	-- Get phones for SERVICE queue order		
		BEGIN

			-- employee service queue order phone
			SELECT @phones = CASE WHEN esqop.PhoneType IS NOT NULL THEN 
										dbo.fun_ParsePhoneNumberWithExtension(esqop.PrePrefix, esqop.Prefix, esqop.Phone, esqop.Extension)				  
								  ELSE 
										dbo.fun_ParsePhoneNumberWithExtension(dp.PrePrefix, dp.Prefix, dp.Phone, dp.Extension)				  
							 END
			FROM x_dept_employee_service xdes
			LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
			LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_dept_employee_ServiceID = esqom.x_dept_employee_ServiceID
			LEFT JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID
			LEFT JOIN dic_queueOrderMethod dic ON esqom.QueueOrderMethod = dic.QueueOrderMethod
			LEFT JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
			WHERE xdes.DeptEmployeeID = @DeptEmployeeID
			AND xdes.serviceCode = @ServiceCode
			AND dic.ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 1
			AND dp.PhoneType = 1 
			AND dp.PhoneOrder = 1

			-- Clinic phone
			SELECT @phones1 = CASE WHEN dp.PhoneType IS NOT NULL THEN	
										dbo.fun_ParsePhoneNumberWithExtension(dp.PrePrefix, dp.Prefix, dp.Phone, dp.Extension)
										ELSE ''
								END
			FROM x_dept_employee_service xdes
			INNER JOIN x_dept_employee xd on xdes.DeptEmployeeID = xd.DeptEmployeeID
			INNER JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_dept_employee_ServiceID = esqom.x_dept_employee_ServiceID
			INNER JOIN dic_queueOrderMethod dic ON esqom.QueueOrderMethod = dic.QueueOrderMethod
			INNER JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
			WHERE xdes.DeptEmployeeID = @DeptEmployeeID
			AND xdes.serviceCode = @ServiceCode
			AND dic.ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0
			AND dp.PhoneType = 1 
			AND dp.PhoneOrder = 1

			IF (@phones <> '' AND @phones1 <> '')
				SET @phones	= @phones + '<br>' + @phones1
			ELSE 
				SET @phones = @phones + @phones1
	
		END
	ELSE
		-- Get phones for EMPLOYEE queue order		
		BEGIN

			-- employee queue order phone
			SELECT @phones = CASE WHEN dEQOP.PhoneType IS NOT NULL THEN	
										dbo.fun_ParsePhoneNumberWithExtension(dEQOP.PrePrefix, dEQOP.Prefix, dEQOP.Phone, dEQOP.Extension)
										ELSE ''
								END
			FROM x_dept_employee_service xdes
			INNER JOIN x_dept_employee xd on xdes.DeptEmployeeID = xd.DeptEmployeeID
			INNER JOIN EmployeeQueueOrderMethod eqom ON xdes.DeptEmployeeID = eqom.DeptEmployeeID
			INNER JOIN dic_queueOrderMethod dic ON eqom.QueueOrderMethod = dic.QueueOrderMethod
			INNER JOIN DeptEmployeeQueueOrderPhones dEQOP ON eqom.QueueOrderMethodID = dEQOP.QueueOrderMethodID
			WHERE xdes.DeptEmployeeID = @DeptEmployeeID
			AND xdes.serviceCode = @ServiceCode
			AND dic.ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 1
			AND dEQOP.PhoneType = 1 
			AND dEQOP.PhoneOrder = 1

			-- Clinic phone
			SELECT @phones1 = CASE WHEN dp.PhoneType IS NOT NULL THEN	
										dbo.fun_ParsePhoneNumberWithExtension(dp.PrePrefix, dp.Prefix, dp.Phone, dp.Extension)
										ELSE ''
								END
			FROM x_dept_employee_service xdes
			INNER JOIN x_dept_employee xd on xdes.DeptEmployeeID = xd.DeptEmployeeID
			INNER JOIN EmployeeQueueOrderMethod eqom ON xdes.DeptEmployeeID = eqom.DeptEmployeeID
			INNER JOIN dic_queueOrderMethod dic ON eqom.QueueOrderMethod = dic.QueueOrderMethod
			INNER JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
			WHERE xdes.DeptEmployeeID = @DeptEmployeeID
			AND xdes.serviceCode = @ServiceCode
			AND dic.ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0
			AND dp.PhoneType = 1 
			AND dp.PhoneOrder = 1

			IF (@phones <> '' AND @phones1 <> '')
				SET @phones	= @phones + '<br>' + @phones1
			ELSE 
				SET @phones = @phones + @phones1

		END

	RETURN @phones	


END

GO

grant exec on fun_GetEmployeeServiceQueueOrderPhones to public 
go 
