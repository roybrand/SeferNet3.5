IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetBrochures')
	BEGIN
		DROP  Procedure  rpc_GetBrochures
	END

GO

CREATE Procedure dbo.rpc_GetBrochures
(
	@IsCommunity bit,
	@IsMushlam bit
)	
AS
	select BrochureID,DisplayName,FileName,languages.displayDescription,
	Brochures.languageCode,
	'tbl' = case ROW_NUMBER() over(order by brochureID)%2 
				when 1 then '1'
				else '2' end
	
	from Brochures
	join languages on Brochures.languageCode = languages.languageCode
	where Brochures.IsCommunity = @IsCommunity 
		and Brochures.IsMushlam = @IsMushlam 

GO

GRANT EXEC ON rpc_GetBrochures TO PUBLIC

GO