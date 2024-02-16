IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServiceDetails')
	BEGIN
		DROP  Procedure  rpc_GetSalServiceDetails
	END

GO

 CREATE Proc [dbo].[rpc_GetSalServiceDetails] 
@ServiceCode Int 
As

-- Table 0: General details of the service.
Select	SS.ServiceCode, SS.ServiceName, SS.EngName, SS.MIN_CODE, SS.IncludeInBasket, 
		SS.FormCode, OFT.ObligationFormDesc As FormType, SS.Limiter, SS.DEL_DATE, 
		SS.Synonym1, SS.Synonym2, SS.Synonym3, SS.Synonym4, SS.Synonym5, SS.IsCanceled, 
		
		SS.BudgetCard As BudgetCode,  BC.[Description] As BudgetDesc, 
		SS.Eshkol as EshkolCode, C.[Description] As EshkolDesc, 
		SS.Pay_Rul As PaymentCode, PR.Description2 As PaymentRules, 
		SS.LimitationComment, SS.ServiceReturnExist
From MF_SalServices386 SS
Left Join MF_ObligationFormType312 OFT On SS.FormCode = OFT.ObligationFormCode
Left Join MF_Cluster C On C.Code = SS.Eshkol
Left Join MF_BudgetCards BC On BC.Code = SS.BudgetCard
Left Join MF_PaymentsRules PR On PR.Code = SS.Pay_Rul
Where SS.ServiceCode = @ServiceCode 

-- Table 1: Select the last time there was an update in the 'MF_SalServices386' table: 
Select Case When ( MAX(BaskteApproveDate) > Max(ADD_DATE) ) Then MAX(BaskteApproveDate) Else Max(ADD_DATE) End As LastSalUpdateDate
From MF_SalServices386
Where ServiceCode = @ServiceCode 

-- Table 2: Select all the changes that were made on this sal service:
Select Distinct BasketApproveDate
From MF_HistoryServices148
Where ServiceCode = @ServiceCode
Order By BasketApproveDate Desc

-- Table 3: Select Omri Codes 
Select ReturnCode , ReturnDescription
From MF_OmriReturns536 
Where AscriptionToCodeTariff = @ServiceCode And DelFlg = 0

-- Table 4: General Management Instructions
Select * 
From MF_Comments388
Where Type1 = 1 And Code = @ServiceCode

-- Table 5: Guidances Management Instructions
Select * 
From MF_Guidances388
Where Code = @ServiceCode

-- Table 6: Select service's "Medical Instructions"
Select *
From MF_Comments388
Where Type1 = 2 And Code = @ServiceCode


Go


GRANT EXEC ON dbo.rpc_GetSalServiceDetails TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetSalServiceDetails TO [clalit\IntranetDev]
GO   