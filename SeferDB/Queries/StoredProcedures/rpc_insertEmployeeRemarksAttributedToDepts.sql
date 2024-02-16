IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeRemarksAttributedToDepts')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeRemarksAttributedToDepts
	END

GO

CREATE PROCEDURE dbo.rpc_insertEmployeeRemarksAttributedToDepts
	(
		@EmployeeID int,
		@DeptCodes varchar(50),
		@AttributedToAll int,
		@EmployeeRemarkID int,
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

	DECLARE @count int, @currentCount int
	DECLARE @curDeptCode int
	
	Declare @MinDeptCode int
	SET @curDeptCode = 0
	Set @MinDeptCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@DeptCodes))

	IF( @count = 0 AND @AttributedToAll = 0)
	-- It means there are NO attributed to any clinic and all records to be deleted
		BEGIN
			DELETE FROM x_Dept_Employee_EmployeeRemarks WHERE EmployeeRemarkID = @EmployeeRemarkID
		END

	IF( @count > 0 AND @AttributedToAll = 0)
	-- Attribute Remark to clinics with deptCodes in @DeptCodes

			SET @currentCount = @count
			
			
				DELETE FROM x_Dept_Employee_EmployeeRemarks WHERE EmployeeRemarkID = @EmployeeRemarkID
				
				UPDATE EmployeeRemarks SET AttributedToAllClinicsInCommunity = @AttributedToAll
				WHERE EmployeeRemarkID = @EmployeeRemarkID
				
				WHILE (@currentCount > 0)
					BEGIN 
						SET @curDeptCode = (select min(IntField) from dbo.SplitString(@DeptCodes)
												where IntField > @MinDeptCode)
					
						SET @MinDeptCode = @curDeptCode
													   
						INSERT INTO x_Dept_Employee_EmployeeRemarks 
						(EmployeeRemarkID, updateUser, DeptEmployeeID)
						SELECT @EmployeeRemarkID, @UpdateUser, DeptEmployeeID
						FROM x_Dept_Employee
						WHERE deptCode = @curDeptCode
						AND employeeID = @EmployeeID
						
						
						SET @currentCount = @currentCount - 1
					
					END
				
			SET @ErrCode = @@Error
	
	IF(@AttributedToAll = 1)
	-- Attribute Remark to ALL clinics where Employee works
	

			
			DELETE FROM x_Dept_Employee_EmployeeRemarks WHERE EmployeeRemarkID = @EmployeeRemarkID
			
			UPDATE EmployeeRemarks SET AttributedToAllClinicsInCommunity = @AttributedToAll
			WHERE EmployeeRemarkID = @EmployeeRemarkID
			
								
			INSERT INTO x_Dept_Employee_EmployeeRemarks 
			(EmployeeRemarkID, updateUser, DeptEmployeeID)
			SELECT  EmployeeRemarkID, @UpdateUser, DeptEmployeeID
			FROM x_Dept_Employee
			INNER JOIN EmployeeRemarks ON x_Dept_Employee.employeeID = EmployeeRemarks.EmployeeID
			WHERE x_Dept_Employee.employeeID = @EmployeeID
			AND EmployeeRemarkID = @EmployeeRemarkID
			
			SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertEmployeeRemarksAttributedToDepts TO PUBLIC

GO

