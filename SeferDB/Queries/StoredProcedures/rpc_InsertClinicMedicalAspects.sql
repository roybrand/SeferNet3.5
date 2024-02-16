IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_InsertClinicMedicalAspects')
	BEGIN
		PRINT 'Dropping Procedure rpc_InsertClinicMedicalAspects'
		DROP  Procedure  rpc_InsertClinicMedicalAspects
	END
GO

CREATE Procedure [dbo].[rpc_InsertClinicMedicalAspects]
	(
		@DeptCode int,
		@MedicalAspectsList varchar(500),
		@UpdateUser varchar(50),
		@ErrorCode int = 0 OUTPUT
	)

AS
	
DECLARE @DistrictCode int 
SET @DistrictCode = (SELECT districtCode FROM Dept WHERE deptCode = @DeptCode)

INSERT INTO x_dept_medicalAspect
SELECT 
null as OldDeptCode, ItemID as MedicalAspectCode, @DistrictCode as HospitalCode, @DeptCode as NewDeptCode
FROM [dbo].[rfn_SplitStringByDelimiterValuesToInt](@MedicalAspectsList, ',')


SET @ErrorCode = @@ERROR

GO

GRANT EXEC ON rpc_InsertClinicMedicalAspects TO PUBLIC
GO
