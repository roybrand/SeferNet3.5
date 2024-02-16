IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateRelevantService')
	BEGIN
		DROP  Procedure  rpc_updateRelevantService
	END

GO

/****** Object:  StoredProcedure [dbo].[rpc_updateRelevantService]    Script Date: 11/08/2009 16:45:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.rpc_updateRelevantService
	(
		@code int, 	
		@name varchar(100),	
		@parentCode int,
		@oldCode   int,
		@oldCodeNew   int,
		@oldTable   varchar (50),
		@oldTableNew   varchar (50),		
		@flag int,
		@userName   varchar (50),
		@ErrorStatus int output
	)

AS
DECLARE @Err int, @Count int
SET @Err = 0
SET @Count = 0
SET @ErrorStatus = 0

IF @oldCode = -1
	BEGIN
		SET @oldCode = null
	END


----service-------
 if(select count(serviceCode) from [service] where [serviceCode] = @code ) > 0      
      begin      
      UPDATE [service]       
      SET  [serviceDescription] = @name ,
			[updateDate] = getdate(),
			[updateUserName] = @userName					
       WHERE [serviceCode] =@code   
       end      
       else       
       begin      
		   INSERT INTO [service]      
			( [serviceCode] ,[serviceDescription] ,     
			[updateDate],[updateUserName] 			
			)      
			VALUES      
			( @code ,@name,  getdate() ,@userName ) 		
         end 

------serviceParentChild-----------------------------------------------------                
		if (@parentCode <> -1 )
                begin
						print ('INSERT INTO serviceParentChild')
					   if(select count ([childCode]) from serviceParentChild where [childCode] =@code ) = 0      
						   INSERT INTO serviceParentChild ([parentCode] ,[childCode])     
								VALUES (@parentCode ,@code)     
					   else      
						   UPDATE [serviceParentChild]      
								SET [parentCode] = @parentCode   
								WHERE [childCode] = @code					
                end
           else
				begin
						print (' Delete from serviceParentChild ')	
						  Delete from serviceParentChild     
										Where childCode =@code
				end
-----dbo.X_Services_OldCodes -----------------------------------------------------------------
if(@oldCodeNew <> -1)
	begin
		print ('--insert into new record X_Services_OldCodes-- ')
			
			if(select count ([OldCode]) from X_Services_OldCodes 
					where OldCode = @oldCode and code = @code and OldTable = @oldTable) = 0 
			begin
				print('insert')
				INSERT INTO [X_Services_OldCodes]
			   ([Code]
			   ,[OldCode]
			   ,[OldTable])
				 VALUES
				(@code,@oldCodeNew,@oldTableNew )
			end
			else
			begin
				print('UPDATE')
				UPDATE [X_Services_OldCodes]      
				SET [Code] = @code 	,
				[OldCode] = @oldCodeNew	,
				[OldTable] = @oldTableNew 	
				WHERE [OldCode] = @oldCode and [OldTable] = @oldTable and [Code] = @code
			end								
			
		end
else
begin
	delete from X_Services_OldCodes
		WHERE [OldCode] = @oldCode and [OldTable] = @oldTable and [Code] = @code
end

-----service---------------------------------
if (@flag  = 1)

begin
		print ('--Delete from professions-- ')
       Delete from  professions  Where  professionCode= @code
	   Delete from professionsParentChild	where childCode	= @code	

------------dbo.X_Professions_OldCodes---------------------------------
		print ('dbo.X_Professions_OldCodes ')
		if( select count (Code) from X_Professions_OldCodes where Code = @code) > 0
			begin
			print ('insert into X_Services_OldCodes old records and delete from X_Professions_OldCodes ')
			
			insert into  X_Services_OldCodes (X_Services_OldCodes.Code, X_Services_OldCodes.OldCode,X_Services_OldCodes.OldTable)
			SELECT Code, OldCode, OldTable
			FROM X_Professions_OldCodes 
			WHERE X_Professions_OldCodes.Code = @code
			and 
					(OldCode <> @oldCode 
					or [OldTable] <> @oldTable )
			end	
			print('delete from X_Professions_OldCodes ')	
			delete from X_Professions_OldCodes 
			WHERE Code = @code			
			end		
 

GO


GRANT EXEC ON rpc_updateRelevantService TO PUBLIC



