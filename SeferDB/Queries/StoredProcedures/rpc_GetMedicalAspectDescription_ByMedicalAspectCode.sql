IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMedicalAspectDescription_ByMedicalAspectCode')
	BEGIN
		DROP  Procedure  rpc_GetMedicalAspectDescription_ByMedicalAspectCode
	END
GO

CREATE Procedure [dbo].[rpc_GetMedicalAspectDescription_ByMedicalAspectCode]
(
	@MedicalAspectCode varchar(10)
)

AS 
SELECT MedicalServiceDesc as MedicalAspectDescription 
FROM MF_MedicalAspects830
WHERE MF_MedicalAspects830.MedicalServiceCode = @MedicalAspectCode

GO

GRANT EXEC ON rpc_GetMedicalAspectDescription_ByMedicalAspectCode TO PUBLIC
GO

