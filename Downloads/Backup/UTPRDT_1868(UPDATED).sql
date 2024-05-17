USE UniTrac
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'UTPRDT_1868_U';

--BUILD TEMP TABLES FOR INSERTS--
Select top 1 * into #templates from TEMPLATE where DESCRPTION_TX = 'MultiBlock Auto Notice' and AGENCY_ID = 1

update #templates set DESCRPTION_TX = 'Remaining Term Reminder'

Update #templates set XSLT_XML = REPLACE(CAST(XSLT_XML as nvarchar(max)),'ContentBlock[@Name=''','ContentBlock[@Name=''RN')

select cbd.* 
into #tmpCBDs
from CONTENT_BLOCK_DEFINITION cbd
left join LETTER_RULE lr on lr.RELATE_ID = cbd.ID
where
cbd.NAME_TX IN ('Acknowledgement','CollateralDescription','CPIPremiumAndCoverageLimitations','HowToProvideProof','ImportantMessage','LetterClosing','MortgageInsuranceInformation','LetterIntroduction','LoanIdentifiers','NoticeVersion','ProofRequirements','RecipientAddress','RecipientName','Salutation','ToAvoidCPI','Footer','ReturnAddress','LoanNumber','FirstPageFooter','ImmediateResolution','AdditionalPage')
and cbd.purge_dt is null and agency_id = 1 and lr.ID is null

Update #tmpCBDs set NAME_TX = 'RN'+NAME_TX

Update #tmpCBDs set CONTENT_DATA_TX = '<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta name=Generator content="Microsoft Word 14 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
 {font-family:Calibri;
 panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
 {font-family:"Arial Narrow";
 panose-1:2 11 6 6 2 2 2 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
 {margin-top:0in;
 margin-right:0in;
 margin-bottom:10.0pt;
 margin-left:0in;
 line-height:115%;
 font-size:11.0pt;
 font-family:"Calibri","sans-serif";}
p
 {margin-right:0in;
 margin-left:0in;
 font-size:12.0pt;
 font-family:"Times New Roman","serif";}
.MsoChpDefault
 {font-family:"Calibri","sans-serif";}
.MsoPapDefault
 {margin-bottom:10.0pt;
 line-height:115%;}
@page WordSection1
 {size:8.5in 11.0in;
 margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
 {page:WordSection1;}
-->
</style>

</head>

<body lang=EN-US>

<div class=WordSection1>

<p class=MsoNormal style=''margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal''><span style=''font-size:12.0pt;font-family:"Arial Narrow","sans-serif"''>{{LenderName}} purchased insurance on the collateral securing your agreement listed below. This is an annual reminder notice this insurance was purchased and charged to you.</span></p>

</div>

</body>

</html>'
where NAME_TX = 'RNLetterIntroduction'

Update #tmpCBDs
set CONTENT_DATA_TX = '<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta name=Generator content="Microsoft Word 14 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
 {font-family:Calibri;
 panose-1:2 15 5 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
 {margin-top:0in;
 margin-right:0in;
 margin-bottom:10.0pt;
 margin-left:0in;
 line-height:115%;
 font-size:11.0pt;
 font-family:"Calibri","sans-serif";}
.MsoChpDefault
 {font-family:"Calibri","sans-serif";}
.MsoPapDefault
 {margin-bottom:10.0pt;
 line-height:115%;}
@page WordSection1
 {size:8.5in 11.0in;
 margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
 {page:WordSection1;}
-->
</style>

</head>

<body lang=EN-US>

<div class=WordSection1>

<p class=MsoNormal><b><span style=''font-size:12.0pt;line-height:115%;
color:black''>REMINDER NOTICE</span></b></p>

</div>

</body>

</html>'
where NAME_TX = 'RNNoticeVersion'

Update #tmpCBDs
set CONTENT_DATA_TX = '<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta name=Generator content="Microsoft Word 14 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
 {font-family:Calibri;
 panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
 {font-family:"Arial Narrow";
 panose-1:2 11 6 6 2 2 2 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
 {margin-top:0in;
 margin-right:0in;
 margin-bottom:10.0pt;
 margin-left:0in;
 line-height:115%;
 font-size:11.0pt;
 font-family:"Calibri","sans-serif";}
.MsoChpDefault
 {font-family:"Calibri","sans-serif";}
.MsoPapDefault
 {margin-bottom:10.0pt;
 line-height:115%;}
@page WordSection1
 {size:8.5in 11.0in;
 margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
 {page:WordSection1;}
 /* List Definitions */
 ol
 {margin-bottom:0in;}
ul
 {margin-bottom:0in;}
-->
</style>

</head>

<body lang=EN-US>

<div class=WordSection1>

<p class=MsoNormal style=''margin-top:6.0pt;margin-right:0in;margin-bottom:6.0pt;
margin-left:0in;line-height:normal''><span style=''font-size:12.0pt;font-family:
"Arial Narrow","sans-serif";color:black''>If you furnish evidence of a physical damage insurance policy, {{LenderName}} will cancel the insurance we purchased and give you a refund or credit of unearned charges. It is necessary for your insurance policy to be effective on or before {{CPIQuoteEffectiveDate}} for a full premium refund. <b>The purchased insurance is intended solely to protect our security interest. It does not provide any coverage for liability or injury and will not satisfy the requirements of any financial responsibility law.</b></span></p>
</div>

</body>

</html>'
where NAME_TX = 'RNToAvoidCPI'

/* Step 1 - Calculate rows to be Inserted */
Declare @RowsToInsertTemp INT = (Select count(*) from #templates);
Declare @RowsToInsertCBD INT = (Select count(*) from #tmpCBDs);
Declare @RowsToInsertCBA INT = (Select count(*) from #tmpCBDs);
Declare @RowsToInsertCBF INT = (Select count(*) from #tmpCBDs);


Declare @RowsInsertedTemp INT
Declare @RowsInsertedCBD INT
Declare @RowsInsertedCBA INT
Declare @RowsInsertedCBF INT
/*If the rows are not contained in an existing table*/

/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like  @Ticket+'%' AND type IN (N'U') )
	BEGIN
    		/* Step 2 - Create EMPTY Storage Table  */
		SELECT  AGENCY_ID,	LENDER_ID,	LOGO_ID,	TYPE_CD,	DESCRPTION_TX,	XSLT_XML,	EXAMPLE_XML,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID,	SUB_TYPE_CD
          		INTO UnitracHDStorage..UTPRDT_1868_U_temp
          		FROM TEMPLATE
          		WHERE 1=0;  /*WHERE 1=0 creates table without moving data*/
				

		SELECT TEMPLATE_ID,	CONTENT_BLOCK_NAME_TX,	USE_LIBRARY_IN,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID
				INTO UnitracHDStorage..UTPRDT_1868_U_CBA
				FROM CONTENT_BLOCK_ASSIGNMENT
				WHERE 1=0
				

		SELECT TEMPLATE_ID,	NAME_TX,	STYLE_NAME_TX,	IGNORE_STYLE_NAME_IN,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID,	CONTENT_DATA_TX,	AGENCY_ID,	GUID_TX
				INTO UnitracHDStorage..UTPRDT_1868_U_CBD
				FROM CONTENT_BLOCK_DEFINITION
				WHERE 1=0

		SELECT NAME_TX,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID,	AGENCY_ID,	GUID_TX
				INTO UnitracHDStorage..UTPRDT_1868_U_CBF
				FROM CONTENT_BLOCK_FAMILY
				WHERE 1=0

    
		/* populate new Storage table from Sources */
		DECLARE @TemplateID TABLE (ID int)

		INSERT INTO UnitracHDStorage..UTPRDT_1868_U_temp
		Select AGENCY_ID,	LENDER_ID,	LOGO_ID,	TYPE_CD,	DESCRPTION_TX,	XSLT_XML,	EXAMPLE_XML,	GETDATE(),	GETDATE(),	@Ticket,	PURGE_DT,	LOCK_ID,	SUB_TYPE_CD
		from #templates
		Set @RowsInsertedTemp = @@ROWCOUNT

		INSERT INTO UnitracHDStorage..UTPRDT_1868_U_CBD
		Select TEMPLATE_ID,	NAME_TX,	STYLE_NAME_TX,	IGNORE_STYLE_NAME_IN,	GETDATE(),	GETDATE(),	@Ticket,	PURGE_DT,	LOCK_ID,	CONTENT_DATA_TX,	AGENCY_ID,	GUID_TX
		from #tmpCBDs
		Set @RowsInsertedCBD = @@ROWCOUNT

		INSERT INTO UnitracHDStorage..UTPRDT_1868_U_CBA
		Select 1,	NAME_TX,	'Y',	GETDATE(),	GETDATE(),	@Ticket,	PURGE_DT,	LOCK_ID
		from #tmpCBDs
		Set @RowsInsertedCBA = @@ROWCOUNT

		INSERT INTO UnitracHDStorage..UTPRDT_1868_U_CBF
		Select NAME_TX,	GETDATE(),	GETDATE(),	'UTPRDT_1868_U',	NULL,	1,	1,	GUID_TX
		from #tmpCBDs
		Set @RowsInsertedCBF = @@ROWCOUNT
		
    		/* Does Storage Table meet expectations */
		IF( @RowsToInsertCBD = @RowsInsertedCBD and @RowsToInsertCBA = @RowsInsertedCBA and @RowsToInsertCBF = @RowsInsertedCBF and @RowsToInsertTemp = @RowsInsertedTemp )
			BEGIN
				PRINT 'Storage table meets expections - continue'

				Set @RowsInsertedCBD = 0
				Set @RowsInsertedCBA = 0
				Set @RowsInsertedCBF = 0
				Set @RowsInsertedTemp = 0

				/* Step 3 - Perform table INSERT */
				INSERT INTO TEMPLATE
				output INSERTED.ID into @TemplateID
				Select AGENCY_ID,	LENDER_ID,	LOGO_ID,	TYPE_CD,	DESCRPTION_TX,	XSLT_XML,	EXAMPLE_XML,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID,	SUB_TYPE_CD
				FROM UnitracHDStorage..UTPRDT_1868_U_temp
				Set @RowsInsertedTemp = @@ROWCOUNT

				INSERT INTO CONTENT_BLOCK_DEFINITION
				Select TEMPLATE_ID,	NAME_TX,	STYLE_NAME_TX,	IGNORE_STYLE_NAME_IN,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID,	CONTENT_DATA_TX,	AGENCY_ID,	NEWID()
				from UnitracHDStorage..UTPRDT_1868_U_CBD
				Set @RowsInsertedCBD = @@ROWCOUNT

				INSERT INTO CONTENT_BLOCK_ASSIGNMENT
				Select (Select ID from @TemplateID), CONTENT_BLOCK_NAME_TX,	USE_LIBRARY_IN,	CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	NULL,	1
				from UnitracHDStorage..UTPRDT_1868_U_CBA
				Set @RowsInsertedCBA = @@ROWCOUNT

				INSERT INTO CONTENT_BLOCK_FAMILY
				SELECT NAME_TX, CREATE_DT,	UPDATE_DT,	UPDATE_USER_TX,	PURGE_DT,	LOCK_ID,	AGENCY_ID,	NEWID()
				from UnitracHDStorage..UTPRDT_1868_U_CBF
				Set @RowsInsertedCBF = @@ROWCOUNT


				/* Step 4 - Inspect results - Commit/Rollback */
		IF( @RowsToInsertCBD = @RowsInsertedCBD and @RowsToInsertCBA = @RowsInsertedCBA and @RowsToInsertCBF = @RowsInsertedCBF and @RowsToInsertTemp = @RowsInsertedTemp )
		  			BEGIN
			    			PRINT 'SUCCESS - Performing Commit'
			    			COMMIT;
			  		END
				ELSE
			  		BEGIN
		    				PRINT 'FAILED TO UPDATE - Performing Rollback'
						ROLLBACK;
	  				END
			END
		ELSE
			BEGIN
				PRINT 'Storage does not meet expectations - rollback'
				ROLLBACK;
			END
	END
ELSE
	BEGIN
		PRINT 'HD TABLE EXISTS - Stop work'
		COMMIT;
	END