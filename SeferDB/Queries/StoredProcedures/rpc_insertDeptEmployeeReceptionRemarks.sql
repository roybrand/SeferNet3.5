IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeeReceptionRemarks')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeeReceptionRemarks
	END

GO

CREATE Procedure dbo.rpc_insertDeptEmployeeReceptionRemarks
	(
		@EmployeeReceptionID int,
		@RemarkText varchar(500),
		@ValidFrom datetime,
		@ValidTo datetime,
		@UpdateUser varchar(50),
		@EnableOverlappingHours int,
		@displayInInternet int,
		@errorCode int = 0 OUTPUT
	)

AS

IF @validFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @ValidFrom = null
	END	

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @ValidTo = null
	END
	
IF  ( (SELECT disableBecauseOfOverlapping FROM deptEmployeeReception WHERE receptionID = @EmployeeReceptionID) = 1
		AND 
		@EnableOverlappingHours = 1
	)
	BEGIN
		UPDATE deptEmployeeReception
		SET disableBecauseOfOverlapping = 0
		WHERE receptionID = @EmployeeReceptionID
		
		INSERT INTO DeptEmployeeReceptionRemarks
		(EmployeeReceptionID, RemarkText, ValidFrom, ValidTo, UpdateDate, UpdateUser, EnableOverlappingHours, displayInInternet)
		VALUES
		(@EmployeeReceptionID, @RemarkText, @ValidFrom, @ValidTo, getdate(), @UpdateUser, @EnableOverlappingHours, @displayInInternet)
		
		SET @errorCode = @@Error
	END	
	

ELSE	
	BEGIN
		INSERT INTO DeptEmployeeReceptionRemarks
		(EmployeeReceptionID, RemarkText, ValidFrom, ValidTo, UpdateDate, UpdateUser, EnableOverlappingHours)
		VALUES
		(@EmployeeReceptionID, @RemarkText, @ValidFrom, @ValidTo, getdate(), @UpdateUser, @EnableOverlappingHours)
		
		SET @errorCode = @@ERROR
	END
GO

GRANT EXEC ON rpc_insertDeptEmployeeReceptionRemarks TO PUBLIC

GO

