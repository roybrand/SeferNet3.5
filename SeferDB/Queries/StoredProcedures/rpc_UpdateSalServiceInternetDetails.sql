IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_UpdateSalServiceInternetDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_UpdateSalServiceInternetDetails]
GO


Create Proc [dbo].[rpc_UpdateSalServiceInternetDetails] 
@ServiceCode Int, @ServiceNameForInternet VarChar(1000), @ServiceDetails VarChar(Max), @ServiceBrief VarChar(Max), @ServiceDetailsInternet VarChar(Max),
@QueueOrder TinyInt, @ShowServiceInInternet TinyInt, @UpdateComplete TinyInt, @UpdateUser VarChar(50), 
@Diagnosis TinyInt, @Treatment TinyInt, @SalOrganCode Int, @Synonyms VarChar(MAX), @Refund VarChar(1000)
As

Declare @Now DateTime;
Set @Now = GETDATE();

If Exists( Select ServiceCode From SalServiceDetailsForInternet Where ServiceCode = @ServiceCode )
Begin

	Update SalServiceDetailsForInternet Set 
		ServiceNameForInternet = @ServiceNameForInternet , 
		ServiceDetails = @ServiceDetails , 
		ServiceBrief = @ServiceBrief , 
		QueueOrder = @QueueOrder , 
		ShowServiceInInternet = @ShowServiceInInternet ,
		ServiceDetailsInternet = @ServiceDetailsInternet, 
		UpdateComplete = @UpdateComplete , 
		UpdateUser = @UpdateUser , 
		Diagnosis = @Diagnosis , 
		Treatment = @Treatment , 
		SalOrganCode = @SalOrganCode , 
		--SalCategoryID = @SalCategoryID , 
		[Synonyms] = @Synonyms ,
		Refund = @Refund , 
		UpdateDate = @Now
	Where ServiceCode = @ServiceCode
	
End
Else
Begin
	
	Insert Into SalServiceDetailsForInternet ( ServiceCode, ServiceNameForInternet, ServiceDetails, 
		ServiceBrief, ServiceDetailsInternet, QueueOrder, ShowServiceInInternet, UpdateComplete, UpdateUser,
		Diagnosis, Treatment, SalOrganCode, [Synonyms], Refund, UpdateDate )
	Values ( @ServiceCode, @ServiceNameForInternet, @ServiceDetails, 
		@ServiceBrief, @ServiceDetailsInternet, @QueueOrder, @ShowServiceInInternet, @UpdateComplete, @UpdateUser, 
		@Diagnosis, @Treatment, @SalOrganCode, @Synonyms, @Refund, @Now )
	
End

--Declare @PresentServiceInInternet tinyint;
--Declare @PresentDoctorsDirectives tinyint;
--Declare @PresentManagerDirectives tinyint;

--Set @PresentServiceInInternet = @ShowServiceInInternet;
--If (exists(Select top 1 * From MF_Comments388 Where Type1 = 2 And Code = @ServiceCode ))
--	Set @PresentDoctorsDirectives = 1; 
--Else
--	Set @PresentDoctorsDirectives = 0;

--If (exists(Select top 1 * From MF_Comments388 Where Type1 = 1 And Code = @ServiceCode ))
--	Set @PresentManagerDirectives = 1;
--Else
--	Set @PresentManagerDirectives = 0;

--Exec HealthServices.dbo.rpc_UpdateServiceDetailsForInternet @ServiceCode ,
--    @PresentServiceInInternet , 
--    @PresentDoctorsDirectives , 
--    @PresentManagerDirectives , 
--    @ServiceNameForInternet , -- ( = ShortExplain varchar(1000) ),
--    @ServiceDetails , 
--    @Diagnosis ,
--    @Treatment  ,
--    @Refund ,
--    @UpdateComplete , -- ( = FinishTreatment tinyint ),
--    0 ,  -- ( = AreaCode int )
--    @SalOrganCode , -- ( = OrganCode int )
--    @UpdateUser

GO

GRANT EXEC ON [dbo].rpc_UpdateSalServiceInternetDetails TO PUBLIC

GO
