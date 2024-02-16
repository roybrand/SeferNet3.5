CREATE function [dbo].[rfn_IngBCNewCodeToOldCodeBySector](@NewCode int, 
														  @ConvertType tinyint, 
														 @EmployeeSectoreCode tinyint) 
returns int
as  
begin  
      Declare @OldCode int 

      set @OldCode = 0  

      -- Profession 
      if   @ConvertType = 1 
            begin 
                  if @NewCode = 40 
                  begin 
                        set @OldCode = 11 
                  end 
                  else 
                        Select @OldCode =  
                        cmp.OldSystemCode 
                        from ING_CodesMapping as cmp 
                        Where cmp.NewSystemCode = @NewCode 
                        and cmp.ConvertType = 4
                        and cmp.DeleteOld = 0  
                        if @OldCode = null or @OldCode = 0
                        begin 
							Select @OldCode = case 
													When @EmployeeSectoreCode = 7 Then  c2.OldSystemCode 
													else 0
											  end 
							from professionsParentChild as pp 
							left join ING_CodesMapping as c2 
							on pp.parentCode  = c2.NewSystemCode 
							and c2.ConvertType = 4 
							and c2.DeleteOld = 0
							Where pp.childCode = @NewCode 
						end 
		                if @OldCode = null or @OldCode = 0
                        begin 
							if @EmployeeSectoreCode = 2 set @OldCode = 6 
							else if @EmployeeSectoreCode = 4 set @OldCode = 81
							else if @EmployeeSectoreCode = 5 set @OldCode = 1
						end 
            end 
      -- Service 
      else if   @ConvertType = 2 
            begin 
                  Select @OldCode = OldSystemCode from ING_CodesMapping as cmp 
                  Where cmp.NewSystemCode = @NewCode 
                  and cmp.ConvertType = 3
                  and cmp.DeleteOld = 0 
            end 
      -- Profession  to Service
      if   @ConvertType = 10 
            begin 
                  Select @OldCode = OldSystemCode from ING_CodesMapping as cmp 
                  Where cmp.NewSystemCode = @NewCode 
                  and cmp.ConvertType = 5
                  and cmp.DeleteOld = 0 
            end 
      -- New Service To Old Profession 
      if   @ConvertType = 11 
            begin 
                  Select @OldCode = OldSystemCode from ING_CodesMapping as cmp 
                  Where cmp.NewSystemCode = @NewCode 
                  and cmp.ConvertType = 8
                  and cmp.DeleteOld = 0 
                  if @OldCode  = null or @OldCode = 0 
                  begin 
					if @EmployeeSectoreCode = 2 set @OldCode = 6 
					else if @EmployeeSectoreCode = 4 set @OldCode = 81
					else if @EmployeeSectoreCode = 5 set @OldCode = 1
				  end 
	
            end 
            
      return @OldCode
end 


GO


grant exec on dbo.rfn_IngBCNewCodeToOldCodeBySector to public 
go  