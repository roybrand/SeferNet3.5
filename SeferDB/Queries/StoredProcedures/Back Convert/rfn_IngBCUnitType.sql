USE [SeferNetHasavaLeAhor]
GO
/****** Object:  UserDefinedFunction [dbo].[rfn_IngBCUnitType]    Script Date: 08/02/2010 17:17:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[rfn_IngBCUnitType](@NewUnitType int, @NewSubUnitType int, @DeptName as varchar(100)) 
returns int 
as  

begin  

	declare @ReturnUnitType  int  
	declare @SubUnitTypeDesc  varchar(50) 

	set @ReturnUnitType  = 0  

	set @SubUnitTypeDesc  = '' 
	if @NewUnitType = 401  
	begin 
		select @SubUnitTypeDesc = subUnitTypeName from dbo.subUnitType 
								  where subUnitTypeCode = @NewSubUnitType 
								  and UnitTypeCode = @NewUnitType 
		if @SubUnitTypeDesc = 'פרטי בהסכם'  
		begin	
			set @ReturnUnitType  = 402 
		end 
		else
		begin 
			set @ReturnUnitType  = @NewUnitType 
		end 
	end 
	else if @NewUnitType in (102, 103, 104) 
	begin 
		select @SubUnitTypeDesc = subUnitTypeName from dbo.subUnitType 
								  where subUnitTypeCode = @NewSubUnitType 
								  and UnitTypeCode = @NewUnitType 
		if @SubUnitTypeDesc = 'עצמאית'  
		begin	
			set @ReturnUnitType  = 106  
		end 
		else
		begin 
			set @ReturnUnitType  = @NewUnitType 
		end 
	end  
	else if @NewUnitType = 111 
	begin 
		select @SubUnitTypeDesc = subUnitTypeName from dbo.subUnitType 
								  where subUnitTypeCode = @NewSubUnitType 
								  and UnitTypeCode = @NewUnitType 
		if @SubUnitTypeDesc = 'פרטי בהסכם'  or @NewUnitType  = 2 
		begin	
			set @ReturnUnitType  = 112  
		end 
		else
		begin 
			set @ReturnUnitType  = @NewUnitType 
		end 
	end  
	else 
	begin 
		select @ReturnUnitType  = BackConvertCode 
								  from ING_UnitTypeConversion 
								  Where NewUnitTypeCode = @NewUnitType  
								  and (SubUnitTypeCode = @NewSubUnitType or SubUnitTypeCode is null)
								  and Direction  = 2 
	end 

	return @ReturnUnitType 
end
