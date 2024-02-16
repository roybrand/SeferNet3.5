IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClalitServicesForAutocomplete')
	BEGIN
		DROP  Procedure  rpc_GetClalitServicesForAutocomplete
	END
GO

CREATE Procedure [dbo].[rpc_GetClalitServicesForAutocomplete]
(
	@Substring varchar(100)
)

AS 

SELECT ClalitServiceCode, ClalitServiceDescription, ServiceCode
FROM
(
	SELECT 
	MF_MedicalAspects830.ClalitServiceCode + ';' + MF_SalServices386.ServiceName as ClalitServiceCode,
	[Services].ServiceCode,
	MF_SalServices386.ServiceName as ClalitServiceDescription,
	showOrder = 0

	FROM MF_MedicalAspects830
	JOIN MedicalAspectsToSefer on MF_MedicalAspects830.MedicalServiceCode = MedicalAspectsToSefer.MedicalAspectCode
	JOIN [Services] on MedicalAspectsToSefer.SeferCode = [Services].ServiceCode
	JOIN MF_SalServices386 on MF_MedicalAspects830.ClalitServiceCode = MF_SalServices386.ServiceCode
	WHERE ServiceName like @Substring + '%'

	UNION

	SELECT 
	MF_MedicalAspects830.ClalitServiceCode + ';' + MF_SalServices386.ServiceName as ClalitServiceCode,
	[Services].ServiceCode,
	MF_SalServices386.ServiceName as ClalitServiceDescription,
	showOrder = 1

	FROM MF_MedicalAspects830
	JOIN MedicalAspectsToSefer on MF_MedicalAspects830.MedicalServiceCode = MedicalAspectsToSefer.MedicalAspectCode
	JOIN [Services] on MedicalAspectsToSefer.SeferCode = [Services].ServiceCode
	JOIN MF_SalServices386 on MF_MedicalAspects830.ClalitServiceCode = MF_SalServices386.ServiceCode
	WHERE ServiceName like '%' + @Substring + '%'
	AND ServiceName NOT like @Substring + '%'
) as T
ORDER BY showOrder, ClalitServiceDescription
GO

GRANT EXEC ON rpc_GetClalitServicesForAutocomplete TO PUBLIC
GO
