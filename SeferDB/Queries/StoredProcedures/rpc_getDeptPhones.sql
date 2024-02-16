IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptPhones')
	BEGIN
		DROP  Procedure  rpc_getDeptPhones
	END

GO

CREATE Procedure rpc_getDeptPhones
	(
		@DeptCode int,
		@PhoneType int
	
	)

AS

SELECT 
DeptPhoneID,
deptCode,
phoneType,
phoneTypeName, 
phoneOrder,
'phone'= dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'MoveUpPicture' = CASE phoneOrder WHEN 1 THEN 0 ELSE 1 END
FROM DeptPhones
INNER JOIN DIC_PhoneTypes ON DeptPhones.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE deptCode = @DeptCode
AND ( @PhoneType = -1 OR phoneType = @PhoneType )
ORDER BY phoneType, phoneOrder

GO

GRANT EXEC ON rpc_getDeptPhones TO PUBLIC

GO

