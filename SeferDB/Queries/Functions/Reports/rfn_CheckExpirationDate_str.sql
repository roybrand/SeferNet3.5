IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_CheckExpirationDate_str')
	BEGIN
		DROP  function  rfn_CheckExpirationDate_str
	END

GO
-- checks if Real expiration interval intersect at conditional interval  
create function dbo.rfn_CheckExpirationDate_str
 (
	@RealValidFrom_str varchar(15),
	@RealValidTo_str varchar(15),
	@ValidFrom_str varchar(15),
	@ValidTo_str varchar(15)
 ) 
RETURNS varchar(1)
WITH EXECUTE AS CALLER

AS
BEGIN

----------@ValidFrom and @ValidTo parameters casting ------------------------
		declare @result varchar(1)
		set @result = 0

		declare @ValidFrom smallDateTime
		declare @ValidTo smallDateTime
		
		
		if (isdate(@ValidTo_str)= 0 )
			set @ValidTo = null
		else
			set @ValidTo = convert(smallDateTime, @ValidTo_str, 103 )

		if (isdate(@ValidFrom_str) = 0) -- getdate()
			set @ValidFrom = convert(smallDateTime, '01/01/1900', 103 )
		else
			set @ValidFrom = convert(smallDateTime, @ValidFrom_str, 103 )
		
		
---------- @RealValidFrom and @RealValidTo parameters casting ------------
		declare	@RealValidFrom smallDateTime
		declare	@RealValidTo smallDateTime

		if (isdate(@RealValidTo_str)= 0 )
			set @RealValidTo = null
		else
			set @RealValidTo = convert(smallDateTime, @RealValidTo_str, 103 )
			
		if (isdate(@RealValidFrom_str)= 0 )
			set @RealValidFrom = null
		else
			set @RealValidFrom = convert(smallDateTime, @RealValidFrom_str, 103 )


-------- dates interval comperetion ---------------
		if(@ValidTo is null and @RealValidTo is null
	
		or	@ValidTo is not null and @RealValidTo is not null
			and @ValidFrom <= @RealValidTo and	 @RealValidFrom <=  @ValidTo 
	
		or  @ValidTo is not null and @RealValidTo is null
			and  @RealValidFrom <=  @ValidTo
	
		or	@ValidTo is null and @RealValidTo is not null
			and @ValidFrom <= @RealValidTo
		)
				set @result = 1
		 else 
				set @result = 0
	
return (@result)
end


go 

grant exec on rfn_CheckExpirationDate_str to public 
go 


	 




