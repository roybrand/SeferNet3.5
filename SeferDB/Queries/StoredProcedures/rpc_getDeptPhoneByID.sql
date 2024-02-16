IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptPhoneByID')
	BEGIN
		DROP  Procedure  rpc_getDeptPhoneByID
	END

GO

CREATE Procedure rpc_getDeptPhoneByID
	(
		@DeptPhoneID int
	)

AS

select DeptPhoneID, deptCode, phoneType, phoneOrder, prePrefix, prefix, phone 
FROM DeptPhones
WHERE DeptPhoneID = @DeptPhoneID

GO

GRANT EXEC ON rpc_getDeptPhoneByID TO PUBLIC

GO

