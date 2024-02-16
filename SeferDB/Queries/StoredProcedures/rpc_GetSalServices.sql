IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetSalServices]') AND type in (N'P', N'PC'))
	BEGIN
		DROP  Procedure  [dbo].rpc_GetSalServices
	END

GO

CREATE Procedure [dbo].[rpc_GetSalServices]
(
@IncludeInBasket int = null ,				-- בסל
@Common tinyint = null ,					-- שכיח 
@ShowServiceInInternet tinyint = null ,		-- הצגה באינטרנט
@IsActive TinyInt = Null ,
@IsLoggedIn Bit ,
@SearchText VARCHAR(100) = null	,			-- חיפוש מורחב
@ServiceCode Int = null ,					-- קוד שירות כללית
@ServiceDescription varchar(300) = null ,	-- טקסט חיפוש שירות כללית
@healthOfficeCode VARCHAR(100) = null ,		-- קוד משרד בריאות
@healthOfficeDescription VARCHAR(100)=null,	-- טקסט חיפוש משרד בריאות
@GroupsCodes varchar(500) = null		,	-- רשימת קודי מקצוע
@ProfessionsCodes varchar(500)= null	,	-- רשימת קודי מקצוע
@OmriReturnCodes Varchar(300) = null ,		-- רשימת קודי החזר עומרי
@ICD9Code varchar(500) ,					-- קוד חיפוש ICD9
@PopulationCodes VarChar(500) = null , 		-- רשימת קודי אוכלוסייה
@SalCategoryID Int = null ,					-- תחום שירות לאינטרנט
@SalOrganCode Int = null ,					-- איבר גוף של השרות לאינטרנט
@BaskteApproveFromDate DateTime = null ,	-- עודכנו - מתאריך
@BaskteApproveToDate DateTime = null ,		-- עודכנו - עד תאריך
@ADD_DATE_FromDate DateTime = Null ,		-- נוספו - מתאריך
@ADD_DATE_ToDate DateTime = Null ,			-- נוספו - עד תאריך
@ShowCanceledServices Bit ,					-- האם להציג שרותים מבוטלים
@DEL_DATE_FromDate DateTime = Null , 		-- בוטלו - מתאריך
@DEL_DATE_ToDate DateTime = Null ,			-- בוטלו - עד תאריך
@InternetUpdatedFromDate DateTime = null ,	-- עודכן לאינטרנט - מתאריך
@InternetUpdatedToDate DateTime = null		-- עודכן לאינטרנט - עד תאריך
)	
AS

DECLARE @Today date SET @Today = GETDATE()

IF ((@ServiceCode is NOT null AND @ServiceCode <> 0) OR (@healthOfficeCode is NOT null AND Len(@healthOfficeCode) <> 0))
	BEGIN
		Select	SALS.ServiceCode , SALS.ServiceName , SALS.MIN_CODE , SALS.IncludeInBasket , SALS.Limiter , SALS.Common , 
				SP.[Professions] As ProfessionDesc , SALS.FormCode
				, SALS.IsCanceled , BC.[Description] As BudgetCard , C.[Description] As EshkolDesc , 
				PR.Description2 As PaymentRules , HealthGov.[Description] As HealthOfficeDescription , 
				Case When (Comments.TotalLines Is Not Null And Comments.TotalLines > 0 ) Then 1 Else 0 End As  HasComments ,
				SDI.ShowServiceInInternet , SDI.UpdateComplete
				--0 As HasComments
		From MF_SalServices386 SALS
		Left Join MF_HealthGov478 HealthGov On HealthGov.GoVCode = SALS.MIN_CODE And HealthGov.DELFL = 0
		Join (	SELECT profServices.ServiceCode , STUFF((	SELECT ', ' + P.[Description]
																FROM MF_Professions P
																JOIN MF_ServiceProfessions SP ON SP.ProfessionCode = P.Code
																WHERE	SP.ProfessionCode = P.Code And SP.Code = profServices.ServiceCode And
																		SP.LogicalDelete = 0 And P.LogicalDelete = 0 And
																		( @ProfessionsCodes Is Null Or Len(@ProfessionsCodes) = 0 Or P.Code In ( SELECT CONVERT( Int , ItemID ) 
																																				FROM dbo.SplitStringNoOrder(@ProfessionsCodes) ) )
																FOR XML PATH('') ), 1, 1, '') as Professions
					FROM MF_SalServices386 profServices
					/*Where profServices.IsCanceled = 0 And profServices.IsCanceled = 0*/ ) SP 
						On SP.ServiceCode = SALS.ServiceCode
						AND (@ProfessionsCodes Is Null Or Len(@ProfessionsCodes) = 0 OR SP.Professions is not null)

		Left Join MF_BudgetCards BC On BC.Code = SALS.BudgetCard And BC.LogicalDelete = 0
		Left Join MF_PaymentsRules PR On PR.Code = SALS.Pay_Rul And PR.LogicalDelete = 0
		Left Join MF_Cluster C On C.Code = SALS.Eshkol And C.LogicalDelete = 0
		Left Join ( Select Code , Count(ID) As TotalLines 
					From MF_Comments388
					Group By Code ) Comments On Comments.Code = SALS.ServiceCode
		Left Join SalServiceDetailsForInternet SDI On SDI.ServiceCode = SALS.ServiceCode
		WHERE ((@ServiceCode is null OR @ServiceCode = 0) AND SALS.MIN_CODE = @healthOfficeCode)
		OR ((@healthOfficeCode is null OR @healthOfficeCode = '') AND SALS.ServiceCode = @ServiceCode)
		Order By SALS.ServiceCode

	END
ELSE
	BEGIN
		IF (@ICD9Code Is NOT Null AND Len(@ICD9Code)> 0) 
			BEGIN
				SELECT ItemID 
				INTO #ICD9codeList
				FROM dbo.rfn_SplitStringValuesToStr(@ICD9Code)
			
				--*********************
				SELECT HospitalServiceCode 
				INTO #INTERMEDIATE_ICD9Code 
				FROM	(
						Select HospitalServiceCode
						From MF_XrefInsuranceICD435
						JOIN #ICD9codeList ON #ICD9codeList.ItemID = MF_XrefInsuranceICD435.DiagnosisCode
						Where Cancel = 0
						--and ModishRecord = 1
						and( ToDate >= GetDate() OR ToDate is null)
						and type = 'ב' 
						
						UNION 
						
						SELECT t435.HospitalServiceCode
						FROM MF_XrefInsuranceICDGroup436 t436
						LEFT JOIN MF_XrefInsuranceICD435 t435
							ON (t436.GroupNumber = t435.GroupCode and t435.GroupCode <> 0)
						JOIN #ICD9codeList ON #ICD9codeList.ItemID = t436.DiagnosisCode
							
						WHERE t436.Cancel = 0 and (t435.cancel is null or t435.cancel = 0)
						--and t436.HospitalServiceCode <> 0
						and t436.fromDate <= GetDate() and ( t435.ToDate >= GetDate() OR t435.ToDate is null) 
						) T
				--*********************	
				Select	SALS.ServiceCode , SALS.ServiceName , SALS.MIN_CODE , SALS.IncludeInBasket , SALS.Limiter , SALS.Common , 
						SP.[Professions] As ProfessionDesc , SALS.FormCode
						, SALS.IsCanceled , BC.[Description] As BudgetCard , C.[Description] As EshkolDesc , 
						PR.Description2 As PaymentRules , HealthGov.[Description] As HealthOfficeDescription , 
						Case When (Comments.TotalLines Is Not Null And Comments.TotalLines > 0 ) Then 1 Else 0 End As HasComments ,
						SDI.ShowServiceInInternet , SDI.UpdateComplete
						--0 As HasComments
				From MF_SalServices386 SALS
				INNER JOIN #INTERMEDIATE_ICD9Code ON SALS.ServiceCode = #INTERMEDIATE_ICD9Code.HospitalServiceCode
				Left Join MF_HealthGov478 HealthGov On HealthGov.GoVCode = SALS.MIN_CODE And HealthGov.DELFL = 0
				Join (	SELECT profServices.ServiceCode , STUFF((	SELECT ', ' + P.[Description]
																		FROM MF_Professions P
																		JOIN MF_ServiceProfessions SP ON SP.ProfessionCode = P.Code
																		WHERE	SP.ProfessionCode = P.Code And SP.Code = profServices.ServiceCode And
																				SP.LogicalDelete = 0 And P.LogicalDelete = 0 And
																				( @ProfessionsCodes Is Null Or Len(@ProfessionsCodes) = 0 Or P.Code In ( SELECT CONVERT( Int , ItemID ) 
																																						FROM dbo.SplitStringNoOrder(@ProfessionsCodes) ) )
																		FOR XML PATH('') ), 1, 1, '') as Professions
							FROM MF_SalServices386 profServices
							/*Where profServices.IsCanceled = 0 And profServices.IsCanceled = 0*/ ) SP 
								On SP.ServiceCode = SALS.ServiceCode
								AND (@ProfessionsCodes Is Null Or Len(@ProfessionsCodes) = 0 OR SP.Professions is not null)

				Left Join MF_BudgetCards BC On BC.Code = SALS.BudgetCard And BC.LogicalDelete = 0
				Left Join MF_PaymentsRules PR On PR.Code = SALS.Pay_Rul And PR.LogicalDelete = 0
				Left Join MF_Cluster C On C.Code = SALS.Eshkol And C.LogicalDelete = 0
				Left Join ( Select Code , Count(ID) As TotalLines 
							From MF_Comments388
							Group By Code ) Comments On Comments.Code = SALS.ServiceCode
				Left Join SalServiceDetailsForInternet SDI On SDI.ServiceCode = SALS.ServiceCode
				WHERE 
						( @IncludeInBasket Is null Or 
							@IncludeInBasket = 4 Or  
						( @IncludeInBasket=1 And SALS.IncludeInBasket = 1 ) Or
						( @IncludeInBasket=0 And SALS.IncludeInBasket = 0 And Limiter = 0 ) Or
						( @IncludeInBasket=3 And SALS.IncludeInBasket = 0 And Limiter > 0 ) Or
						( @IncludeInBasket=2 And (SALS.IncludeInBasket = 1 Or Limiter > 0 ) ) )
							
					AND ( @Common Is Null Or @Common = 3 Or SALS.Common = @Common ) 
					AND ( @ShowServiceInInternet Is Null Or @ShowServiceInInternet = 3  Or 
						(SDI.ShowServiceInInternet = @ShowServiceInInternet Or (@ShowServiceInInternet=0 And SDI.ShowServiceInInternet Is Null ) )  ) 
					AND  		
						( @IsActive Is Null Or @IsActive = 3 Or ( @IsActive = 1 And IsCanceled = 0 AND (SALS.DEL_DATE Is Null OR SALS.DEL_DATE > @Today)) Or ( @IsActive = 0 And (SALS.DEL_DATE Is Not Null OR IsCanceled = 1) ) ) 

					--AND ( ( @healthOfficeCode Is Null Or Len(@healthOfficeCode) = 0 Or MIN_CODE = @healthOfficeCode  )-- Or 
					--	 ) 
					AND ( @GroupsCodes Is Null Or Len(@GroupsCodes) = 0 Or SALS.GroupCode in ( SELECT CONVERT( Int , ItemID ) FROM dbo.SplitStringNoOrder(@GroupsCodes)) )  
					AND ( @OmriReturnCodes Is Null Or Len(@OmriReturnCodes) = 0 Or SALS.ServiceCode in (Select AscriptionToCodeTariff 
																										From MF_OmriReturns536 
																										Where ReturnCode In (	SELECT ItemID
																																FROM dbo.SplitStringNoOrder(@OmriReturnCodes) ) ) ) 
					AND ( @PopulationCodes Is Null Or Len(@PopulationCodes) = 0 Or SALS.ServiceCode in (Select ServiceCode
																										From MF_ServicesTariff210 
																										Where PopulationSubCode = 0 And PopulationCode In ( SELECT ItemID 
																																							FROM dbo.SplitStringNoOrder(@PopulationCodes) ) ) ) 
					AND ( @SalCategoryID Is Null Or @SalCategoryID <= 0 Or SALS.ServiceCode in (Select sp.Code 
																								From MF_ServiceProfessions sp
																								Join SalProfessionToCategory spc on spc.ProfessionCode = sp.ProfessionCode
																								Where spc.SalCategoryID = @SalCategoryID And sp.LogicalDelete = 0 ) ) 
					AND ( @SalOrganCode Is Null Or @SalOrganCode <= 0 Or SALS.ServiceCode in ( Select ssd.ServiceCode 
																							 From SalServiceDetailsForInternet ssd
																							 Where ssd.SalOrganCode = @SalOrganCode ) ) 
					AND	  -- Advance Search - Start
					  ( @SearchText Is null Or Len(@SearchText)=0 Or ServiceName Like '%'+@SearchText+'%' Or Synonym1 Like '%'+@SearchText+'%' Or Synonym2 Like '%'+@SearchText+'%' Or 
						Synonym3 Like '%'+@SearchText+'%' Or Synonym4 Like '%'+@SearchText+'%' Or Synonym5 Like '%'+@SearchText+'%' Or HealthGov.[Description] Like '%'+@SearchText+'%' Or
						EngName LIKE '%'+@SearchText+'%' OR
						SALS.ServiceCode In ( Select Distinct Code From MF_Comments388 Where Description Like '%'+@SearchText+'%' ) Or
						SALS.ServiceCode In ( Select Distinct Code from MF_Guidances388 Where	Diagnostics Like '%'+@SearchText+'%' Or Age Like '%'+@SearchText+'%' Or 
																								ClalitFacility Like '%'+@SearchText+'%' Or Publicfacility Like '%'+@SearchText+'%' Or 
																								treatment Like '%'+@SearchText+'%' Or Comment Like '%'+@SearchText+'%' ) ) 
					  -- Advance Search - End	
					  -- Date Filter - Start
					AND	( @BaskteApproveFromDate Is Null Or SALS.BaskteApproveDate >= @BaskteApproveFromDate Or CONVERT(Varchar,SALS.BaskteApproveDate,107) = CONVERT(Varchar,@BaskteApproveFromDate,107) ) 
					AND ( @BaskteApproveToDate Is Null Or SALS.BaskteApproveDate <= @BaskteApproveToDate Or CONVERT(Varchar,SALS.BaskteApproveDate,107) = CONVERT(Varchar,@BaskteApproveToDate,107) ) 
					AND ( @ADD_DATE_FromDate Is Null Or SALS.ADD_DATE >= @ADD_DATE_FromDate Or CONVERT(Varchar,SALS.ADD_DATE,107) = CONVERT(Varchar,@ADD_DATE_FromDate,107) ) 
					AND ( @ADD_DATE_ToDate Is Null Or SALS.ADD_DATE <= @ADD_DATE_ToDate Or CONVERT(Varchar,SALS.ADD_DATE,107) = CONVERT(Varchar,@ADD_DATE_ToDate,107) ) 
					AND (@ShowCanceledServices = 0 Or SALS.IsCanceled = 1 ) 
					AND ( @DEL_DATE_FromDate Is Null Or SALS.DEL_DATE >= @DEL_DATE_FromDate Or 
								CONVERT(Varchar,SALS.DEL_DATE,107) = CONVERT(Varchar,@DEL_DATE_FromDate,107) ) 
					AND ( @DEL_DATE_ToDate Is Null Or SALS.DEL_DATE <= @DEL_DATE_ToDate Or 
								CONVERT(Varchar,SALS.DEL_DATE,107) = CONVERT(Varchar,@DEL_DATE_ToDate,107) ) 
					AND ( @InternetUpdatedFromDate Is Null Or SDI.UpdateDate >= @InternetUpdatedFromDate Or CONVERT(Varchar,SDI.UpdateDate,107) = CONVERT(Varchar,@InternetUpdatedFromDate,107) ) 
					AND ( @InternetUpdatedToDate Is Null Or SDI.UpdateDate <= @InternetUpdatedToDate Or CONVERT(Varchar,SDI.UpdateDate,107) = CONVERT(Varchar,@InternetUpdatedToDate,107) )
					  -- Date Filter - End

				Order By SALS.ServiceCode

			END
		ELSE
			BEGIN
				DECLARE @params nvarchar(max)
				DECLARE @Declarations nvarchar(max)
				DECLARE @SqlSelect nvarchar(max)
				DECLARE @SqlINTERMEDIATE nvarchar(max) = ''
				--DECLARE @SqlINTERMEDIATE_TextSearch nvarchar(max) = ''
				
				DECLARE @SqlEnd nvarchar(max)

				DECLARE @SqlWhere nvarchar(max)
				
				SET @Declarations = 
'				DECLARE @xToday date SET @xToday = GETDATE()

'
				
--# TEMP TABLES	
				SET @SqlINTERMEDIATE = ''
				IF (@ProfessionsCodes Is NOT Null AND Len(@ProfessionsCodes) <> 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE +
'				SELECT CONVERT( Int, ItemID ) as ItemID 
				INTO #INTERMEDIATE_ProfessionsCodes 
				FROM dbo.SplitStringNoOrder(@xProfessionsCodes)
					
'
				IF (@SearchText Is NOT null AND Len(@SearchText) > 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE +
'				
				Select Code 
				INTO #INTERMEDIATE_TextSearch
				FROM
				(Select Distinct Code From MF_Comments388 Where Description Like ''%''+@xSearchText+''%''
				UNION 
				Select Distinct Code from MF_Guidances388 Where	Diagnostics Like ''%''+@xSearchText+''%'' Or Age Like ''%''+@xSearchText+''%'' Or 
																ClalitFacility Like ''%''+@xSearchText+''%'' Or Publicfacility Like ''%''+@xSearchText+''%'' Or 
																treatment Like ''%''+@xSearchText+''%'' Or Comment Like ''%''+@xSearchText+''%'') as T
'
				IF (@GroupsCodes Is NOT Null AND Len(@GroupsCodes) > 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE + 
'
				SELECT CONVERT( Int, ItemID ) as ItemID 
				INTO #INTERMEDIATE_GroupsCodes
				FROM dbo.SplitStringNoOrder(@xGroupsCodes)
'
				IF (@OmriReturnCodes Is NOT Null AND Len(@OmriReturnCodes) > 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE + 					
'
				SELECT AscriptionToCodeTariff
				INTO #INTERMEDIATE_AscriptionToCodeTariff
				FROM MF_OmriReturns536 
				Where ReturnCode In (SELECT ItemID FROM dbo.SplitStringNoOrder(@xOmriReturnCodes) ) 
'
				IF (@PopulationCodes Is NOT Null AND Len(@PopulationCodes) > 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE + 	
'
				SELECT ServiceCode
				INTO #INTERMEDIATE_PopulationCodes
				FROM MF_ServicesTariff210 
				WHERE PopulationSubCode = 0 
				And PopulationCode In (SELECT ItemID FROM dbo.SplitStringNoOrder(@xPopulationCodes) ) 
'
				IF (@SalCategoryID Is NOT Null AND @SalCategoryID > 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE + 	
'
				SELECT sp.Code
				INTO #INTERMEDIATE_SalCategory
				FROM MF_ServiceProfessions sp
				JOIN SalProfessionToCategory spc ON spc.ProfessionCode = sp.ProfessionCode
				WHERE spc.SalCategoryID = @xSalCategoryID And sp.LogicalDelete = 0  
'
				IF (@SalOrganCode Is NOT Null AND @SalOrganCode > 0)
					SET @SqlINTERMEDIATE = @SqlINTERMEDIATE + 	
'
				SELECT ssd.ServiceCode
				INTO #INTERMEDIATE_SalOrganCode
				FROM SalServiceDetailsForInternet ssd
				WHERE ssd.SalOrganCode = @xSalOrganCode 
'

--#END TEMP TABLES					
				
				SET @SqlSelect =
'				SELECT SALS.ServiceCode, SALS.ServiceName, SALS.MIN_CODE, SALS.IncludeInBasket, SALS.Limiter, SALS.Common, 
				SP.[Professions] As ProfessionDesc, SALS.FormCode,
				SALS.IsCanceled, BC.[Description] As BudgetCard, C.[Description] As EshkolDesc, 
				PR.Description2 As PaymentRules, HealthGov.[Description] As HealthOfficeDescription, 
				Case When (Comments.TotalLines Is Not Null And Comments.TotalLines > 0 ) Then 1 Else 0 End As HasComments,
				SDI.ShowServiceInInternet, SDI.UpdateComplete
						 
				FROM MF_SalServices386 SALS	
				LEFT JOIN MF_HealthGov478 HealthGov On HealthGov.GoVCode = SALS.MIN_CODE And HealthGov.DELFL = 0
'
									
				SET @SqlSelect = @SqlSelect +
'				JOIN (	SELECT profServices.ServiceCode, STUFF((SELECT '', '' + P.[Description]
																FROM MF_Professions P
																JOIN MF_ServiceProfessions SP ON SP.ProfessionCode = P.Code 
'
				IF (@ProfessionsCodes Is NOT Null AND Len(@ProfessionsCodes) <> 0)
					SET @SqlSelect = @SqlSelect + 
'																JOIN #INTERMEDIATE_ProfessionsCodes ON #INTERMEDIATE_ProfessionsCodes.ItemID = P.Code 
'
					SET @SqlSelect = @SqlSelect + 																			
'																WHERE SP.Code = profServices.ServiceCode 
																AND SP.LogicalDelete = 0 And P.LogicalDelete = 0
																FOR XML PATH('''') ), 1, 1, '''') as Professions
																FROM MF_SalServices386 profServices ) SP
							On SP.ServiceCode = SALS.ServiceCode '
				IF (@ProfessionsCodes Is NOT Null AND Len(@ProfessionsCodes) <> 0)
					SET @SqlSelect = @SqlSelect + ' AND SP.Professions is not null '
																												
				SET @SqlSelect = @SqlSelect + 	
'
				Left Join MF_BudgetCards BC On BC.Code = SALS.BudgetCard And BC.LogicalDelete = 0
				Left Join MF_PaymentsRules PR On PR.Code = SALS.Pay_Rul And PR.LogicalDelete = 0
				Left Join MF_Cluster C On C.Code = SALS.Eshkol And C.LogicalDelete = 0
				Left Join ( Select Code, Count(ID) As TotalLines 
							From MF_Comments388
							Group By Code ) Comments On Comments.Code = SALS.ServiceCode
				Left Join SalServiceDetailsForInternet SDI On SDI.ServiceCode = SALS.ServiceCode
'				
								 
				SET @SqlWhere =	
'				WHERE 1=1
'
				IF @IncludeInBasket=1
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.IncludeInBasket = 1
'
				IF @IncludeInBasket=0
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.IncludeInBasket = 0 And Limiter = 0
'
				IF @IncludeInBasket=3
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.IncludeInBasket = 0 And Limiter > 0
'
				IF @IncludeInBasket=2
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.IncludeInBasket = 1 And Limiter > 0
'
				IF ( @Common Is NOT Null AND @Common <> 3 ) 
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.Common = @xCommon
'	
				IF (@ShowServiceInInternet Is NOT Null AND @ShowServiceInInternet <> 3 AND @ShowServiceInInternet <> 0) 
					SET @SqlWhere =	@SqlWhere + 
'				AND SDI.ShowServiceInInternet = @xShowServiceInInternet
'
				IF (@ShowServiceInInternet = 0) 
					SET @SqlWhere =	@SqlWhere + 
'				AND SDI.ShowServiceInInternet Is Null
'
				IF (@IsActive Is NOT Null AND @IsActive <> 3 AND @IsActive = 1) 
					SET @SqlWhere =	@SqlWhere + 
'				AND IsCanceled = 0 AND (SALS.DEL_DATE Is Null OR SALS.DEL_DATE > @xToday)
'				
				IF (@IsActive = 0) 
					SET @SqlWhere =	@SqlWhere + 
'				AND (SALS.DEL_DATE Is Not Null OR IsCanceled = 1)
'
				IF (@GroupsCodes Is NOT Null AND Len(@GroupsCodes) > 0)
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.GroupCode in (SELECT ItemID FROM #INTERMEDIATE_GroupsCodes)
'
				IF (@OmriReturnCodes Is NOT Null AND Len(@OmriReturnCodes) > 0)
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.ServiceCode in (SELECT AscriptionToCodeTariff FROM #INTERMEDIATE_AscriptionToCodeTariff)
'
				IF (@PopulationCodes Is NOT Null AND Len(@PopulationCodes) > 0)
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.ServiceCode in (SELECT ServiceCode FROM #INTERMEDIATE_PopulationCodes)
'
				IF (@SalCategoryID Is NOT Null AND @SalCategoryID > 0)
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.ServiceCode in (Select Code FROM #INTERMEDIATE_SalCategory)
'
				IF (@SalOrganCode Is NOT Null AND @SalOrganCode > 0)
					SET @SqlWhere =	@SqlWhere + 
'				AND SALS.ServiceCode in (Select ServiceCode FROM #INTERMEDIATE_SalOrganCode)
'
				IF (@SearchText Is NOT null AND Len(@SearchText) > 0)
					SET @SqlWhere =	@SqlWhere + 
'				AND	( ServiceName Like ''%''+@xSearchText+''%'' Or Synonym1 Like ''%''+@xSearchText+''%'' Or Synonym2 Like ''%''+@xSearchText+''%'' Or 
						Synonym3 Like ''%''+@xSearchText+''%'' Or Synonym4 Like ''%''+@xSearchText+''%'' Or Synonym5 Like ''%''+@xSearchText+''%'' Or HealthGov.[Description] Like ''%''+@xSearchText+''%'' Or
						EngName LIKE ''%''+@xSearchText+''%'' OR
						SALS.ServiceCode In ( Select Code From #INTERMEDIATE_TextSearch )
					)
'
				IF	( @BaskteApproveFromDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 					
'				AND (SALS.BaskteApproveDate >= @xBaskteApproveFromDate OR
					CONVERT(Varchar,SALS.BaskteApproveDate,107) = CONVERT(Varchar,@xBaskteApproveFromDate,107) ) 
'
				IF	( @BaskteApproveToDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 					
'				AND (SALS.BaskteApproveDate <= @xBaskteApproveToDate OR
					CONVERT(Varchar,SALS.BaskteApproveDate,107) = CONVERT(Varchar,@xBaskteApproveFromDate,107) ) 
'
				IF	( @ADD_DATE_FromDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 						
'				AND (SALS.ADD_DATE >= @xADD_DATE_FromDate OR 
					CONVERT(Varchar,SALS.ADD_DATE,107) = CONVERT(Varchar,@xADD_DATE_FromDate,107) ) 
'
				IF	( @ADD_DATE_ToDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 		
'				AND (SALS.ADD_DATE <= @xADD_DATE_ToDate OR CONVERT(Varchar,SALS.ADD_DATE,107) = CONVERT(Varchar,@xADD_DATE_ToDate,107) ) 
'
				IF	( @ShowCanceledServices Is NOT Null AND @ShowCanceledServices = 1 )
					SET @SqlWhere =	@SqlWhere + 
'				AND (SALS.IsCanceled = 1) 
'
				IF	( @DEL_DATE_FromDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 		
'				AND (SALS.DEL_DATE >= @xDEL_DATE_FromDate OR CONVERT(Varchar,SALS.DEL_DATE,107) = CONVERT(Varchar,@xDEL_DATE_FromDate,107) ) 
'
				IF	( @DEL_DATE_ToDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 		
'				AND (SALS.DEL_DATE <= @xDEL_DATE_ToDate OR CONVERT(Varchar,SALS.DEL_DATE,107) = CONVERT(Varchar,@xDEL_DATE_ToDate,107) ) 
'
				IF	( @InternetUpdatedFromDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 		
'				AND (SDI.UpdateDate >= @xInternetUpdatedFromDate OR CONVERT(Varchar,SDI.UpdateDate,107) = CONVERT(Varchar,@xInternetUpdatedFromDate,107) ) 
'
				IF	( @InternetUpdatedToDate Is NOT Null )
					SET @SqlWhere =	@SqlWhere + 		
'				AND (SDI.UpdateDate >= @xInternetUpdatedToDate OR CONVERT(Varchar,SDI.UpdateDate,107) = CONVERT(Varchar,@xInternetUpdatedToDate,107) ) 
'
				SET @SqlEnd = 
'				Order By SALS.ServiceCode'

				SET @SqlSelect = 
					  @Declarations 
					+ @SqlINTERMEDIATE 
					+ @SqlSelect
					+ @SqlWhere
					+ @SqlEnd
							
				SET @params = 
				'@xIncludeInBasket int = null,				
				@xCommon tinyint = null,					
				@xShowServiceInInternet tinyint = null,
				@xIsActive TinyInt = Null,
				@xIsLoggedIn Bit,
				@xSearchText VARCHAR(100) = null,
				@xServiceCode Int = null,
				@xServiceDescription varchar(300) = null,
				@xhealthOfficeCode VARCHAR(100) = null,
				@xhealthOfficeDescription VARCHAR(100)=null,
				@xGroupsCodes varchar(500) = null,
				@xProfessionsCodes varchar(500)= null,
				@xOmriReturnCodes Varchar(300) = null,
				@xICD9Code varchar(500),	
				@xPopulationCodes VarChar(500) = null, 	
				@xSalCategoryID Int = null,			
				@xSalOrganCode Int = null,			
				@xBaskteApproveFromDate DateTime = null,	
				@xBaskteApproveToDate DateTime = null,		
				@xADD_DATE_FromDate DateTime = Null,	
				@xADD_DATE_ToDate DateTime = Null,			
				@xShowCanceledServices Bit,				
				@xDEL_DATE_FromDate DateTime = Null, 	
				@xDEL_DATE_ToDate DateTime = Null,		
				@xInternetUpdatedFromDate DateTime = null,	
				@xInternetUpdatedToDate DateTime = null	
				'
Exec rpc_HelperLongPrint @SqlSelect 				
exec sp_executesql @SqlSelect, @params,		  
				@xIncludeInBasket = @IncludeInBasket,				
				@xCommon = @Common,					
				@xShowServiceInInternet = @ShowServiceInInternet,
				@xIsActive = @IsActive,
				@xIsLoggedIn = @IsLoggedIn,
				@xSearchText = @SearchText,
				@xServiceCode = @ServiceCode,
				@xServiceDescription = @ServiceDescription,
				@xhealthOfficeCode = @healthOfficeCode,
				@xhealthOfficeDescription = @healthOfficeDescription,
				@xGroupsCodes = @GroupsCodes,
				@xProfessionsCodes = @ProfessionsCodes,
				@xOmriReturnCodes = @OmriReturnCodes,
				@xICD9Code = @ICD9Code,	
				@xPopulationCodes = @PopulationCodes, 	
				@xSalCategoryID = @SalCategoryID,			
				@xSalOrganCode = @SalOrganCode,			
				@xBaskteApproveFromDate = @BaskteApproveFromDate,	
				@xBaskteApproveToDate = @BaskteApproveToDate,		
				@xADD_DATE_FromDate = @ADD_DATE_FromDate,	
				@xADD_DATE_ToDate = @ADD_DATE_ToDate,			
				@xShowCanceledServices = @ShowCanceledServices,				
				@xDEL_DATE_FromDate = @DEL_DATE_FromDate, 	
				@xDEL_DATE_ToDate = @DEL_DATE_ToDate,		
				@xInternetUpdatedFromDate = @InternetUpdatedFromDate,	
				@xInternetUpdatedToDate = @InternetUpdatedToDate					
								
			END
	END
GO

GRANT EXECUTE
    ON OBJECT::[dbo].[rpc_GetSalServices] TO [clalit\webuser]
    AS [dbo];
GO

GRANT EXECUTE
    ON OBJECT::[dbo].[rpc_GetSalServices] TO [clalit\IntranetDev]
    AS [dbo];
GO
