IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClinicMedicalAspects')
	BEGIN
		DROP  Procedure  dbo.rpc_GetClinicMedicalAspects
	END
GO

CREATE Procedure dbo.rpc_GetClinicMedicalAspects
(
	@DeptCode int
) 

AS

SELECT DISTINCT
x_dept_medicalAspect.NewDeptCode as DeptCode, 
s.ServiceDescription, -- שם בספר
x_dept_medicalAspect.MedicalAspectCode, -- קוד היבט
s.ServiceCode, -- קוד ספר

MF_MedicalAspects830.MedicalServiceDesc as MedicalAspectName, -- שם היבט
MF_MedicalAspects830.MedicalServiceCode, -- קוד היבט
MF_MedicalAspects830.ClalitServiceCode, -- קוד כללית
MF_SalServices386.ServiceName as ClalitServiceName -- שם כללית


FROM x_dept_medicalAspect 
JOIN MedicalAspectsToSefer MAtoS ON x_dept_medicalAspect.MedicalAspectCode = MAtoS.MedicalAspectCode
JOIN [Services] s ON s.ServiceCode = MAtoS.SeferCode
JOIN MF_MedicalAspects830 
	ON x_dept_medicalAspect.MedicalAspectCode = MF_MedicalAspects830.MedicalServiceCode 
JOIN MF_SalServices386 ON MF_MedicalAspects830.ClalitServiceCode = MF_SalServices386.ServiceCode
WHERE NewDeptCode = @DeptCode

GO

GRANT EXEC ON [dbo].rpc_GetClinicMedicalAspects TO PUBLIC
GO
