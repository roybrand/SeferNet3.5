--rpc_GetClinicTeamAgreementsInDept
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClinicTeamAgreementsInDept')
	BEGIN
		DROP  Procedure  rpc_GetClinicTeamAgreementsInDept
	END

GO

CREATE Procedure dbo.rpc_GetClinicTeamAgreementsInDept
(
	@DeptCode int
)

AS

SELECT IsCommunity, IsMushlam, IsHospital,
CASE WHEN (SELECT COUNT(*) FROM x_Dept_Employee
			JOIN DIC_AgreementTypes ON x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID
			WHERE employeeID = 1000000019 
			AND deptCode = d.deptCode
			AND DIC_AgreementTypes.OrganizationSectorID = 1) > 0 THEN 1 ELSE 0 END 
	as 'HasCommunityTeam',
CASE WHEN (SELECT COUNT(*) FROM x_Dept_Employee
			JOIN DIC_AgreementTypes ON x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID
			WHERE employeeID = 1000000019 
			AND deptCode = d.deptCode
			AND DIC_AgreementTypes.OrganizationSectorID = 2) > 0 THEN 1 ELSE 0 END 
	as 'HasMushlamTeam',
CASE WHEN (SELECT COUNT(*) FROM x_Dept_Employee
			JOIN DIC_AgreementTypes ON x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID
 			WHERE employeeID = 1000000019 
			AND deptCode = d.deptCode
			AND DIC_AgreementTypes.OrganizationSectorID = 3) > 0 THEN 1 ELSE 0 END 
	as 'HasHospitalTeam'		
FROM Dept d
WHERE d.deptCode = @DeptCode

GO

GRANT EXEC ON rpc_GetClinicTeamAgreementsInDept TO PUBLIC

GO
