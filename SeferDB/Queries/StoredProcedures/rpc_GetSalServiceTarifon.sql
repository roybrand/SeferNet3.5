IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServiceTarifon')
	BEGIN
		DROP  Procedure  rpc_GetSalServiceTarifon
	END

GO

CREATE PROCEDURE [dbo].[rpc_GetSalServiceTarifon]
@ServiceCode Int , @IsBasicPermission Bit
As

Select	[Populations].PopulationsDesc As PopulationsDesc, [SubPopulations].PopulationsDesc As SubPopulationsDesc, 
		ST.PopulationCode, ST.PopulationSubCode, 
		ST.TariffNew, ST.TrueDate As UpdateDate,
		PopulationGiven
From MF_SalServices386 SALS
Left Join (	Select ServiceCode, PopulationCode, PopulationSubCode, Max(TrueDate) LatestTrueDate
			From MF_ServicesTariff210
			Group By ServiceCode, PopulationCode, PopulationSubCode ) As LatestServicesTariff On 
									LatestServicesTariff.ServiceCode = SALS.ServiceCode
Left Join (	Select ServiceCode, PopulationCode, PopulationSubCode, TrueDate, TariffNew, PopulationGiven
			From MF_ServicesTariff210  where PopulationCancelCode = 0) ST On 
									ST.TrueDate = LatestServicesTariff.LatestTrueDate And
									ST.PopulationCode = LatestServicesTariff.PopulationCode And
									ST.PopulationSubCode = LatestServicesTariff.PopulationSubCode And
									ST.ServiceCode = LatestServicesTariff.ServiceCode
Left Join MF_Populations213 [Populations] ON [Populations].PopulationsCode = ST.PopulationCode And [Populations].SubPopulationsCode = 0 And [Populations].IsCanceled = 0
Left Join MF_Populations213 [SubPopulations] ON [SubPopulations].SubPopulationsCode = ST.PopulationSubCode And 
													ST.PopulationSubCode > 0 And [Populations].PopulationsCode = [SubPopulations].PopulationsCode And [SubPopulations].IsCanceled = 0
Where SALS.ServiceCode = @ServiceCode And 
		( @IsBasicPermission = 0 Or ( [Populations].PopulationsCode In ( 2,3,10,12 ) And ST.PopulationSubCode = 0  ) )
AND [Populations].PopulationsDesc is not null		
order by PopulationCode, PopulationSubCode
GO

GRANT EXEC ON rpc_GetSalServiceTarifon TO PUBLIC

GO