  

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_deleteDeptEmployeeReceptionRemarks')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEmployeeReceptionRemarks
	END

GO


CREATE Procedure dbo.rpc_deleteDeptEmployeeReceptionRemarks
	(
		@DeptEmployeeReceptionRemarkID int,
		@errorCode int = 0 OUTPUT
	)

AS

SET @errorCode = 0

DECLARE @EnableOverlappingHours int

DECLARE @EmployeeReceptionID int
DECLARE	@DeptCode int
DECLARE	@EmployeeID int
DECLARE @cityCode int
DECLARE @StreetCode varchar(50)

DECLARE @disableBecauseOfOverlapping int


SET @EnableOverlappingHours = (SELECT EnableOverlappingHours FROM DeptEmployeeReceptionRemarks WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID)

-- If the remark is NOT of "EnableOverlappingHours" sort then there is no problem to delete it
IF (@EnableOverlappingHours = 0)
BEGIN
	DELETE FROM DeptEmployeeReceptionRemarks
	WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
	
	RETURN
END
-- If the remark to be removed is the sort of "EnableOverlappingHours"
-- we have to check what will happen with overlapping and, consequently, to permit or not permit the deletion
IF (@EnableOverlappingHours = 1)
BEGIN

	SET @EmployeeReceptionID = (SELECT EmployeeReceptionID FROM DeptEmployeeReceptionRemarks WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID)

-- If there are more remarks of "EnableOverlappingHours" sort but this one, then it's enough to just delete it
	IF((SELECT COUNT(*) FROM DeptEmployeeReceptionRemarks 
		WHERE EmployeeReceptionID = @EmployeeReceptionID AND DeptEmployeeReceptionRemarkID <> @DeptEmployeeReceptionRemarkID
		AND EnableOverlappingHours = 1 ) > 0)
	BEGIN
		DELETE FROM DeptEmployeeReceptionRemarks
		WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
		
		RETURN
	END
	-- Then we try to check if the overlaping situation will occur
	-- and if "yes" then @disableBecauseOfOverlapping = 1
	SET @disableBecauseOfOverlapping =
	
	(SELECT COUNT(*)
	FROM
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID = @EmployeeReceptionID) AS DER

	INNER JOIN 
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID <> @EmployeeReceptionID) AS DER2
		
		ON DER.EmployeeID = DER2.EmployeeID
		
	WHERE (DER.deptCode = DER2.deptCode 
		OR
		(DER.StreetCode IS NOT NULL AND DER2.StreetCode IS NOT NULL AND (DER.cityCode = DER2.cityCode AND DER.StreetCode = DER2.StreetCode))
		)
	AND DER.receptionDay = DER2.receptionDay
	AND NOT (
		(DER2.openingHour <= dER.openingHour AND DER2.closingHour <= dER.openingHour)
		OR 
		(DER2.openingHour >= dER.closingHour AND DER2.closingHour >= dER.closingHour)
		)
	AND DER2.disableBecauseOfOverlapping = 0
	)	
	+
	(SELECT COUNT(*)
	FROM
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID = @EmployeeReceptionID) AS DER

	INNER JOIN 
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID <> @EmployeeReceptionID) AS DER2
		
		ON DER.EmployeeID = DER2.EmployeeID
		
	WHERE (DER.deptCode <> DER2.deptCode 
			OR
			(DER.StreetCode IS NOT NULL AND DER2.StreetCode IS NOT NULL AND (DER.cityCode = DER2.cityCode AND DER.StreetCode <> DER2.StreetCode))
		)
	AND DER.receptionDay = DER2.receptionDay
	AND NOT (
		(DER2.openingHour < DER.openingHour AND 
			DATEDIFF(mi, CAST((CASE DER2.closingHour WHEN '24:00' THEN '23:59' ELSE DER2.closingHour END)as smalldatetime), CAST(DER.openingHour as smalldatetime) )>= 30 )
		OR 
		( DATEDIFF(mi, CAST((CASE DER.closingHour WHEN '24:00' THEN '23:59' ELSE DER.closingHour END)as smalldatetime), CAST(DER2.openingHour as smalldatetime) )>= 30 
			AND DER2.closingHour > DER.closingHour)
		)
	AND DER2.disableBecauseOfOverlapping = 0
	)	
	-- If "overlapping"	will take place then we DELETE from "DeptEmployeeReceptionRemarks"
	-- and UDATE "deptEmployeeReception": SET disableBecauseOfOverlapping = 1 
	IF(@disableBecauseOfOverlapping = 1)
		BEGIN
			UPDATE deptEmployeeReception
			SET disableBecauseOfOverlapping = @disableBecauseOfOverlapping
			WHERE receptionID = @EmployeeReceptionID
			
			DELETE FROM DeptEmployeeReceptionRemarks
			WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
		END 
	ELSE
		BEGIN
			DELETE FROM DeptEmployeeReceptionRemarks
			WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
		END	

	
END


GO


GRANT EXEC ON rpc_deleteDeptEmployeeReceptionRemarks TO PUBLIC
GO
   