IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeReception')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeReception
	END

GO

CREATE Procedure [dbo].[rpc_InsertEmployeeReception]
(
		@employeeID INT,
		@deptCode  INT,
		@agreementType INT,
		@receptionDay INT,
		@openingHour VARCHAR(5),
		@closingHour VARCHAR(5),
		@receptionRoom VARCHAR(10),
		@receiveGuests bit,
		@validFrom SMALLDATETIME,
		@validTo SMALLDATETIME,
		@itemType VARCHAR(10),
		@itemID  INT,
		@remark  VARCHAR(500),
		@remarkID INT,
		@updateUser VARCHAR(50)
)

AS

DECLARE @ReceptionID  INT
DECLARE @enableOverlappingHours  INT
DECLARE @deptEmployeeID  INT

SET @enableOverlappingHours = 0

SET XACT_ABORT on
BEGIN TRY

	SET @deptEmployeeID =	(SELECT DeptEmployeeID
							 FROM x_dept_employee
							 WHERE DeptCode = @deptCode
							 AND EmployeeID = @employeeID
							 AND ( @agreementType = -1 OR agreementType = @agreementType)
							)

	--EmployeeReception
	INSERT INTO DeptEmployeeReception (ReceptionDay, OpeningHour, ClosingHour, ReceptionRoom, ReceiveGuests,
												ValidFrom, ValidTo, UpdateDate, UpdateUser, disableBecauseOfOverlapping, DeptEmployeeID )
	VALUES( @receptionDay, @openingHour, @closingHour, @receptionRoom, @receiveGuests, @validFrom, @validTo, GetDate(), @updateUser, 0, @deptEmployeeID)

	SET @ReceptionID = @@IDENTITY

	IF (@remarkID > 0)
	BEGIN
		SELECT @enableOverlappingHours = EnableOverlappingHours
										 FROM DIC_GeneralRemarks
										 WHERE RemarkID = @remarkID
		-- Remarks
		INSERT INTO DeptEmployeeReceptionRemarks(EmployeeReceptionID, RemarkText, RemarkId,  ValidFrom, 
												ValidTo, UpdateDate, UpdateUser, EnableOverlappingHours, DisplayInInternet)
		VALUES( @ReceptionID, @remark, @remarkID, @validFrom, @validTo, GetDate(), @updateUser, @enableOverlappingHours, 1 )									 
	END								 

	INSERT INTO	deptEmployeeReceptionServices
	(receptionID, serviceCode, updateUser, updateDate)
	VALUES(@ReceptionID, @itemID, @updateUser, getdate())

	-- INSERT INTO deptEmployeeReception_Regular
	DECLARE @OpH time = CAST(@openingHour as time)
	DECLARE @ClH time = CAST(@closingHour as time)
	DECLARE @NewReceptionID AS int = @ReceptionID

	BEGIN
	IF(@OpH < @ClH)
		BEGIN
			--print '@OpH < @ClH'		
			INSERT INTO deptEmployeeReception_Regular
			(
				receptionDay,
				openingHour,
				closingHour,
				ReceptionRoom,
				ReceiveGuests, 
				ValidFrom,
				ValidTo,
				UpdateDate,
				UpdateUser,
				disableBecauseOfOverlapping, 
				DeptEmployeeID,
				DeptEmployeeReceptionID
			)
			VALUES
			(
				@receptionDay,
				@openingHour,
				@closingHour,
				@receptionRoom,
				@receiveGuests,
				@validFrom,
				@validTo,		
				getdate(),
				@UpdateUser,
				0,
				@deptEmployeeID,
				@NewReceptionID
			)	
		END
			--print '@OpH > @ClH'
	IF(@OpH >= @ClH)
		BEGIN			
		
			INSERT INTO deptEmployeeReception_Regular
			(
				receptionDay,
				openingHour,
				closingHour,
				ReceptionRoom,
				ReceiveGuests,  
				ValidFrom,
				ValidTo,
				UpdateDate,
				UpdateUser,
				disableBecauseOfOverlapping, 
				DeptEmployeeID,
				DeptEmployeeReceptionID
			)
			VALUES
			(
				@receptionDay,
				@openingHour,
				 '23:59',--closingHour
				@receptionRoom,
				@receiveGuests,
				@validFrom,
				@validTo,		
				getdate(),
				@UpdateUser,
				0,
				@deptEmployeeID,
				@NewReceptionID
			)
			
			IF(@closingHour <> '00:00' AND @receptionDay < 8)
				BEGIN
					INSERT INTO deptEmployeeReception_Regular
					(
						receptionDay,
						openingHour,
						closingHour,
						ReceptionRoom,
						ReceiveGuests,						 
						ValidFrom,
						ValidTo,
						UpdateDate,
						UpdateUser,
						disableBecauseOfOverlapping, 
						DeptEmployeeID,
						DeptEmployeeReceptionID
					)
					VALUES
					(
						CASE WHEN @receptionDay < 7 THEN @receptionDay + 1 ELSE 1 END,
						'00:00',
						@closingHour,
						@receptionRoom,
						@receiveGuests,
						@validFrom,
						@validTo,		
						getdate(),
						@UpdateUser,
						0,
						@deptEmployeeID,
						@NewReceptionID
					)				
				END				
		END

	END	

END TRY
BEGIN CATCH
	Exec master.dbo.sp_RethrowError
END CATCH	

GO

GRANT EXEC ON rpc_InsertEmployeeReception TO [clalit\webuser]
GO

GRANT EXEC ON rpc_InsertEmployeeReception TO [clalit\IntranetDev]
GO


