IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertSubUnitTypes')
	BEGIN
		DROP  Procedure  rpc_insertSubUnitTypes
	END

GO


CREATE Procedure [dbo].[rpc_insertSubUnitTypes]
(  
	@subUnitTypeCodeList varchar(100), 	
	@unitTypeCode int, 	
	@userName varchar(100)		
)
as  

declare @myTable table
	(
		ID INT IDENTITY(1,1),
		UnitCode int   
	    
	)

delete from subUnitType where UnitTypeCode=@unitTypeCode

-- Get the subUnitTypeCodes from the list into the table
-- and then run a loop on it	
insert into @myTable(UnitCode)select * from rfn_SplitStringByDelimiterValuesToStr(@subUnitTypeCodeList,',')
declare @i int
declare @RowCount int

set @RowCount = (Select Count(*) From @myTable)
set @i = 1
WHILE (@i <= @RowCount)
	BEGIN
	        DECLARE @iSubUnitTypeCode int    
	        SELECT @iSubUnitTypeCode = UnitCode FROM @myTable WHERE ID = @i
	        Insert into subUnitType(subUnitTypeCode,UnitTypeCode,UpdateDate,UpdateUser)
				values(@iSubUnitTypeCode,@unitTypeCode,GETDATE(),@userName)
			SET @i = @i  + 1
	END

GO

GRANT EXEC ON rpc_insertSubUnitTypes TO PUBLIC