IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptReceptions')
	BEGIN
		DROP  Procedure  rpc_insertDeptReceptions
	END

GO

CREATE Procedure [dbo].[rpc_insertDeptReceptions]
(
		@deptCode int,
		@receptionDay int,
		@openingHour varchar(5),
		@closingHour varchar(5),
		@validFrom datetime,
		@validTo datetime,
		@RemarkID int,
		@RemarkText varchar(500),
		@updateUserName varchar(50),
		@receptionHoursTypeID tinyint
)

AS

DECLARE @NewReceptionID AS int

SET XACT_ABORT on
BEGIN TRY

	BEGIN


		INSERT INTO DeptReception
		(
			DeptCode,
			receptionDay,
			openingHour,
			closingHour , 
			ValidFrom,
			ValidTo,
			UpdateDate,
			UpdateUserName,
			ReceptionHoursTypeID
		)
		VALUES
		(
			@DeptCode,
			@receptionDay,
			@openingHour,@closingHour,
			@validFrom,
			@validTo,		
			getdate(),
			@UpdateUserName,
			@receptionHoursTypeID
		)
	print 'IDENT_CURRENT : - '
	print IDENT_CURRENT('DeptReception')

	set @NewReceptionID =  IDENT_CURRENT('DeptReception')

	print '@NewReceptionID'
	print @NewReceptionID

	-- INSERT INTO DeptReception_Regular
	DECLARE @OpH time = CAST(@openingHour as time)
	DECLARE @ClH time = CAST(@closingHour as time)

		BEGIN
		IF(@OpH < @ClH)
			BEGIN
				--print '@OpH < @ClH'		
				INSERT INTO DeptReception_Regular
				(
					DeptCode,
					receptionDay,
					openingHour,
					closingHour, 
					ValidFrom,
					ValidTo,
					UpdateDate,
					UpdateUserName,
					ReceptionHoursTypeID,
					DeptReceptionID
				)
				VALUES
				(
					@DeptCode,
					@receptionDay,
					@openingHour,
					@closingHour,
					@validFrom,
					@validTo,		
					getdate(),
					@UpdateUserName,
					@receptionHoursTypeID,
					@NewReceptionID
				)	
			END
				--print '@OpH > @ClH'
		IF(@OpH >= @ClH)
				BEGIN			
				
					INSERT INTO DeptReception_Regular
					(
						DeptCode,
						receptionDay,
						openingHour,
						closingHour, 
						ValidFrom,
						ValidTo,
						UpdateDate,
						UpdateUserName,
						ReceptionHoursTypeID,
						DeptReceptionID
					)
					VALUES
					(
						@DeptCode,
						@receptionDay,
						@openingHour,
						 '23:59',--closingHour
						@validFrom,
						@validTo,		
						getdate(),
						@UpdateUserName,
						@receptionHoursTypeID,
						@NewReceptionID
					)
					
					IF(@closingHour <> '00:00' AND @receptionDay < 8)
						BEGIN
							INSERT INTO DeptReception_Regular
							(
								DeptCode,
								receptionDay,
								openingHour,
								closingHour, 
								ValidFrom,
								ValidTo,
								UpdateDate,
								UpdateUserName,
								ReceptionHoursTypeID,
								DeptReceptionID
							)
							VALUES
							(
								@DeptCode,
								CASE WHEN @receptionDay < 7 THEN @receptionDay + 1 ELSE 1 END,
								'00:00',
								@closingHour,
								@validFrom,
								@validTo,		
								getdate(),
								@UpdateUserName,
								@receptionHoursTypeID,
								@NewReceptionID
							)				
						END				
				END

			END
		END	

	IF(@RemarkText <> '' and @RemarkID <> -1)
		BEGIN 
		INSERT INTO DeptReceptionRemarks
			(
				ReceptionID, 
				RemarkText, 
				RemarkID, 
				ValidFrom, 
				ValidTo, 
				DisplayInInternet, 
				UpdateDate, 
				UpdateUser
			)
			VALUES
			(
				@NewReceptionID,
				@RemarkText,
				@RemarkID,
				null,
				null,	
				null,	
				getdate(),
				@UpdateUserName
			)
		END

END TRY
BEGIN CATCH
	Exec master.dbo.sp_RethrowError
END CATCH
GO


GRANT EXEC ON rpc_insertDeptReceptions TO PUBLIC

GO
