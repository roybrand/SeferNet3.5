IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_LogChange')
    BEGIN
	    DROP  Procedure  rpc_Insert_LogChange
    END
GO

Create Procedure dbo.rpc_Insert_LogChange
(
	@ChangeTypeID int,
	@UpdateUser varchar(50),
	@DeptCode int,
	@EmployeeID bigint,	
	@DeptEmployeeID int,
	@deptEmployeeServicesID int,
	@RemarkID int,
	@ServiceCode int,
	@Value varchar(500)
)

AS

IF(@RemarkID is not null)
BEGIN
	SET @Value  = dbo.rfn_GetFotmatedRemark(@Value)
END
/* @DeptEmployeeID = -1 means it to be calculated via @DeptCode & @EmployeeID */
/* @DeptEmployeeID = -1 & @DeptCode = -1 means ALL DeptCodes and DeptEmployeeID it to be calculated via @EmployeeID */


IF(@DeptCode != -1)
	BEGIN
		IF(@DeptEmployeeID = -1 AND @EmployeeID is not null)
			BEGIN
				SET @DeptEmployeeID = ( SELECT TOP 1 DeptEmployeeID FROM x_Dept_Employee 
										WHERE x_Dept_Employee.deptCode = @DeptCode
										AND x_Dept_Employee.employeeID = @EmployeeID )
			END

		INSERT INTO LogChange 
		(ChangeTypeID, UpdateDate, UpdateUser, DeptCode, DeptEmployeeID, deptEmployeeServiceID, RemarkID, ServiceCode, Value)
		VALUES 
		(@ChangeTypeID, getdate(), @UpdateUser, @DeptCode, @DeptEmployeeID, @deptEmployeeServicesID, @RemarkID, @ServiceCode, @Value)
	END
	
IF(@DeptCode = -1)
	BEGIN
	
		INSERT INTO LogChange 
		(ChangeTypeID, UpdateDate, UpdateUser, DeptCode, DeptEmployeeID, deptEmployeeServiceID, RemarkID, ServiceCode, Value)
		SELECT 
		@ChangeTypeID, getdate(), @UpdateUser, T.deptCode, T.DeptEmployeeID, @deptEmployeeServicesID, @RemarkID, @ServiceCode, @Value
		FROM 
		(SELECT DISTINCT deptCode, DeptEmployeeID FROM x_Dept_Employee WHERE EmployeeID = @EmployeeID) as T
	
	END

GO

GRANT EXEC ON [dbo].rpc_Insert_LogChange TO [clalit\webuser]
GO

GRANT EXEC ON [dbo].rpc_Insert_LogChange TO [clalit\IntranetDev]
GO
