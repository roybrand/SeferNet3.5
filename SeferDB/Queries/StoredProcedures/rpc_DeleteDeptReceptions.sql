IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptReceptions')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptReceptions
	END

GO

CREATE Procedure [dbo].[rpc_DeleteDeptReceptions]

	(
			@deptCode int,
			@receptionHoursTypeID tinyint	
	)
AS

SET XACT_ABORT on
BEGIN TRY

	BEGIN 
		DELETE FROM DeptReception
		WHERE DeptCode = @deptCode	
			and ReceptionHoursTypeID = @receptionHoursTypeID
			
		DELETE FROM DeptReception_Regular
		WHERE DeptCode = @deptCode	
			and ReceptionHoursTypeID = @receptionHoursTypeID					
	END 
END TRY
BEGIN CATCH
	Exec master.dbo.sp_RethrowError
END CATCH		
GO

GRANT EXEC ON rpc_DeleteDeptReceptions TO PUBLIC

GO
