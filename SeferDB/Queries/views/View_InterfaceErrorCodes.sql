 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_InterfaceErrorCodes')
	BEGIN
		DROP  View View_InterfaceErrorCodes
	END
GO



create VIEW [dbo].[View_InterfaceErrorCodes]
AS
SELECT     ErrorDesc, ErrorCode
FROM         dbo.InterfaceErrorCodes
WHERE     (InterfaceType = 7) 

go