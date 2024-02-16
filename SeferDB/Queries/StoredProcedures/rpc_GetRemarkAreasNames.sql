IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetRemarkAreasNames')
	BEGIN
		DROP  Procedure  rpc_GetRemarkAreasNames
	END

GO


create PROCEDURE dbo.rpc_GetRemarkAreasNames(@RelatedRemarkID int) 
AS
BEGIN
	SELECT dbo.rfn_GetRemarksAreasNames(@RelatedRemarkID)  as AreaName 
	from dbo.View_AllDistricts
	Where DistrictCode = 10000 
END
GO
 
 
grant exec on dbo.rpc_GetRemarkAreasNames to public 
go 