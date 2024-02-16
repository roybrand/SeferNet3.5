IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServiceTarifonHistory')
	BEGIN
		DROP  Procedure  rpc_GetSalServiceTarifonHistory
	END

GO

CREATE PROCEDURE [dbo].[rpc_GetSalServiceTarifonHistory]
@ServiceCode Int , @PopulationsCode TinyInt , @SubPopulationsCode TinyInt
As

Select ServiceCode , PopulationCode , PopulationSubCode , TariffNew ,  TrueDate 
From MF_ServicesTariff210
Where ServiceCode = @ServiceCode And PopulationCode = @PopulationsCode And PopulationSubCode = @SubPopulationsCode
Order By TrueDate Desc

Go

GRANT EXEC ON rpc_GetSalServiceTarifonHistory TO PUBLIC

GO