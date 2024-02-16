IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertMushlamToSeferMapping')
    BEGIN
	    DROP  Procedure  rpc_insertMushlamToSeferMapping
    END

GO

CREATE Procedure dbo.rpc_insertMushlamToSeferMapping
(
	@tableCode INT, 
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
	if not exists(select MushlamCode from MushlamTreatmentTypesToSefer
					where MushlamCode = @mushlamServiceCode
					and SeferCode = @seferServiceCode
					and ParentServiceID = @parentCode)
	begin
		declare @treatmentName varchar(100)
		set @treatmentName = (select TreatmentName from MushlamTreatmentTypes
								where TreatmentCode = @mushlamServiceCode)
		insert into MushlamTreatmentTypesToSefer 
		(MushlamCode,Description,SeferCode,ParentServiceID,UpdateUser,UpdateDate)
		values(@mushlamServiceCode,@treatmentName,@seferServiceCode,
		@parentCode,@updateUser, GETDATE())
	end					
				  
end
else
begin
	if @tableCode = 17 --MushlamSubSpecialityToSefer
	begin	
		if not exists(
		select id from MushlamSubSpecialityToSefer
		where MushlamServiceCode = @mushlamServiceCode
		and ParentCode = @parentCode
		and SeferServiceCode = @seferServiceCode
		)
		begin
			insert into MushlamSubSpecialityToSefer
			(MushlamTableCode,MushlamServiceCode,ParentCode,SeferServiceCode,
			UpdateUser,UpdateDate)
			values(@tableCode,@mushlamServiceCode,@parentCode,@seferServiceCode,
			@updateUser,GETDATE())
			
			-- Inserting also to MushlamServicesToSefer
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
	else
	begin
		if @tableCode = 18 --MushlamServicesToSefer
		begin
			if not exists(
				select id from MushlamServicesToSefer
				where GroupCode = @groupCode
				and SubGroupCode = @subGroupCode
				and SeferCode = @seferServiceCode
			)	
			begin
				insert into MushlamServicesToSefer
				(GroupCode,SubGroupCode,SeferCode,UpdateUser,UpdateDate)
				values(@groupCode,@subGroupCode,@seferServiceCode,@updateUser,GETDATE())
			end
		end
		else
		begin
			if @tableCode = 51 --MushlamSpecialityToSefer
			begin
				if not exists(
					select id from MushlamSpecialityToSefer
					where MushlamServiceCode = @mushlamServiceCode
					and SeferServiceCode = @seferServiceCode
				)
				begin
					insert into MushlamSpecialityToSefer
					(MushlamTableCode,MushlamServiceCode,SeferServiceCode,
					UpdateUser,UpdateDate)
					values(@tableCode,@mushlamServiceCode,@seferServiceCode,
					@updateUser,GETDATE())
						-- Inserting also to MushlamServicesToSefer
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
end
             
GO


GRANT EXEC ON rpc_insertMushlamToSeferMapping TO PUBLIC

GO     