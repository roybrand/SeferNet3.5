 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'SqlDynamicWhereAndSeparator')
	BEGIN
		DROP  FUNCTION  SqlDynamicWhereAndSeparator
	END

GO

create FUNCTION [dbo].[SqlDynamicWhereAndSeparator]
(
	@sqlWhere varchar (4000)
	
)
RETURNS varchar(4000)

AS
BEGIN	
		
	if (@sqlWhere <> 'WHERE ')
	begin  
	set @sqlWhere = @sqlWhere + ' and ';
	end 

	RETURN (@sqlWhere)
END  
go