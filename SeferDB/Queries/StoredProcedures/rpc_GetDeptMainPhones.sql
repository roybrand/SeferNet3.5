IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptMainPhones')
	BEGIN
		DROP  Procedure  rpc_GetDeptMainPhones
	END

GO

CREATE Procedure [dbo].[rpc_GetDeptMainPhones]
(
		@deptCode INT,
		@phoneType INT
)

AS


SELECT  deptCode, DeptPhones.phoneType, phoneOrder, prePrefix, prefixCode, prefixValue as PrefixText, phone, extension
FROM DeptPhones
INNER JOIN DIC_PhonePrefix dic ON DeptPhones.prefix = dic.prefixCode
WHERE deptCode = @DeptCode
AND ( @PhoneType = -1 OR DeptPhones.phoneType = @PhoneType )
--AND PhoneOrder = 1
ORDER BY DeptPhones.phoneType, DeptPhones.PhoneOrder

GO


GRANT EXEC ON rpc_GetDeptMainPhones TO PUBLIC

GO


 