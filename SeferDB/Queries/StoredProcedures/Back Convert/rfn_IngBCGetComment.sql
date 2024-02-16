ALTER  FUNCTION [dbo].[rfn_IngBCGetComment](@CommnetText varchar(1000), @CommentType tinyint)
RETURNS varchar(1000)
AS
BEGIN
	
	DECLARE @ReturnComment varchar(1000) 
	declare @newline char(2) 
	
	set @ReturnComment = '' 
	set @ReturnComment = Rtrim(ltrim(@CommnetText)) 
		
		
	set @newline = CHAR(10)  + CHAR(13) 


		-- @CommentType = 1 - Dept Remark 
	IF @CommentType = 1 set @ReturnComment = LEFT(@ReturnComment, 1000) 
	-- @CommentType = 2 - Dept Sweeping Remark 
	else IF @CommentType = 2 set @ReturnComment = LEFT(@ReturnComment, 1000) 
	-- @CommentType = 3 - Employee Remark 
	else IF @CommentType = 3 set @ReturnComment = LEFT(@ReturnComment, 50) 
	-- @CommentType = 4 - Employee Dept Remark 
	else IF @CommentType = 4 
		begin 
			set @ReturnComment = LEFT(@ReturnComment, 500) 
			if right(@ReturnComment, len(@newline)) = @newline set @ReturnComment = LEFT(@ReturnComment, @ReturnComment - LEN(@newline)) 
		end 
	-- @CommentType = 5 - Dept Reception Remark 
	else IF @CommentType = 5 set @ReturnComment = LEFT(@ReturnComment, 500)
	-- @CommentType = 6 - Dept Service Reception Remark 
	else IF @CommentType = 6 set @ReturnComment = LEFT(@ReturnComment, 100)
	-- @CommentType = 7 - Employee Dept Reception Remark 
	else IF @CommentType = 7 
	begin
		set @ReturnComment = LEFT(@ReturnComment, 500)
		if right(@ReturnComment, len(@newline)) = @newline set @ReturnComment = LEFT(@ReturnComment, @ReturnComment - LEN(@newline)) 
	end 


	set @ReturnComment = dbo.rfn_CleanString(@ReturnComment)  
	 
	RETURN @ReturnComment

END
