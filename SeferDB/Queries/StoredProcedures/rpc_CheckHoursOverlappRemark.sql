
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_checkHoursOverlappRemark')
	BEGIN
		PRINT 'Dropping Procedure rpc_checkHoursOverlappRemark'
		DROP  Procedure  rpc_checkHoursOverlappRemark
	END

GO

PRINT 'Creating Procedure rpc_checkHoursOverlappRemark'
GO     
-- gets comma seperated remark id's in the format "x,y,x,y" - where x is the remarkId and y is dept code

CREATE Procedure [dbo].[rpc_checkHoursOverlappRemark]
(
	@commaSeperatedValues  VARCHAR(MAX)
)

AS

SELECT dic.RemarkID, EnableOverlappingHours
FROM dbo.SplitStringToTable(@commaSeperatedValues) AS vals
INNER JOIN DIC_GeneralRemarks dic on vals.RemarkID = dic.RemarkID


SELECT distinct vals.DeptCode, Dept.StreetCode, Dept.CityCode, Dept.House
FROM dbo.SplitStringToTable(@commaSeperatedValues) AS vals
LEFT JOIN DEPT ON vals.DeptCode = Dept.DeptCode

GO


GRANT EXEC ON rpc_checkHoursOverlappRemark TO PUBLIC
              GO
   