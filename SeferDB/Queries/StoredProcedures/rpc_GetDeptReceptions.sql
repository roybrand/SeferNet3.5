IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptReceptions')
	BEGIN
		DROP  Procedure  rpc_GetDeptReceptions
	END

GO

CREATE Procedure [dbo].[rpc_GetDeptReceptions]
(
	@deptCode int,
	@receptionHoursTypeID tinyint		
)
 
  
AS

SELECT  receptionID ,
  receptionDay, openingHour, closingHour, validFrom,validTo ,
v.RemarkID, RemarkText, EnableOverMidnightHours, rem.EnableOverlappingHours
FROM v_DeptReception v
LEFT JOIN DIC_GeneralRemarks rem ON v.RemarkID = rem.RemarkID
WHERE deptCode =  @deptCode AND  (validTo >= GETDATE() OR validTo IS NULL)
	And v.ReceptionHoursTypeID = @receptionHoursTypeID
ORDER BY receptionDay ,openingHour



SELECT 

openinghour, ClosingHour , remarkText, ValidFrom, ValidTo,  receptionDay,dense_rank() OVER (ORDER BY  

openinghour, ClosingHour,dayGroup) AS RecRank FROM 
(
SELECT 

openinghour, Closinghour , remarkText, ValidFrom, ValidTo, receptionDay,
sum(power(2,receptionDay-1)) OVER (partition BY 
openinghour,  CLOSINGhour, remarkText, ValidFrom, ValidTo ) dayGroup,
   COUNT(*) as nrecs 
FROM v_DeptReception
WHERE deptCode =  @deptCode   AND (validTo >= GETDATE() OR validTo IS NULL)
	And v_DeptReception.ReceptionHoursTypeID = @receptionHoursTypeID
GROUP BY  DeptCode, openinghour, CLOSINGhour, remarkText, ValidFrom, ValidTo, receptionDay) AS a 

GO


GRANT EXEC ON rpc_GetDeptReceptions TO PUBLIC

GO


