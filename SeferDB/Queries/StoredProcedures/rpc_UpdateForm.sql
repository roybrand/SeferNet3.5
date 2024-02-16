IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateForm')
	BEGIN
		DROP  Procedure  rpc_UpdateForm
	END

GO

CREATE Procedure dbo.rpc_UpdateForm
(
	@FormID int,
	@FileName varchar(50),
	@FormDisplayName varchar(100)
	
)	
AS
	update Forms 
	set FileName = @FileName,
	FormDisplayName = @FormDisplayName
	where FormID = @FormID

GO

GRANT EXEC ON rpc_UpdateForm TO PUBLIC

GO