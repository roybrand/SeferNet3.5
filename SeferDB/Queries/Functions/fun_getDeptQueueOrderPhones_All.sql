IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getDeptQueueOrderPhones_All')
	BEGIN
		DROP  function  fun_getDeptQueueOrderPhones_All
	END
GO

CREATE FUNCTION [dbo].fun_getDeptQueueOrderPhones_All(@DeptCode int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int
	SET @ThereIsQueueOrderViaClinicPhone = 0

	DECLARE @strPhones varchar(1000)
	SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM DeptQueueOrderPhones
	INNER JOIN DeptQueueOrderMethod ON DeptQueueOrderPhones.QueueOrderMethodID = DeptQueueOrderMethod.QueueOrderMethodID
	WHERE DeptQueueOrderMethod.deptCode  = @DeptCode
	
SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM DeptQueueOrderMethod
	INNER JOIN DIC_QueueOrderMethod ON DeptQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE deptCode = @DeptCode
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

grant exec on fun_getDeptQueueOrderPhones_All to public 
GO    

 