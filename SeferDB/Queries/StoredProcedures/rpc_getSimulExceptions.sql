IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSimulExceptions')
	BEGIN
		DROP  Procedure  rpc_getSimulExceptions
	END

GO

CREATE Procedure rpc_getSimulExceptions

AS
SELECT SimulExceptions.Simulid ,SimulExceptions.SeferSherut, KodSimul, 
'Ord' = 0 
FROM SimulExceptions  
LEFT JOIN Simul403 ON SimulExceptions.SimulId = Simul403.KodSimul 
WHERE SeferSherut = 1 and KodSimul IS NULL 
UNION  
SELECT SimulExceptions.Simulid ,SimulExceptions.SeferSherut, KodSimul, 
'Ord' = 1 
FROM SimulExceptions  
LEFT JOIN Simul403 ON SimulExceptions.SimulId = Simul403.KodSimul 
WHERE NOT (SeferSherut = 1 and KodSimul is null) 
ORDER BY Ord, SeferSherut DESC 

GO


GRANT EXEC ON rpc_getSimulExceptions TO PUBLIC

GO


