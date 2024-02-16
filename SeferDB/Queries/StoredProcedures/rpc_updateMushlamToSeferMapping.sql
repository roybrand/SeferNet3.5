IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateMushlamToSeferMapping')
    BEGIN
	    DROP  Procedure  rpc_updateMushlamToSeferMapping
    END

GO

CREATE Procedure dbo.rpc_updateMushlamToSeferMapping
(
	@tableCode INT,
	@mappingID INT, 
	@mushlamServiceCode INT, 
	@seferServiceCode INT,
	@parentCode INT, 
	@groupCode INT,
	@subGroupCode INT,
	@updateUser VARCHAR(50)
)

AS

IF @tableCode = 15 --MushlamTreatmentTypesToSefer
begin
	declare @treatmentName varchar(100)
	set @treatmentName = (select TreatmentName from MushlamTreatmentTypes
							where TreatmentCode = @mushlamServiceCode)
		update MushlamTreatmentTypesToSefer
		set MushlamCode = @mushlamServiceCode,
			Description = @treatmentName,
			SeferCode = @seferServiceCode,
			ParentServiceID = ParentServiceID,
			UpdateUser = @updateUser,
			UpdateDate = GETDATE()
		where ID = @mappingID
end 
else
begin
	if @tableCode = 17 --MushlamSubSpecialityToSefer
	begin	
		declare @oldSubSeferServiceCode int
				
		set @oldSubSeferServiceCode = 
		(
			select SeferServiceCode from MushlamSubSpecialityToSefer
			where ID = @mappingID
		)
		
		update MushlamSubSpecialityToSefer
		set MushlamServiceCode = @mushlamServiceCode,
			ParentCode = @parentCode,
			SeferServiceCode = @seferServiceCode,
			UpdateUser = @updateUser,
			UpdateDate = GETDATE()
		where ID = @mappingID	
		
		/* Updating also MushlamServicesToSefer:
		   If the old service code does no exist at
		   MushlamSpecialityToSefer or MushlamSubSpecialityToSefer
		   we need to delete it from MushlamServicesToSefer.
		*/
		if not exists(
			select MSTS.id from MushlamSpecialityToSefer MSTS
			join MushlamSubSpecialityToSefer MSSTS
			on MSTS.SeferServiceCode = MSSTS.SeferServiceCode
			where MSTS.SeferServiceCode = @oldSubSeferServiceCode
		)
		begin
			delete MushlamServicesToSefer
			where GroupCode = 3
			and SubGroupCode = 0
			and SeferCode = @oldSubSeferServiceCode
			
		end
		
		/* Inserting the new service to MushlamServicesToSefer */
		if not exists(
			select id from MushlamServicesToSefer
			where GroupCode = 3
			and SubGroupCode = 0
			and SeferCode = @seferServiceCode
			)	
		begin
			insert into MushlamServicesToSefer
			(GroupCode,SubGroupCode,SeferCode,UpdateUser,UpdateDate)
			values(3,0,@seferServiceCode,@updateUser,GETDATE())
		end
	end
	else
	begin
		if @tableCode = 18 --MushlamServicesToSefer
		begin
			update MushlamServicesToSefer
			set GroupCode = @groupCode,
				SubGroupCode = @subGroupCode,
				SeferCode = @seferServiceCode,
				UpdateUser = @updateUser,
				UpdateDate = GETDATE()
			where ID = @mappingID
			
		end
		else
		begin
			if @tableCode = 51 ----MushlamSpecialityToSefer
			begin
				
				declare @oldSeferServiceCode int
				
				set @oldSeferServiceCode = 
				(
					select SeferServiceCode from MushlamSpecialityToSefer
					where ID = @mappingID
				)
				
				update MushlamSpecialityToSefer
				set MushlamServiceCode = @mushlamServiceCode,
					SeferServiceCode = @seferServiceCode,
					UpdateUser = @updateUser,
					UpdateDate = GETDATE()
				where ID = @mappingID
				
				/* Updating also MushlamServicesToSefer:
				   If the old service code does no exist at
				   MushlamSpecialityToSefer or MushlamSubSpecialityToSefer
				   we need to delete it from MushlamServicesToSefer.
				*/
				if not exists(
					select MSTS.id from MushlamSpecialityToSefer MSTS
					join MushlamSubSpecialityToSefer MSSTS
					on MSTS.SeferServiceCode = MSSTS.SeferServiceCode
					where MSTS.SeferServiceCode = @oldSeferServiceCode
				)
				begin
					delete MushlamServicesToSefer
					where GroupCode = 3
					and SubGroupCode = 0
					and SeferCode = @oldSeferServiceCode
					
				end
				
				/* Inserting the new service to MushlamServicesToSefer */
				if not exists(
					select id from MushlamServicesToSefer
					where GroupCode = 3
					and SubGroupCode = 0
					and SeferCode = @seferServiceCode
					)	
				begin
					insert into MushlamServicesToSefer
					(GroupCode,SubGroupCode,SeferCode,UpdateUser,UpdateDate)
					values(3,0,@seferServiceCode,@updateUser,GETDATE())
				end
					
					
			end
		end
	end
end
                
GO


GRANT EXEC ON rpc_updateMushlamToSeferMapping TO PUBLIC

GO            
