IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptRemark')
	BEGIN
		DROP  Procedure  rpc_insertDeptRemark
	END

GO

CREATE Procedure [dbo].[rpc_insertDeptRemark]
(
	@remarkDicID INT,
	@remarkText VARCHAR(500),
	@deptCode INT,
	@validFrom DATETIME,
	@validTo DATETIME,
	@ActiveFrom DATETIME,
	@displayInInternet BIT,
	@updateUser VARCHAR(50)
)
 
AS

IF @validFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validFrom = null
	END	

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validTo = null
	END	

IF @ActiveFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validTo = null
	END		

DECLARE @minShowOrder INT

SELECT @minShowOrder = MIN(ShowOrder) 
					FROM DeptRemarks
					WHERE DeptCode = @deptCode
IF @minShowOrder IS NULL
	SET @minShowOrder = 0

IF @ActiveFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @ActiveFrom = DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = @remarkDicID), @validFrom)
	END	

IF(@ActiveFrom < getdate()) BEGIN SET @ActiveFrom = getdate() END

UPDATE DeptRemarks
SET ShowOrder = ShowOrder + 1
WHERE DeptCode = @deptCode

INSERT INTO DeptRemarks
(DicRemarkID, RemarkText, DeptCode, ValidFrom, ValidTo,
				DisplayInInternet, ShowOrder, ActiveFrom, UpdateDate, UpdateUser)
VALUES
( @remarkDicID, @remarkText, @deptCode, @validFrom, @validTo, 
				@displayInInternet, @minShowOrder, @ActiveFrom, GetDate(), @updateUser)
GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\IntranetDev]
GO

