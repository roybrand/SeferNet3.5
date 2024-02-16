IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptAndServicesRemarks')
	BEGIN
		DROP  View View_DeptAndServicesRemarks
	END
GO

CREATE VIEW [dbo].[View_DeptAndServicesRemarks]
AS
SELECT *
FROM         
(
-------------- dept Remarks ---------------
select 
View_DeptRemarks.deptCode,
serviceCode = null, 
serviceDescription = '',
View_DeptRemarks.DicRemarkID as remarkID,
replace(replace(View_DeptRemarks.RemarkText,'#', ''), '&quot;', char(34)) as RemarkText,
replace([dbo].[rfn_GetFotmatedRemark](View_DeptRemarks.RemarkText), '&quot;', char(34)) as RemarkTextFormatted,
View_DeptRemarks.validFrom,
View_DeptRemarks.validTo,

RemarkType = 1, -- dept Remarks
View_DeptRemarks.IsSharedRemark as IsSharedRemark,
case when View_DeptRemarks.validTo is null then 1 else 0 end as IsConstantRemark, 
View_DeptRemarks.displayInInternet,
case when  View_DeptRemarks.validFrom >= GETDATE() then 1 else 0 end as IsFutureRemark

from View_DeptRemarks
/*	
union

-------------- dept Services Remarks ---------------	
select 
xDE.deptCode,
xDES.ServiceCode,
Services.serviceDescription,
DESR.remarkID,
replace(replace(DESR.RemarkText,'#', ''), '&quot;', char(34))as RemarkText,
replace([dbo].[rfn_GetFotmatedRemark](DESR.RemarkText), '&quot;', char(34)) as RemarkTextFormatted,
DESR.ValidFrom,
DESR.ValidTo,

RemarkType = 4, -- dept Services Remarks
IsSharedRemark = 0,
case when DESR.validTo is null then 1 else 0 end as IsConstantRemark, 
DESR.displayInInternet,
case when  DESR.validFrom >= GETDATE() then 1 else 0 end as IsFutureRemark

from x_Dept_Employee xDE
 join x_Dept_Employee_Service xDES on xDE.DeptEmployeeID = xDES.DeptEmployeeID
 join Services on xDES.serviceCode = Services.serviceCode
 join DeptEmployeeServiceRemarks DESR on xDES.x_Dept_Employee_ServiceID = DESR.x_dept_employee_serviceID
*/ 
) as resultTable



GO

grant select on View_DeptAndServicesRemarks to public 

GO



