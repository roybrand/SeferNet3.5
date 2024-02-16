ALTER function [dbo].[rfn_IngBCNewCodeToOldCode](@NewCode int, @ConvertType tinyint) 
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
                        Select @OldCode = OldSystemCode from ING_CodesMapping as cmp 
                        Where cmp.NewSystemCode = @NewCode 
                        and cmp.ConvertType = 4
                        and cmp.DeleteOld = 0 
            end 
      -- Service 
      else if   @ConvertType = 2 
            begin 
                  Select @OldCode = OldSystemCode from ING_CodesMapping as cmp 
                  Where cmp.NewSystemCode = @NewCode 
                  and cmp.ConvertType = 3
                  and cmp.DeleteOld = 0 
            end 
      

      -- Position  
      else if   @ConvertType = 3 
            begin 
                  Select @OldCode = OldSystemCode from ING_CodesMapping as cmp 
                  Where cmp.NewSystemCode = @NewCode 
                  and cmp.ConvertType = 10
                  and cmp.DeleteOld = 0 
                  if @OldCode = 0 set @OldCode = 9999 
            end 
      -- Dept Type 
      else if   @ConvertType = 4  
            begin 
                  set @OldCode = 0  
            end         
      -- independent dept 
      else if   @ConvertType = 5 
            begin 
					if @NewCode is null  or @NewCode = 0 
						set @OldCode =  0 
					else 
						set @OldCode =  1
            end         
      -- Dept status 
      else if   @ConvertType = 6 
            begin 
                  if @NewCode = 1   set @OldCode = 0  
                  else if @NewCode = 0    set @OldCode = 1 
                  else if @NewCode = 2    set @OldCode = 2 
            end         
      -- population Sector Code
      else if   @ConvertType = 7 
            begin 
                  if @NewCode = 1   set @OldCode = 2 
                  else if @NewCode = 2    set @OldCode = 3 
                  else if @NewCode = 3    set @OldCode = 4 
                  else if @NewCode = 4    set @OldCode = 2
                  else set @OldCode = 1
            end         
-- Employee Sector to Profession - x_dept_emp 
-- מינהל - 81
-- סיעוד - 1 
-- רוקחות - 83
	else if   @ConvertType = 8 
		begin	
			-- פארא רפואי
			if @NewCode = 2 	set @OldCode = 2 
			-- לא רופא
			else if @NewCode = 3 	set @OldCode = 2 
			-- מינהל
			else if @NewCode = 4 	set @OldCode = 81 
			-- סיעוד
			else if @NewCode = 5 	set @OldCode = 1 
			-- רוקחות
			else if @NewCode = 6 	set @OldCode = 83  
			-- רפואה
			else if @NewCode = 7 	set @OldCode = 2 
				
		end 	
            
-- Employee Sector to Position - x_dept_emp 
	else if   @ConvertType = 9 
		begin	
			-- פארא רפואי
			if @NewCode = 2 	set @OldCode = 28 
			-- לא רופא
			else if @NewCode = 3 	set @OldCode = 2 
			-- מינהל
			else if @NewCode = 4 	set @OldCode = 5 
			-- סיעוד
			else if @NewCode = 5 	set @OldCode = 2 
			-- רוקחות -- 
			else if @NewCode = 6 	set @OldCode = 59
			-- רפואה
			else if @NewCode = 7 	set @OldCode = 80 
				
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
            end 
            
      return @OldCode
end 
