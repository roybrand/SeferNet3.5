IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateRelevantProfession')
	BEGIN
		DROP  Procedure  rpc_updateRelevantProfession
	END

GO

create Procedure [dbo].[rpc_updateRelevantProfession]
	(
		@code int, 	
		@name varchar(100),	
		@parentCode int,
		@oldCode   int,
		@oldCodeNew   int,
		@oldTable   varchar (50),
		@oldTableNew   varchar (50),
		@sectorCode varchar(30),
		@showExpert varchar (50),
		@flag int,
		@userName varchar (50)
	)

AS

IF @oldCode = -1
	BEGIN
		SET @oldCode = null
	END




----professions-------
 if(select count(professionCode) from [professions] where [professionCode] = @code ) > 0      
      begin      
      UPDATE [professions]       
      SET  [professionDescription] = @name ,
			[updateDate] = getdate(),					 
			[ShowExpert]= @showExpert  ,
			[updateUserName] = @userName
       WHERE [professionCode] =@code   
       end      
       else       
       begin      
		   INSERT INTO [professions]      
			( [professionCode] ,[professionDescription] ,     
			[updateDate],[updateUserName],[ShowExpert])      
			VALUES      
			( @code ,@name,  getdate() ,@userName ,	@showExpert) 		
         end 
         

------professionsParentChild-----------------------------------------------------                
		if (@parentCode <> -1 )
                BEGIN
					   IF(SELECT COUNT ([parentCode]) from professionsParentChild where [childCode] =@code ) = 0      
						   INSERT INTO professionsParentChild ([parentCode] ,[childCode])     
								VALUES (@parentCode ,@code)     
					   ELSE      
						   UPDATE [professionsParentChild]      
								SET [parentCode] = @parentCode   
								WHERE [childCode] = @code
								
						DELETE x_profession_SectorCode
						WHERE ProfessionCode = @code
						
						-- insert only the sectors that the parent profession has
						INSERT INTO x_profession_SectorCode (ProfessionCode, EmployeeSectorCode)
									SELECT @code, EmployeeSectorCode
									FROM dbo.SplitString(@sectorCode) as sectorCodes
									INNER JOIN x_profession_SectorCode xps ON sectorCodes.IntField = xps.EmployeeSectorCode
									INNER JOIN ProfessionsParentChild ppc ON xps.ProfessionCode = ppc.parentCode
									WHERE ppc.childCode = @code						
                END
           ELSE
				BEGIN
				
						DELETE FROM professionsParentChild      
						WHERE childCode = @code
						
						DELETE FROM x_profession_SectorCode      
						WHERE professionCode = @code
						
						
						-- if the current code has professions childs
						IF EXISTS 
						(
							SELECT * 
							FROM ProfessionsParentChild
							WHERE ParentCode = @code
						)
						BEGIN
							INSERT INTO x_profession_SectorCode (ProfessionCode, EmployeeSectorCode)
							SELECT DISTINCT @code, EmployeeSectorCode	
							FROM x_profession_SectorCode xps
								  INNER JOIN ProfessionsParentChild ppc ON xps.ProfessionCode = ppc.ChildCode
										AND ppc.ParentCode = @code
							
						END	
										
						INSERT INTO x_profession_SectorCode (ProfessionCode, EmployeeSectorCode)
							SELECT @code, IntField
							FROM  dbo.SplitString(@sectorCode) temp
							LEFT JOIN x_profession_SectorCode xps ON temp.IntField = xps.EmployeeSectorCode 
							AND @code = xps.ProfessionCode
							WHERE xps.ProfessionCode IS NULL
				END
			 
-----X_Professions_OldCodes -----------------------------------------------------------------
if(@oldCodeNew <> -1)
	begin			
			if(select count ([OldCode]) from X_Professions_OldCodes 
					where OldCode = @oldCode and code = @code and OldTable = @oldTable) = 0 
			begin
				
				INSERT INTO [X_Professions_OldCodes]
			   ([Code]
			   ,[OldCode]
			   ,[OldTable])
				 VALUES
				(@code,@oldCodeNew,@oldTableNew )
			end
			else
			begin
				UPDATE [X_Professions_OldCodes]      
				SET [Code] = @code 	,
				[OldCode] = @oldCodeNew	,
				[OldTable] = @oldTableNew 	
				WHERE [OldCode] = @oldCode and [OldTable] = @oldTable and [Code] = @code
			end								
			
		end
else
begin
	delete from X_Professions_OldCodes
		WHERE [OldCode] = @oldCode and [OldTable] = @oldTable and [Code] = @code
end

-----service---------------------------------
if (@flag  = 1)

begin
		print ('--Delete from service-- ')
       Delete from service   Where serviceCode = @code
	   Delete from dbo.serviceParentChild	where childCode	= @code	

----------X_Services_OldCodes-----------------------------------
		print ('X_Services_OldCodes ')
		if( select count (Code) from dbo.X_Services_OldCodes where Code = @code) > 0
			begin
			print ('delete from X_Services_OldCodes ')
			
			insert into X_Professions_OldCodes  (X_Professions_OldCodes.Code, X_Professions_OldCodes.OldCode,X_Professions_OldCodes.OldTable)
			SELECT Code, OldCode, OldTable
			FROM X_Services_OldCodes 
			WHERE X_Services_OldCodes.Code = @code
			and 
					(OldCode <> @oldCode 
					or [OldTable] <> @oldTable )
			end		
			delete from X_Services_OldCodes 
			WHERE Code = @code			
			end		
 


	
GO


GRANT EXEC ON dbo.rpc_updateRelevantProfession TO PUBLIC

GO

