Alter function [dbo].[rfn_IngBCNewCodeToOldCode2](@NewProfessionCode int, 
													@NewPositionCode  int, 
													@NewServiceCode int , 
													@NewSectorCode  int, 
													@Expert tinyint , 
													@ConvertType tinyint) 
returns int
as  
begin  
	Declare @OldCode int 

	set @OldCode = 0   
	
	-- Convert to Old Postion 
	if @ConvertType = 9 
	begin 
				if @NewPositionCode is null and @NewProfessionCode = 2 and @Expert = 1 
				begin 
					set @OldCode = 53   
				end 
				else if @NewPositionCode is null and @NewProfessionCode = 411 and @NewSectorCode = 2  
				begin 
					set @OldCode = 3   
				end 
				else if @NewPositionCode is null and @NewProfessionCode in (101, 749) and @NewSectorCode = 2  
				begin 
					set @OldCode = 26   
				end 
				else if @NewPositionCode is null and @NewProfessionCode = 363 and @NewSectorCode = 2  
				begin 
					set @OldCode = 37
				end 
				else if @NewPositionCode is null and @NewProfessionCode = 125 and @NewSectorCode = 2  
				begin 
					set @OldCode = 18
				end 
				else if @NewPositionCode is null and @NewProfessionCode = 751 and @NewSectorCode = 2  
				begin 
					set @OldCode = 22
				end 
				else if @NewPositionCode is null and @NewProfessionCode = 576 and @NewSectorCode = 2  
				begin 
					set @OldCode = 32
				end 
				else if @NewPositionCode is null and @NewServiceCode in (524,1034,250)  and @NewSectorCode = 2  
				begin 
					set @OldCode = 73
				end 

				else if @NewPositionCode is null and @NewProfessionCode = 40 and @Expert = 1 
				begin 
					set @OldCode = 68
				end 
				else if @NewPositionCode is null and @NewProfessionCode not in (40,2) and @Expert = 0
				begin 
					set @OldCode = 51
				end 
				else if @NewPositionCode is null and @NewProfessionCode not in (40,2) and @Expert = 1
				begin 
					set @OldCode = 50
				end 

				else if @NewPositionCode is null and @NewSectorCode = 5 
				begin 
					set @OldCode = 2
				end 
				
				else if @NewPositionCode is null and @NewSectorCode = 4
				begin 
					set @OldCode = 6
				end 
				else if @NewPositionCode is null and @NewSectorCode = 6
				begin 
					set @OldCode = 61
				end 
				else if @NewPositionCode is null and @NewSectorCode = 7 and @NewProfessionCode = 2  and @Expert = 0 
				begin 
					set @OldCode = 52
				end 
	end 
	-- Convert to Old Profession 
	else if @ConvertType = 8  
	begin 
		if @NewPositionCode is null and @NewProfessionCode is null and @NewSectorCode = 6  
		begin 
			set @OldCode = 83
		end 
		else if @NewPositionCode = 59 and @NewSectorCode = 6 
		begin 
			set @OldCode = 83
		end 
		else if @NewProfessionCode = 751  and @NewSectorCode = 2 
		begin 
			set @OldCode = 9005 --71
		end 
		else if @NewProfessionCode = 125 and @NewSectorCode = 2 
		begin 
			set @OldCode = 9011 --71 
		end 
		else if @NewProfessionCode = 576 and @NewSectorCode = 2 
		begin 
			set @OldCode = 71 
		end 
		else if @NewServiceCode = 524 and @NewSectorCode = 2 
		begin 
			set @OldCode = 85
		end 
		else if @NewServiceCode = 1034 and @NewSectorCode = 2 
		begin 
			set @OldCode = 63
		end 
		else if @NewServiceCode = 250 and @NewSectorCode = 2 
		begin 
			set @OldCode = 61
		end 
		else if @NewProfessionCode = 363 and @NewSectorCode = 2 
		begin 
			set @OldCode = 9012
		end 
		else if @NewProfessionCode = 749 and @NewSectorCode = 2 
		begin 
			set @OldCode = 9007
		end 
		else if @NewProfessionCode = 101 and @NewSectorCode = 2 
		begin 
			set @OldCode = 9009
		end 

	end 



	return @OldCode
end 
go 
grant exec on [dbo].[rfn_IngBCNewCodeToOldCode2] to public 



 