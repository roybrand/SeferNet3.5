IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetSalServices_PopulationTariff]') AND type in (N'P', N'PC'))
    BEGIN
	    DROP  Procedure  [dbo].rpc_GetSalServices_PopulationTariff
    END

GO

Create Procedure [dbo].[rpc_GetSalServices_PopulationTariff]
(
@IncludeInBasket int = null ,				-- בסל
@Common tinyint = null ,					-- שכיח 
--@Limiter tinyint = null ,					-- הערות הגבלה
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
@ICD9Code varchar(10) = null ,				-- קוד חיפוש ICD9
@PopulationCodes VarChar(500) = null , 		-- רשימת קודי אוכלוסייה
@SalCategoryID Int = null ,					-- תחום שירות לאינטרנט
@SalOrganCode Int = null ,					-- איבר גוף של השרות לאינטרנט
@BaskteApproveFromDate DateTime = null ,	-- עודכנו - מתאריך
@BaskteApproveToDate DateTime = null ,		-- עודכנו - עד תאריך
@ADD_DATE_FromDate DateTime = Null ,		-- נוספו - מתאריך
@ADD_DATE_ToDate DateTime = Null ,			-- נוספו - עד תאריך
@ShowCanceledServices Bit ,					-- האם להציג שרותים מבוטלים
@DEL_DATE_FromDate DateTime = Null , 		-- בוטלו - מתאריך
@DEL_DATE_ToDate DateTime = Null , 			-- בוטלו - עד תאריך
@InternetUpdatedFromDate DateTime = null ,	-- עודכן לאינטרנט - מתאריך
@InternetUpdatedToDate DateTime = null		-- עודכן לאינטרנט - עד תאריך
)	
AS

select	ServiceCode, ServiceName, MIN_CODE , IsCanceled , 
		[P1] as IthashbenutPnimit , [P2] as IshtatfutAzmit , 
		[P3] as TaarifZiburiBet , [P4] as TeunotDrahim ,
		[P5] as TaarifMale , [P7] as KatsatPnimi , 
		[P8] as KlalitMushlam , [P9] as KatsatHizoni ,
		[P10] as MimunEtzLemecutah , [P11] as OvdimZarim , 
		[P12] as Hechzerim , [P13] as bituahOhMeyuhad ,
		[P14] as MimunEtzLeMushlam,
		[P15] as TaarifeyShuk , [P16] as TikzuvBetHolim , 
		[P17] as TaarifAlef , [P18] as TaarifZiburiZam , 
		[P19] as TaarifZiburiGemel , [P20] as ZahalBeklalitHova , 
		[P21] as ZahalBeklalitKeva , [P33] as TaarifZiburiEskemim
from 
(


Select	SALS.ServiceCode , SALS.MIN_CODE , SALS.ServiceName , SALS.IsCanceled , 'P' + convert(varchar(3), [Populations].PopulationsCode) as PopName , 
		Case When ( ST.TariffNew Is Null ) Then 0 Else ST.TariffNew End As TariffNew
From MF_SalServices386 SALS
Left Join MF_HealthGov478 HealthGov On HealthGov.GoVCode = SALS.MIN_CODE And HealthGov.DELFL = 0
Left Join MF_TariffGroups212 Groups On Groups.GroupCode = SALS.GroupCode And Groups.IsCanceled = 0
--Left Join MF_InsuranceServices432 [IS] On [IS].GroupCode = SALS.GroupCode And [IS].SubGroupCode = SALS.SubGroupCode And [IS].DELFL = 0
--Left Join MF_BudgetCards BC On BC.Code = SALS.BudgetCard And BC.LogicalDelete = 0
--Left Join MF_PaymentsRules PR On PR.Code = SALS.Pay_Rul And PR.LogicalDelete = 0
--Left Join MF_Cluster C On C.Code = SALS.Eshkol And C.LogicalDelete = 0
Left Join (	Select ServiceCode , PopulationCode , Max(TrueDate) LatestTrueDate
			From MF_ServicesTariff210
			Where PopulationSubCode = 0
			Group By ServiceCode , PopulationCode ) As LatestServicesTariff On 
									LatestServicesTariff.ServiceCode = SALS.ServiceCode
Left Join (	Select ServiceCode , PopulationCode , TrueDate , TariffNew
			From MF_ServicesTariff210
			Where PopulationSubCode = 0 ) ST On 
									ST.TrueDate = LatestServicesTariff.LatestTrueDate And
									ST.PopulationCode = LatestServicesTariff.PopulationCode And
									ST.ServiceCode = LatestServicesTariff.ServiceCode
Left Join MF_Populations213 [Populations] ON [Populations].PopulationsCode = ST.PopulationCode And [Populations].SubPopulationsCode = 0 And [Populations].IsCanceled = 0
Left Join SalServiceDetailsForInternet SDI On SDI.ServiceCode = SALS.ServiceCode
Where ( @IncludeInBasket Is null Or 
		@IncludeInBasket = 4 Or  
	  ( @IncludeInBasket=1 And SALS.IncludeInBasket = 1 ) Or
	  ( @IncludeInBasket=0 And SALS.IncludeInBasket = 0 And Limiter = 0 ) Or
	  ( @IncludeInBasket=3 And SALS.IncludeInBasket = 0 And Limiter > 0 ) Or
	  ( @IncludeInBasket=2 And (SALS.IncludeInBasket = 1 Or Limiter > 0 ) ) ) And

	  ( @Common Is Null Or @Common = 3 Or SALS.Common = @Common ) And
	  --( @Limiter Is Null Or @Limiter = 3 Or SALS.Limiter = @Limiter ) And 
	  ( @ShowServiceInInternet Is Null Or @ShowServiceInInternet = 3  Or 
		(SDI.ShowServiceInInternet = @ShowServiceInInternet Or (@ShowServiceInInternet=0 And SDI.ShowServiceInInternet Is Null ) )  ) And  
		
	  ( @IsActive Is Null Or @IsActive = 3 Or ( @IsActive = 1 And SALS.DEL_DATE Is Null ) Or ( @IsActive = 0 And SALS.DEL_DATE Is Not Null ) ) And
	  
	  ( @ServiceCode is null Or @ServiceCode = 0 Or SALS.ServiceCode = @ServiceCode ) And 
	  
	  ( ( @healthOfficeCode Is Null Or Len(@healthOfficeCode) = 0 Or MIN_CODE = @healthOfficeCode  ) Or 
		( @healthOfficeDescription Is Null Or Len(@healthOfficeDescription)=0 Or ( Len(@healthOfficeCode)=0 And HealthGov.[Description] Like '%' + @healthOfficeDescription + '%' ) ) ) And
	  
	  ( @GroupsCodes Is Null Or Len(@GroupsCodes) = 0 Or SALS.GroupCode in ( SELECT ItemID FROM dbo.SplitStringNoOrder(@GroupsCodes)) ) And
		
	  ( @ProfessionsCodes Is Null Or Len(@ProfessionsCodes) = 0 Or SALS.ServiceCode In (	Select SP.Code 
																							From MF_ServiceProfessions SP
																							Where SP.ProfessionCode In ( Select CONVERT( Int , ItemID ) 
																														 FROM dbo.SplitStringNoOrder(@ProfessionsCodes) ) ) ) And
	  
	  
	  ( @OmriReturnCodes Is Null Or Len(@OmriReturnCodes) = 0 Or SALS.ServiceCode in (	Select AscriptionToCodeTariff 
																						From MF_OmriReturns536 
																						Where ReturnCode In (	SELECT ItemID
																												FROM dbo.SplitStringNoOrder(@OmriReturnCodes) ) ) ) And 
																									
	  ( @ICD9Code Is Null Or Len(@ICD9Code)=0 Or SALS.ServiceCode In (	Select HospitalServiceCode
																		From MF_XrefInsuranceICD435
																		Where DiagnosisCode = @ICD9Code ) ) And
	  
	  ( @PopulationCodes Is Null Or Len(@PopulationCodes) = 0 Or SALS.ServiceCode in (	Select ServiceCode
																						From MF_ServicesTariff210 
																						Where PopulationSubCode = 0 And PopulationCode In ( SELECT ItemID 
																																			FROM dbo.SplitStringNoOrder(@PopulationCodes) ) ) ) And
	  ( @SalCategoryID Is Null Or @SalCategoryID <= 0 Or SALS.ServiceCode in (	Select sp.Code 
																				From MF_ServiceProfessions sp
																				Join SalProfessionToCategory spc on spc.ProfessionCode = sp.ProfessionCode
																				Where spc.SalCategoryID = @SalCategoryID And sp.LogicalDelete = 0 ) ) And

	  ( @SalOrganCode Is Null Or @SalOrganCode <= 0 Or SALS.ServiceCode in ( Select ssd.ServiceCode 
																			 From SalServiceDetailsForInternet ssd
																			 Where ssd.SalOrganCode = @SalOrganCode ) ) And
	  -- Advance Search - Start
	  ( @SearchText Is null Or Len(@SearchText)=0 Or ServiceName Like '%'+@SearchText+'%' Or Synonym1 Like '%'+@SearchText+'%' Or Synonym2 Like '%'+@SearchText+'%' Or 
		Synonym3 Like '%'+@SearchText+'%' Or Synonym4 Like '%'+@SearchText+'%' Or Synonym5 Like '%'+@SearchText+'%' Or HealthGov.[Description] Like '%'+@SearchText+'%' Or
		SALS.ServiceCode In ( Select Distinct Code From MF_Comments388 Where Description Like '%'+@SearchText+'%' ) Or
		SALS.ServiceCode In ( Select Distinct Code from MF_Guidances388 Where	Diagnostics Like '%'+@SearchText+'%' Or Age Like '%'+@SearchText+'%' Or 
																				ClalitFacility Like '%'+@SearchText+'%' Or Publicfacility Like '%'+@SearchText+'%' Or 
																				treatment Like '%'+@SearchText+'%' Or Comment Like '%'+@SearchText+'%' ) ) And
	  -- Advance Search - End	
	  -- Date Filter - Start
	  ( @BaskteApproveFromDate Is Null Or SALS.BaskteApproveDate >= @BaskteApproveFromDate Or CONVERT(Varchar,SALS.BaskteApproveDate,107) = CONVERT(Varchar,@BaskteApproveFromDate,107) ) And
	  ( @BaskteApproveToDate Is Null Or SALS.BaskteApproveDate <= @BaskteApproveToDate Or CONVERT(Varchar,SALS.BaskteApproveDate,107) = CONVERT(Varchar,@BaskteApproveToDate,107) ) And 
	  ( @ADD_DATE_FromDate Is Null Or SALS.ADD_DATE >= @ADD_DATE_FromDate Or CONVERT(Varchar,SALS.ADD_DATE,107) = CONVERT(Varchar,@ADD_DATE_FromDate,107) ) And 
	  ( @ADD_DATE_ToDate Is Null Or SALS.ADD_DATE <= @ADD_DATE_ToDate Or CONVERT(Varchar,SALS.ADD_DATE,107) = CONVERT(Varchar,@ADD_DATE_ToDate,107) ) And 
	  
	  (@ShowCanceledServices = 0 Or SALS.IsCanceled = 1 ) And 
	  ( @DEL_DATE_FromDate Is Null Or SALS.DEL_DATE >= @DEL_DATE_FromDate Or 
				CONVERT(Varchar,SALS.DEL_DATE,107) = CONVERT(Varchar,@DEL_DATE_FromDate,107) ) And 
	  ( @DEL_DATE_ToDate Is Null Or SALS.DEL_DATE <= @DEL_DATE_ToDate Or 
				CONVERT(Varchar,SALS.DEL_DATE,107) = CONVERT(Varchar,@DEL_DATE_ToDate,107) ) And
				
	  ( @InternetUpdatedFromDate Is Null Or SDI.UpdateDate >= @InternetUpdatedFromDate Or CONVERT(Varchar,SDI.UpdateDate,107) = CONVERT(Varchar,@InternetUpdatedFromDate,107) ) And 
	  ( @InternetUpdatedToDate Is Null Or SDI.UpdateDate <= @InternetUpdatedToDate Or CONVERT(Varchar,SDI.UpdateDate,107) = CONVERT(Varchar,@InternetUpdatedToDate,107) )
	  
	  -- Date Filter - End
	  
) As StatsPivotTable
pivot 
(max(TariffNew) 
for PopName in ([P1],[P2],[P3],[P4],[P5],[P7],[P8],[P9],[P10],
				[P11],[P12],[P13],[P14],[P15],[P16],[P17],[P18],[P19],
				[P20],[P21],[P33] )
) AS PivotTable
Order By ServiceCode

GO

GRANT EXEC ON rpc_GetSalServices_PopulationTariff TO PUBLIC

GO