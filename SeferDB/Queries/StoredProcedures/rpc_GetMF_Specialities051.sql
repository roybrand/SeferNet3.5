--rpc_GetMF_Specialities051
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMF_Specialities051')
	BEGIN
		DROP  Procedure  rpc_GetMF_Specialities051
	END
GO

CREATE PROCEDURE [dbo].[rpc_GetMF_Specialities051]
	@Code int, 
	@Description varchar(500),
	@SelectedValues varchar(500)
AS
	SELECT DISTINCT
	ID,
	Code,
	Description,
	ShowInternet,
	DeleteFlg,
	Selected = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
	FROM MF_Specialities051
	LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedValues)) as sel ON MF_Specialities051.Code = sel.IntField
	WHERE (@Code is null OR Code = @Code)
	AND (@Description is null OR Description LIKE '%'+ @Description +'%')

	SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
	FROM SelectedElementsQuantityRestriction
	WHERE popupType = 16

GO


GRANT EXEC ON dbo.rpc_GetMF_Specialities051 TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetMF_Specialities051 TO [clalit\IntranetDev]
GO