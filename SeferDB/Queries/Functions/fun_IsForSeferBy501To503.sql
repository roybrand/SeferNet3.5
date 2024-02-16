IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_IsForSeferBy501To503')
	BEGIN
		DROP  FUNCTION  fun_IsForSeferBy501To503
	END
GO

CREATE FUNCTION dbo.fun_IsForSeferBy501To503
(
	@KodSimul int 
)

RETURNS INT

AS

BEGIN
	DECLARE @Count INT

	SET @Count = (	SELECT COUNT(*)
					FROM Simul403
					INNER JOIN SugSimul501 T501		ON  Simul403.SugSimul501 = T501.SugSimul
													AND T501.SeferSherut = 1
					LEFT JOIN TatSugSimul502 T502	ON  Simul403.SugSimul501 = T502.SugSimul
													AND Simul403.TatSugSimul502 = T502.TatSugSimulId
					LEFT JOIN TatHitmahut503 T503	ON Simul403.SugSimul501 = T503.SugSimul
													AND Simul403.TatSugSimul502 = T503.TatSugSimulId
													AND Simul403.TatHitmahut503 = T503.TatHitmahut
					WHERE	( IsNull(Simul403.TatSugSimul502, 0) = 0 
								OR (Simul403.SugSimul501 = T502.SugSimul AND Simul403.TatSugSimul502 = T502.TatSugSimulId )
							)
					AND		( IsNull(Simul403.TatHitmahut503, 0) = 0
								OR (Simul403.SugSimul501 = T503.SugSimul AND Simul403.TatSugSimul502 = T503.TatSugSimulId AND Simul403.TatHitmahut503 = T503.TatHitmahut )
							)		  
					AND Simul403.KodSimul = @KodSimul 
				)	

	SET @Count = IsNull(@Count, 0)
					
	RETURN @Count
END
GO

GRANT EXEC ON fun_IsForSeferBy501To503 TO PUBLIC

GO

