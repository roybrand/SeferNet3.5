IF EXISTS (SELECT * FROM sys.objects WHERE   name = 'rtr_MessageInfo')
	BEGIN
		DROP  trigger  rtr_MessageInfo
	END

GO

CREATE TRIGGER [dbo].[rtr_MessageInfo]
ON [dbo].[DIC_MessageInfo]
FOR INSERT,UPDATE
AS
begin
	
	------------------------** basic query of MessageInfo table ( must no be removed
	-- preventing spaces in the enumName column, because a C# enum will be generated from it
	 update mi
	 set mi.EnumName = REPLACE(mi.EnumName,' ','') 
	 from 
	 [dbo].DIC_MessageInfo as mi  inner join (select * from inserted) as  ins 
	 on mi.MessageInfoId = ins.MessageInfoId
	 -----------------------*** and basic
	 
	 ----------------------**extenstion query to support different languages
	 -- copy all messages to   MessageInfoLanguage table so it will be easier for
	 -- the user to enter them and traslate them to the other langauges              
      if exists (select * from sys.tables where name = 'MessageInfoApplicationLanguage')
      begin
        INSERT INTO [dbo].[MessageInfoApplicationLanguage]
           ([MessageInfoId]
           ,[MessageText]
           ,[ApplicationLanguageId])
        SELECT    ins.MessageInfoId, ins.UserMessageText, l.ApplicationLanguageId
		FROM         dbo.MessageInfoApplicationLanguage AS mil RIGHT OUTER JOIN
							  (select * from inserted) as  ins  ON mil.MessageInfoId = ins.MessageInfoId CROSS JOIN
							  dbo.ApplicationLanguage l 
		WHERE 1 = 1 
		and  (mil.MessageInfoId IS NULL)
		and  l.IsActive = 1 
		
			------------------------------updating only the hebrew as default line
		--save work to the user
			update mil
		 set   mil.MessageInfoId = ins.MessageInfoId
           ,mil.MessageText = ins.UserMessageText
           ,mil.ApplicationLanguageId = l.ApplicationLanguageId		
		FROM         dbo.MessageInfoApplicationLanguage AS mil RIGHT OUTER JOIN
							  (select * from inserted) as  ins 
							   ON mil.MessageInfoId = ins.MessageInfoId inner JOIN
							  dbo.ApplicationLanguage l on mil.ApplicationLanguageId = l.ApplicationLanguageId
		WHERE 1 = 1 
		and  l.languageDescription like '%עברית%'
		
	  end
	
end
 
go
