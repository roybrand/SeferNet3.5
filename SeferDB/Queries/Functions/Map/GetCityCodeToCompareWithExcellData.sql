IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'GetCityCodeToCompareWithExcellData')
BEGIN
	print 'drop function GetCityCodeToCompareWithExcellData'
	DROP  FUNCTION  GetCityCodeToCompareWithExcellData
END

GO


create FUNCTION [dbo].[GetCityCodeToCompareWithExcellData](@cityCodeToFix int)

RETURNS varchar(50)
AS
BEGIN
	--fix citycode to match the format that the excell->city table has
	--because city table has normal codes (numbers) and they have codes with letters in the 
	-- end ,like 501u, so when we insert these code to the cities table we fix them
	-- and we remove the letter and we add 1000000 so we get 1000501
	--so this function fix it back from the number to original number 501u
	return 
	(case when @cityCodeToFix > 1000000 then cast((@cityCodeToFix - 1000000) as varchar(50)) + 'u' else cast(@cityCodeToFix as varchar(50))end)

END

go 