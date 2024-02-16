IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'VMessageInfoLanguages')
	BEGIN
		DROP  view  VMessageInfoLanguages
	END

GO


CREATE VIEW [dbo].[VMessageInfoLanguages]
AS
SELECT     dbo.MessageInfoApplicationLanguage.MessageInfoApplicationLanguageId, dbo.MessageInfoApplicationLanguage.MessageInfoId, dbo.MessageInfoApplicationLanguage.MessageText as LanguageMessageText, 
                      dbo.MessageInfoApplicationLanguage.ApplicationLanguageId, dbo.DIC_MessageInfo.UserMessageText, dbo.DIC_MessageInfo.SystemMessageText, 
                      dbo.DIC_MessageInfo.MessageCategoryId, dbo.DIC_MessageCategory.MessageCategoryDescription, dbo.ApplicationLanguage.LanguageDescription
FROM         dbo.DIC_MessageCategory INNER JOIN
                      dbo.DIC_MessageInfo ON dbo.DIC_MessageCategory.MessageCategoryId = dbo.DIC_MessageInfo.MessageCategoryId RIGHT OUTER JOIN
                      dbo.MessageInfoApplicationLanguage INNER JOIN
                      dbo.ApplicationLanguage ON dbo.MessageInfoApplicationLanguage.ApplicationLanguageId = dbo.ApplicationLanguage.ApplicationLanguageId AND dbo.ApplicationLanguage.IsActive = 1 ON 
                      dbo.DIC_MessageInfo.MessageInfoId = dbo.MessageInfoApplicationLanguage.MessageInfoId


GO

grant select on VMessageInfoLanguages to public 