
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEventParticular')
	BEGIN
		DROP  Procedure  rpc_insertDeptEventParticular
	END

GO

CREATE Procedure dbo.rpc_insertDeptEventParticular
	(
		@DeptEventID int,
		@Date smalldatetime,
		@OpeningHour varchar(5),
		@ClosingHour varchar(5),
		@UpdateUser varchar(50)
	)

AS

BEGIN 
	INSERT INTO DeptEventParticulars
	(DeptEventID, Day, Date, OpeningHour, ClosingHour, UpdateDate, UpdateUser)
	VALUES
	(@DeptEventID, DATEPART(dw, @Date), @Date, @OpeningHour, @ClosingHour, getdate(), @UpdateUser)

END 

GO

GRANT EXEC ON rpc_insertDeptEventParticular TO PUBLIC

GO