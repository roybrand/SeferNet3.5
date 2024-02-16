IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetPopulationDetails')
	BEGIN
		DROP  Procedure  rpc_GetPopulationDetails
	END

GO

CREATE PROCEDURE dbo.rpc_GetPopulationDetails
@PopulationsCode TinyInt , @SubPopulationsCode TinyInt
As

Select * 
from MF_Populations213 P
Where P.PopulationsCode = @PopulationsCode And P.SubPopulationsCode = @SubPopulationsCode 

Select * 
From MF_PopulationSettings251
Where PopulationCode = @PopulationsCode

Go

GRANT EXEC ON rpc_GetPopulationDetails TO PUBLIC

GO