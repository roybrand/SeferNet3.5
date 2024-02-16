IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertSweepingRemark')
	BEGIN
		DROP  Procedure  rpc_InsertSweepingRemark
	END

GO

CREATE Procedure dbo.rpc_InsertSweepingRemark
(
	@remarkDicID INT,
	@remarkText VARCHAR(500),
	@districtCode INT,
	@unitTypeCode INT,
	@subUnitTypeCode INT,
	@populationCode INT,
	@administrationCode INT,
	@validFrom DATETIME,
	@validTo DATETIME,
	@displayInInternet BIT,
	@increaseRelatedRemarkID BIT,
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

DECLARE @relatedRemark INT
IF @increaseRelatedRemarkID = 1 
	SELECT @relatedRemark = Max(RelatedRemarkID) + 1 FROM Remarks
ELSE
	SELECT @relatedRemark = Max(RelatedRemarkID) FROM Remarks
	
IF (@relatedRemark IS NULL)
	SET @relatedRemark = 1	


INSERT INTO Remarks
(DicRemarkID, RemarkText, RelatedRemarkID, DistrictCode, AdministrationCode, DeptCode, UnitTypeCode, SubUnitTypeCode, 
									PopulationSector, ValidFrom, ValidTo,DisplayInInternet, UpdateDate, UpdateUser)
VALUES
( @remarkDicID, @remarkText, @relatedRemark  , @districtCode , @administrationCode , -1, @unitTypeCode , @subUnitTypeCode,
									@populationCode , @validFrom, @validTo, @displayInInternet, GetDate(), @updateUser)

GO

GRANT EXEC ON rpc_InsertSweepingRemark TO PUBLIC

GO

