USE [UniTrac]
GO
/****** Object:  StoredProcedure [dbo].[GetLoans]    Script Date: 2/14/2017 2:41:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE 
 @id bigint = null,
 @propertyId  bigint = null,
 @lenderId bigint = null,
 @number varchar(18) = null,
 @divisionCode varchar(20) = null,
 @branchCode varchar(20) = null,
 @isServiceFeeInvoiceCall varchar(1) = null,
 @startDate datetime = null,
 @endDate datetime = null,
 @recordTypeCode varchar(20) = null,
 @statusCode varchar(20) = null,
 @statusCodeOp varchar(20) = null,
 @extractUnmatchCount int = null,
 @loanIdForGetCollateralLoans bigint = null

 SET @lenderId = '1021'
 SET @number = '339-16'

BEGIN
   SET NOCOUNT ON

   create table #Id
   (
      Id bigint
   )

   if @isServiceFeeInvoiceCall is null
   begin
   
      if @id is not null and @id > 0 
         insert into #Id values (@id)
      
      if @number is not null
         insert into #Id
            select 
		       l.ID
            from 
		       LOAN l
            where 
               l.NUMBER_TX = @number
               and l.LENDER_ID = isnull(@lenderId, l.LENDER_ID)
               and l.PURGE_DT is null
      
      else if @propertyId is not null and @propertyId > 0 
         insert into #Id
            select 
			   c.Loan_id
            from PROPERTY p
               inner join COLLATERAL c on p.ID = c.PROPERTY_ID
               inner join LOAN l on l.id = c.loan_id
            where 
               P.ID = @propertyId
               and l.LENDER_ID = isnull(@lenderId, l.LENDER_ID)
               and c.PURGE_DT is null
               and l.PURGE_DT is null
      
      else if @lenderId is not null and @lenderId > 0 
         insert into #Id
            select id
               from Loan
            where 
               LENDER_ID = @lenderId
               and RECORD_TYPE_CD IN ('G', 'A', 'D')
               and PURGE_DT is null
               and ( @divisionCode IS NULL OR DIVISION_CODE_TX = @divisionCode )
	   		   and ( @branchCode IS NULL OR BRANCH_CODE_TX = @branchCode )

      else if @loanIdForGetCollateralLoans is not null
         insert into #Id
            select distinct
               c.Loan_id
            from
               (SELECT PROPERTY_ID FROM COLLATERAL WHERE LOAN_ID = @loanIdForGetCollateralLoans AND PURGE_DT IS NULL ) collateralProperties
               inner join PROPERTY p on collateralProperties.PROPERTY_ID = p.ID
               inner join COLLATERAL c on p.ID = c.PROPERTY_ID
               inner join LOAN l on l.id = c.loan_id
            where 
               c.PURGE_DT is null 
               and l.PURGE_DT is null
      
   end
   
   else if @isServiceFeeInvoiceCall is not null
   begin
	  if @lenderId is not null and @lenderId > 0
         insert into #Id
         select id
            from Loan
         where 
            LENDER_ID = @lenderId                
            and PURGE_DT is null
            and ( @divisionCode IS NULL OR DIVISION_CODE_TX = @divisionCode )
			   and ( @branchCode IS NULL OR BRANCH_CODE_TX = @branchCode )
			   
	   -- Date Range Criteria
	   if @startDate is not null 
		  delete   t
		  from     #Id t 
				   inner join Loan l on t.Id = l.ID
		  where    l.CREATE_DT < @startDate

	   if @endDate is not null 
		  delete   t
		  from     #Id t 
				   inner join Loan l on t.Id = l.ID
		  where    l.CREATE_DT >= @endDate	 
		  
	   
	   if @recordTypeCode is not null                     
		  delete   t 
		  from     #Id t
				   inner join LOAN l on t.Id = l.ID
		  where    RECORD_TYPE_CD not in (select STRVALUE from dbo.SplitFunction(@recordTypeCode, ','))	  

	   if @statusCode is not null
	   BEGIN        
	   
		  set @statusCodeOp = ISNULL(@statusCodeOp, 'IN')
			
		  declare @statusCodes table ( statusCode varchar(1) )
		  insert into @statusCodes 
		  select STRVALUE from dbo.SplitFunction(@statusCode, ',')

		  delete   t 
		  from     #Id t
					inner join LOAN l on t.Id = l.ID
		  where    (
					  (@statusCodeOp  = 'NOT IN' and STATUS_CD in (select * from @statusCodes))
					  OR
					  (@statusCodeOp  = 'IN' and STATUS_CD not in (select * from @statusCodes))
				   )
	   END	  
	   
	   if @extractUnmatchCount is not null                     
		  delete   t 
		  from     #Id t
				   inner join LOAN l on t.Id = l.ID
		  where   l.EXTRACT_UNMATCH_COUNT_NO != @extractUnmatchCount  
			   
   end
   	  
   SELECT
	  ID,
	  RECORD_TYPE_CD,
	  LENDER_ID,
	  AGENCY_ID,
	  NUMBER_TX,
	  TYPE_CD,
	  STATUS_CD,
	  STATUS_DT,
	  RETAIN_IN,
	  RETAIN_UTL_IN,
	  FANNIE_MAE_IN,
	  LOCK_ID,
	  EXTRACT_UNMATCH_COUNT_NO,
	  NOTE_TX,
	  ASSOCIATE_IN,
	  EXCLUDE_ASSOCIATE_IN,
	  FIELD_PROTECTION_XML,
	  BALANCE_AMOUNT_NO,
	  BALANCE_LAST_UPDATE_DT,
	  SOURCE_CD,
	  BALANCE_TYPE_CD,
	  DEALER_REPORTED_DT,
	  EFFECTIVE_DT,
	  MATURITY_DT,
	  ORIGINAL_BALANCE_AMOUNT_NO,
	  ORIGINAL_PAYMENT_AMOUNT_NO,
	  APR_AMOUNT_NO,
	  PAYMENT_AMOUNT_NO,
	  PAYMENT_FREQUENCY_CD,
	  INTEREST_TYPE_CD,
	  LAST_PAYMENT_DT,
	  NEXT_SCHEDULED_PAYMENT_DT,
	  PAYOFF_DT,
	  OFFICER_CODE_TX,
	  DEALER_CODE_TX,
	  BRANCH_CODE_TX,
	  DIVISION_CODE_TX,
	  DEPARTMENT_CODE_TX,
	  SERVICECENTER_CODE_TX,
	  CONTRACT_TYPE_CD,
	  CREDIT_LINE_AMOUNT_NO,
	  PURGE_DT,
	  SPECIAL_HANDLING_XML,
	  CREATE_DT,
	  GSE_CD,
	  DELINQUENCY_DT,
	  DELETED_DT,
      CREDIT_SCORE_CD,
      CURRENT_PAYMENT_INCREASE_AMOUNT_NO,
      STATUS_OFFICER_CODE_TX,
      ESCROW_IN,
	  LENDER_BRANCH_CODE_TX,
	  EXTRACT_LOAN_UPDATE_ONLY_IN,
	  PREDICTIVE_SCORE_NO,
	  PREDICTIVE_DECILE_NO
   FROM LOAN
   WHERE ID in (select ID from #Id)
END

--DROP TABLE #ID