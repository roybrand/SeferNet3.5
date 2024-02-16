IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteMushlamToSeferMapping')
    BEGIN
	    DROP  Procedure  rpc_deleteMushlamToSeferMapping
    END

GO

CREATE Procedure dbo.rpc_deleteMushlamToSeferMapping
(
	@id INT,
	@tableCode INT
)

AS
declare @tmpSerCode int
if (@tableCode = 15)
begin
	delete from MushlamTreatmentTypesToSefer
	where ID = @id
end
else 
	if (@tableCode = 18)
	begin
		delete from MushlamServicesToSefer
		where ID = @id
	end
	else
	if (@tableCode = 17)
	begin
		set @tmpSerCode = 
		(select SeferServiceCode from MushlamSubSpecialityToSefer
			where ID = @id)
		
		delete from MushlamSubSpecialityToSefer
		where ID = @id
		
		/* Checking if need to delete from MushlamServicesToSefer */
		if not exists
		(
			select MSSTS.id from MushlamSubSpecialityToSefer MSSTS
			JOIN MushlamSpecialityToSefer MSTS
			on MSSTS.SeferServiceCode = MSTS.SeferServiceCode
			where MSSTS.SeferServiceCode = @tmpSerCode
		)
		begin
		delete from MushlamServicesToSefer
		where SeferCode = @tmpSerCode and GroupCode = 3 and SubGroupCode = 0
		end
	end
	else --tableCode = 51
		set @tmpSerCode = 
		(select SeferServiceCode from MushlamSpecialityToSefer
			where ID = @id)
		
		delete from MushlamSpecialityToSefer
		where ID = @id
		
		/* Checking if need to delete from MushlamServicesToSefer */
		if not exists
		(
			select MSSTS.id from MushlamSubSpecialityToSefer MSSTS
			JOIN MushlamSpecialityToSefer MSTS
			on MSSTS.SeferServiceCode = MSTS.SeferServiceCode
			where MSSTS.SeferServiceCode = @tmpSerCode
		)
		begin
		delete from MushlamServicesToSefer
		where SeferCode = @tmpSerCode and GroupCode = 3 and SubGroupCode = 0
		end
		

                
GO


GRANT EXEC ON rpc_deleteMushlamToSeferMapping TO PUBLIC

GO            
