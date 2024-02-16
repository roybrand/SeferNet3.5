IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_TrackingChanges')
	BEGIN
		DROP  PROCEDURE  rprt_TrackingChanges
	END
GO

CREATE PROCEDURE [dbo].[rprt_TrackingChanges]
(
	@DistrictCodes varchar(200) = null,
	@AdminCode int = null,
	@DeptCodes varchar(max) = null,
	@EmployeeNames varchar(max) = null,
	@ChangeTypes varchar(max) = null,
	@UserNames varchar(max) = null,		
	@Remarks varchar(max) = null,	
	@Services varchar(max) = null,	
	@FromDateString varchar(20) = null,
	@ToDateString varchar(20) = null,
	@IsExcelVersion VARCHAR(2)= NULL
) 
AS 

DECLARE @FromDate smallDateTime
DECLARE @ToDate smallDateTime

SET DATEFORMAT dmy
IF ISDATE(@FromDateString) = 1
	SET @FromDate = convert(smallDateTime, @FromDateString, 103 )
ELSE
	SET @FromDate = null

IF ISDATE(@ToDateString) = 1
	SET @ToDate = convert(smallDateTime, @ToDateString, 103 )
ELSE
	SET @ToDate = null

SELECT * INTO #tmpSelectedDistricts FROM dbo.SplitString(@DistrictCodes)
SELECT * INTO #tmpSelectedDepts FROM dbo.SplitString(@DeptCodes)
SELECT * INTO #tmpSelectedServices FROM dbo.SplitString(@Services)
SELECT * INTO #tmpSelectedChangeTypes FROM dbo.SplitString(@ChangeTypes)
SELECT * INTO #tmpSelectedRemarks FROM dbo.SplitString(@Remarks)
SELECT * INTO #tmpSelectedUsers FROM dbo.SplitString(@UserNames)
SELECT * INTO #tmpSelectedEmployees FROM dbo.SplitString(@EmployeeNames)

SELECT L.UpdateDate, 
	CASE WHEN U.UserID IS NULL 
		THEN CAST(L.UpdateUser as varchar(10)) + ' שם לא ידוע ' 
		ELSE CAST(U.UserID as varchar(10)) + ' ' + U.FirstName + ' ' + U.LastName END as UpdateUser, 
	DIC.ChangeTypeDescription as ChangeType, Dist.DeptCode as DistrictCode, Dist.deptName as DistrictName, 
	ISNULL(Adm.deptCode, 0) as AdminClinicCode, ISNULL(Adm.deptName, '') as AdminClinicName, 
	Dept.DeptCode as ClinicCode, Dept.deptName as ClinicName, ES.EmployeeSectorDescription as EmployeeSector, 
	(E.lastName + ' ' + E.firstName) as EmployeeName,
	S.ServiceDescription as EmployeeService, Value as PreviousValue
FROM LogChange L
JOIN DIC_LogChangeType DIC ON L.ChangeTypeID = DIC.ChangeTypeID
JOIN Dept ON L.DeptCode = Dept.deptCode
JOIN Dept Dist ON Dept.districtCode = Dist.deptCode
LEFT JOIN Dept Adm ON Dept.administrationCode = Adm.deptCode
LEFT JOIN x_Dept_Employee xde ON L.DeptEmployeeID = xde.DeptEmployeeID
LEFT JOIN Employee E ON xde.employeeID = E.employeeID
LEFT JOIN EmployeeSector ES ON E.EmployeeSectorCode = ES.EmployeeSectorCode
LEFT JOIN [Services] S ON L.ServiceCode = S.ServiceCode
LEFT JOIN Users U ON L.UpdateUser = U.UserID

LEFT JOIN #tmpSelectedDistricts ON Dist.deptCode = #tmpSelectedDistricts.IntField
LEFT JOIN #tmpSelectedDepts ON Dept.deptCode = #tmpSelectedDepts.IntField
LEFT JOIN #tmpSelectedServices ON L.ServiceCode = #tmpSelectedServices.IntField
LEFT JOIN #tmpSelectedChangeTypes ON L.ChangeTypeID = #tmpSelectedChangeTypes.IntField
LEFT JOIN #tmpSelectedRemarks ON L.RemarkID = #tmpSelectedRemarks.IntField
LEFT JOIN #tmpSelectedUsers ON L.UpdateUser = #tmpSelectedUsers.IntField
LEFT JOIN #tmpSelectedEmployees ON xde.EmployeeID = #tmpSelectedEmployees.IntField

WHERE   (@DistrictCodes IS NULL OR @DistrictCodes = '-1' OR #tmpSelectedDistricts.IntField IS NOT NULL)
	AND (@AdminCode IS NULL OR @AdminCode = -1 OR Adm.deptCode = @AdminCode)
	AND (@DeptCodes IS NULL OR @DeptCodes = '-1' OR #tmpSelectedDepts.IntField IS NOT NULL)
	AND (@Services IS NULL OR @Services = '-1' OR #tmpSelectedServices.IntField IS NOT NULL)
	AND (@ChangeTypes IS NULL OR @ChangeTypes = '-1' OR #tmpSelectedChangeTypes.IntField IS NOT NULL)		
	AND (@Remarks IS NULL OR @Remarks = '-1' OR #tmpSelectedRemarks.IntField IS NOT NULL)
	AND (@UserNames IS NULL OR @UserNames = '-1' OR #tmpSelectedUsers.IntField IS NOT NULL)
	AND (@EmployeeNames IS NULL OR @EmployeeNames = '-1' OR #tmpSelectedEmployees.IntField IS NOT NULL)	
	AND (@FromDate IS NULL OR L.UpdateDate >= @FromDate)
	AND (@ToDate IS NULL OR L.UpdateDate <= @ToDate)				
	
GO


GRANT EXEC ON [dbo].rprt_TrackingChanges TO [clalit\webuser]
GO

GRANT EXEC ON [dbo].rprt_TrackingChanges TO [clalit\IntranetDev]
GO

