IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertSynonymToService')
    BEGIN
	    DROP  Procedure  rpc_InsertSynonymToService
    END

GO

CREATE Procedure dbo.rpc_InsertSynonymToService
(	
	@servicesCodes varchar(500),
	@synonym VARCHAR(100),
	@userName VARCHAR(50)
)

AS

declare @tmpTable table
(
	rowID int identity,
	serviceCode int
)

insert into @tmpTable SELECT IntField FROM dbo.SplitString( @servicesCodes )
declare @sumOfServices int = (SELECT count(rowID) FROM @tmpTable)
declare @i int = 1
declare @tmpServiceCode int
while @i <= @sumOfServices
begin
	set @tmpServiceCode = (select serviceCode from @tmpTable where rowID = @i)
	
	IF NOT EXISTS 
	(
		SELECT ServiceCode
		FROM ServiceSynonym
		WHERE ServiceCode = @tmpServiceCode
		AND ServiceSynonym = @synonym
	)
	begin
		INSERT INTO ServiceSynonym
		(ServiceCode, ServiceSynonym, UpdateDate, UpdateUser)

		VALUES
		(@tmpServiceCode, @synonym, GETDATE(), @userName)
		set @i = @i + 1
	end
end
                
GO


GRANT EXEC ON rpc_InsertSynonymToService TO PUBLIC

GO            
