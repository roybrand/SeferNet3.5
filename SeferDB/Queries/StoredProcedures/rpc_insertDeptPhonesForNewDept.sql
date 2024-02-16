IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptPhonesForNewDept')
	BEGIN
		DROP  Procedure  rpc_insertDeptPhonesForNewDept
	END

GO

CREATE Procedure [dbo].[rpc_insertDeptPhonesForNewDept]
	(
		@DeptCode int,
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS

DECLARE @ItHasPhone1 int
DECLARE @ItHasPhone2 int
SET @ErrCode = 0

SET @ItHasPhone1 = IsNull((SELECT Nphone1
FROM InterfaceFromSimulNewDepts
WHERE SimulDeptId = @DeptCode), 0)

SET @ItHasPhone2 = IsNull((SELECT Nphone2
FROM InterfaceFromSimulNewDepts
WHERE SimulDeptId = @DeptCode), 0)
	
IF (@ItHasPhone1 <> 0)
	BEGIN
		INSERT INTO DeptPhones
		( deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, updateUser )
		SELECT
		SimulDeptId, 1, 1, preprefix1, DIC_PhonePrefix.prefixCode, Nphone1, @UpdateUser
		FROM InterfaceFromSimulNewDepts
		INNER JOIN DIC_PhonePrefix ON CAST(InterfaceFromSimulNewDepts.prefix1 as varchar(50)) = DIC_PhonePrefix.prefixValue
		WHERE SimulDeptId = @DeptCode
		
		SET @ErrCode = @@Error
	END
	
IF (@ItHasPhone2 <> 0)
	BEGIN
		INSERT INTO DeptPhones
		( deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, updateUser )
		SELECT
		SimulDeptId, 1, 2, preprefix2, DIC_PhonePrefix.prefixCode, Nphone2, @UpdateUser
		FROM InterfaceFromSimulNewDepts
		INNER JOIN DIC_PhonePrefix ON CAST(InterfaceFromSimulNewDepts.prefix2 as varchar(50)) = DIC_PhonePrefix.prefixValue
		WHERE SimulDeptId = @DeptCode
		
		SET @ErrCode = @@Error
	END
		
GO

GRANT EXEC ON rpc_insertDeptPhonesForNewDept TO PUBLIC

GO

