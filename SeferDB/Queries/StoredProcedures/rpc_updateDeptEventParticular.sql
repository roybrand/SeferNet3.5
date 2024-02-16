IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptEventParticular')
	BEGIN
		DROP  Procedure  rpc_updateDeptEventParticular
	END

GO

CREATE PROCEDURE dbo.rpc_updateDeptEventParticular
	(
		@DeptEventParticularsID int,
		@Date smalldatetime,
		@OpeningHour varchar(5),
		@Duration varchar(50),
		@UpdateUser varchar(50),
		@RepeatingEvent int,
		@DeptEventID int,
		@ErrCode int OUTPUT
	)

AS

DECLARE @weekday varchar(1)
----
DECLARE @Count int
DECLARE @OrderNumber int

SET @weekday = (SELECT CASE DATEPART(dw, @Date) WHEN 1 THEN 'à' 
	WHEN 2 THEN 'á'WHEN 3 THEN 'â'WHEN 4 THEN 'ã'WHEN 5 THEN 'ä' WHEN 6 THEN 'å' WHEN 7 THEN 'ù' END)

IF (@RepeatingEvent = 0)
	BEGIN
	
			UPDATE DeptEventParticulars
			--SET Day = @weekday, 
			SET Day = DATEPART(dw, @Date), 
				Date = @Date, 
				OpeningHour = @OpeningHour,
				Duration = @Duration,
				UpdateDate = getdate(),
				UpdateUser = @UpdateUser
			WHERE DeptEventParticularsID = @DeptEventParticularsID
				
			SET @ErrCode = @@Error
	END
-- the next case is a repiating event
-- we update all the rows, starting from the first and making increment of 7 days for the date 
IF (@RepeatingEvent = 1)  
	BEGIN
			SET @Count = (SELECT COUNT(DeptEventParticularsID) FROM DeptEventParticulars WHERE DeptEventID = @DeptEventID)
			SET @OrderNumber = 1
			
			WHILE (@Count > 0)
				BEGIN
					UPDATE DeptEventParticulars
					SET Day = @weekday, 
						Date = @Date, 
						OpeningHour = @OpeningHour,
						Duration = @Duration,
						UpdateDate = getdate(),
						UpdateUser = @UpdateUser
					WHERE DeptEventID = @DeptEventID
					  AND OrderNumber = @OrderNumber
				
					SET @Date = DATEADD (dd , 7, @Date )
					SET @Count = @Count - 1
					SET @OrderNumber = @OrderNumber + 1
				END
				
			SET @ErrCode = @@Error
	END
GO

GRANT EXEC ON rpc_updateDeptEventParticular TO PUBLIC

GO

