IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeRemarksForUpdate')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeRemarksForUpdate
	END

GO

CREATE Procedure [dbo].[rpc_GetEmployeeRemarksForUpdate]
(
	@EmployeeID int
)
AS

-- Current Remarks 
SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, ActiveFrom, Internetdisplay, Deleted, 
AttributedToAllClinicsInCommunity as AttributedToAllClinics, AreasNames, DeptsCodes, RelevantForSystemManager, dicRemarkID, ShowForPreviousDays
FROM 
(
	SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, ActiveFrom, Internetdisplay, Deleted, 
	AttributedToAllClinicsInCommunity, AreasNames, DeptsCodes, RelevantForSystemManager, dicRemarkID, ShowForPreviousDays
	FROM(
			SELECT  DISTINCT 
				1 as RecordType,
				er.EmployeeRemarkID as RemarkID, 
				RemarkText as RemarkText,  
				CASE WHEN dgr.Remark  IS NOT NULL THEN dgr.Remark ELSE '' END AS RemarkTemplate, 
				convert(varchar, ValidFROM, 103) as ValidFROM,
				convert(varchar, ValidTo, 103)  as ValidTo,
				convert(varchar, ActiveFrom, 103) as ActiveFrom, 
				displayInInternet as Internetdisplay,
				0 as Deleted, 			
				AttributedToAllClinicsInCommunity, 
				dbo.fun_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID ) as AreasNames, 
				dbo.fun_GetEmployeeRemarkDeptsCodes(er.EmployeeRemarkID,@EmployeeID ) as DeptsCodes,
				IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager,
				dgr.RemarkID as dicRemarkID, dgr.ShowForPreviousDays
				
			FROM EmployeeRemarks as er 
			LEFT JOIN dbo.DIC_GeneralRemarks as dgr ON er.DicRemarkID = dgr.RemarkID 
			LEFT JOIN x_Dept_Employee_EmployeeRemarks as xder ON er.EmployeeRemarkID = xder.EmployeeRemarkID 
			WHERE (dbo.rfn_IsDatesCurrent(validFROM, validTo, GETDATE()) = 1 OR dbo.rfn_IsDatesCurrent(ActiveFrom, validTo, GETDATE()) = 1)
			AND er.EmployeeID = @EmployeeID 

		) as tblCurrent 
) as tblFinalCurrent 
ORDER BY RemarkText


-- Future Remarks 
SELECT RecordType, RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, ActiveFrom, Internetdisplay, Deleted, 
AttributedToAllClinicsInCommunity as AttributedToAllClinics, AreasNames, DeptsCodes, RelevantForSystemManager, dicRemarkID, ShowForPreviousDays
FROM 
(
	SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, ActiveFrom, Internetdisplay, Deleted, 
		AttributedToAllClinicsInCommunity, AreasNames, DeptsCodes, RelevantForSystemManager, dicRemarkID, ShowForPreviousDays
	FROM(
			SELECT  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
				CASE 
					WHEN dgr.Remark  is not null then dgr.Remark  
					ELSE '' 
				end as RemarkTemplate , convert(varchar, ValidFROM, 103) as ValidFROM, 
				convert(varchar, ValidTo, 103) as ValidTo,
				convert(varchar, ActiveFrom, 103) as ActiveFrom,
				displayInInternet as Internetdisplay, 0 as Deleted, 			
				AttributedToAllClinicsInCommunity, 
				dbo.fun_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
				dbo.fun_GetEmployeeRemarkDeptsCodes(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes,
				IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager,
				dgr.RemarkID as dicRemarkID, dgr.ShowForPreviousDays
			FROM EmployeeRemarks as er 
			LEFT JOIN dbo.DIC_GeneralRemarks as dgr ON er.DicRemarkID = dgr.RemarkID 
			LEFT JOIN x_Dept_Employee_EmployeeRemarks as xder ON er.EmployeeRemarkID = xder.EmployeeRemarkID 
			WHERE (ValidFROM > getdate() AND ActiveFrom > getdate())
			AND er.EmployeeID = @EmployeeID

		) as tblCurrent 
) as tblFinalCurrent 
ORDER BY RemarkText


-- Historic Remarks 
SELECT RecordType, RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, ActiveFrom, CAST(Internetdisplay as bit) as Internetdisplay, Deleted, 
	AttributedToAllClinicsInCommunity as AttributedToAllClinics, 
	CASE WHEN AttributedToAllClinicsInCommunity = 0 THEN AreasNames ELSE 'כל היחידות בקהילה' END as AreasNames, 
	CASE WHEN AttributedToAllClinicsInCommunity = 0 THEN DeptsCodes ELSE '-1' END as DeptsCodes, 
	RelevantForSystemManager, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkTextFormated, dicRemarkID, ShowForPreviousDays
FROM 
(
	SELECT RecordType, RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, ActiveFrom, Internetdisplay, Deleted, 
	AttributedToAllClinicsInCommunity, AreasNames, DeptsCodes, RelevantForSystemManager, dicRemarkID, ShowForPreviousDays
	FROM(
			SELECT  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
				CASE 
					WHEN dgr.Remark  is not null then dgr.Remark  
					ELSE '' 
				end as RemarkTemplate, convert(varchar, ValidFROM, 103) as ValidFROM, convert(varchar, ValidTo, 103) as ValidTo,
				convert(varchar,  ActiveFrom, 103) as  ActiveFrom,
				displayInInternet as Internetdisplay, 0 as Deleted , 			
				AttributedToAllClinicsInCommunity , 
				dbo.fun_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
				dbo.fun_GetEmployeeRemarkDeptsCodes(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes,
				IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager,
				dgr.RemarkID as dicRemarkID, dgr.ShowForPreviousDays
			FROM EmployeeRemarks as er 
			LEFT JOIN dbo.DIC_GeneralRemarks as dgr ON er.DicRemarkID = dgr.RemarkID 
			LEFT JOIN x_Dept_Employee_EmployeeRemarks as xDept ON er.EmployeeRemarkID = xDept.EmployeeRemarkID 
			WHERE DateDiff(day, ValidTo, getdate()) >= 1
			AND er.EmployeeID = @EmployeeID

		) as tblCurrent 
) as tblFinalCurrent 
ORDER BY RemarkText
GO

GRANT EXEC ON rpc_GetEmployeeRemarksForUpdate TO PUBLIC
GO
 