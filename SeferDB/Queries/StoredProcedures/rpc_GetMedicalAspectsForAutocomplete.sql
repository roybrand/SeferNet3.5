IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMedicalAspectsForAutocomplete')
	BEGIN
		DROP  Procedure  rpc_GetMedicalAspectsForAutocomplete
	END
GO

CREATE Procedure [dbo].[rpc_GetMedicalAspectsForAutocomplete]
(
	@Substring varchar(100)
)

AS 

SELECT MedicalAspectCode, MedicalAspectDescription, ServiceCode 
FROM
(	
	SELECT 
	MF_MedicalAspects830.MedicalServiceCode + ';' + MF_MedicalAspects830.MedicalServiceDesc as MedicalAspectCode, 
	MF_MedicalAspects830.MedicalServiceDesc as MedicalAspectDescription,
	[Services].ServiceCode, showOrder = 0

	FROM MF_MedicalAspects830
	JOIN MedicalAspectsToSefer on MF_MedicalAspects830.MedicalServiceCode = MedicalAspectsToSefer.MedicalAspectCode
	JOIN [Services] on MedicalAspectsToSefer.SeferCode = [Services].ServiceCode
	WHERE MedicalServiceDesc like @Substring + '%'

	UNION 

	SELECT 
	MF_MedicalAspects830.MedicalServiceCode + ';' + MF_MedicalAspects830.MedicalServiceDesc as MedicalAspectCode, 
	MF_MedicalAspects830.MedicalServiceDesc as MedicalAspectDescription,
	[Services].ServiceCode, showOrder = 1

	FROM MF_MedicalAspects830
	JOIN MedicalAspectsToSefer on MF_MedicalAspects830.MedicalServiceCode = MedicalAspectsToSefer.MedicalAspectCode
	JOIN [Services] on MedicalAspectsToSefer.SeferCode = [Services].ServiceCode
	WHERE MedicalServiceDesc like '%' + @Substring + '%'
	AND MedicalServiceDesc NOT like @Substring + '%'
) as T
ORDER BY showOrder, MedicalAspectDescription

GO

GRANT EXEC ON rpc_GetMedicalAspectsForAutocomplete TO PUBLIC
GO
