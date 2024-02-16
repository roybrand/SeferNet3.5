Create Procedure dbo.rpc_ingBCWriteToLog(
		@SrcTable varchar(50), 
		@DestTable varchar(50), 
		@BCAction varchar(10), 
		@AffectRows bigint) 
as 

	insert into ING_BCLog
	(DistrictCode, TableCode, SourceTableName,  DestTableName, BCAction, AffectedRows)
	Select bccd.DistrictCode as DistrictCode, 255 TableCode, 
	@SrcTable as SourceTableName,  @DestTable as DestTableName	, 
	@BCAction as BCAction, @AffectRows as AffectedRows
	from Ing_BCConvertDistricts  as bccd 
	left join View_AllDistricts  as vad 
	on bccd.DistrictCode = vad.DistrictCode 
	where 	BCConvert = 1 
