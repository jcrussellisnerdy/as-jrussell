USE [UNITRAC]; --INSERT DATABASE 

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

DECLARE @Ticket nvarchar(15) = 'CSH32796'   --INSERT TICKET NUMBER 
DECLARE @RowsToChange INT = 0

BEGIN TRAN
/****** CREATE SOURCE TEMP TABLE  ******/
IF OBJECT_ID('tempdb..#INTERACTION_HISTORY_INSERT', 'U') IS NOT NULL
	DROP TABLE #INTERACTION_HISTORY_INSERT
CREATE TABLE #INTERACTION_HISTORY_INSERT
(
	[TYPE_CD][NVARCHAR](15),
	[LOAN_ID][BIGINT],
	[PROPERTY_ID][BIGINT],
	[EFFECTIVE_DT][DATETIME],
	[ALERT_IN][CHAR](1),
	[PENDING_IN][CHAR](1),
	[IN_HOUSE_ONLY_IN][CHAR](1),
	[CREATE_DT][DATETIME],
	[CREATE_USER_TX][NVARCHAR](50),
	[UPDATE_DT][DATETIME],
	[UPDATE_USER_TX][NVARCHAR](15),
	[LOCK_ID][TINYINT],
	[ARCHIVED_IN][CHAR](1),
	[SPECIAL_HANDLING_XML][NVARCHAR](50),
	[NOTE_TX][NVARCHAR](MAX)
)WITH (DATA_COMPRESSION = PAGE);

/****** INSERT RECORDS SOURCE TEMP TABLE  ******/
INSERT INTO #INTERACTION_HISTORY_INSERT ([TYPE_CD],[LOAN_ID],[PROPERTY_ID],[EFFECTIVE_DT],[ALERT_IN],[PENDING_IN],[IN_HOUSE_ONLY_IN],[CREATE_DT],[CREATE_USER_TX],[UPDATE_DT],[UPDATE_USER_TX],[LOCK_ID],[ARCHIVED_IN],[SPECIAL_HANDLING_XML],[NOTE_TX])

VALUES
('MEMO',104387327,77225933,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>77751437</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',64714991,37621327,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>36929008</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',143660810,116406559,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>117579301</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',150807786,123548382,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>124813896</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',139488655,112250117,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>113380129</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',138741371,111505425,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>112629419</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',180650759,153317360,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>155020127</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',124875326,97745949,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>98671342</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',118053706,90916848,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>91708741</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',81320691,54205129,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>54019604</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',182210696,154875044,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>156598744</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',182210905,154875246,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>156598946</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',166201910,138914723,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>140419947</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',146783507,119529402,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>120742554</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',147675215,120420111,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>121643191</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',90104234,62975645,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>63200348</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',185921508,158562530,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>160323512</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',188586011,161114280,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>162904995</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',46009674,18654639,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>17918090</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',192824124,165348145,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>167185918</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',114496756,87352681,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>88084148</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',112558497,85415233,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>86102093</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',145069775,117817942,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>119011156</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',191971614,164495681,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>166325956</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',119698726,92573377,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>93397092</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162813196,135531403,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136999759</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',27221746,13253254,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>12506307</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',193694925,166218487,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>168063975</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',83609860,56497549,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>56416584</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',182210964,154875307,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>156599007</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',69519746,42446912,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>41882830</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',99650563,72489431,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>72848204</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',70846831,43769833,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>43235065</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',79455777,52331739,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>52086772</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',64714766,37992686,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>37305718</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',2274899,2030562,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>1240347</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',62093127,34976534,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>34280320</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',64714566,37620810,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>36928494</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',170424404,174716703,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>176676903</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',99650509,72489379,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>72848151</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',198880880,171398828,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>173318512</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',151707506,124448533,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>125741048</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',88819792,61697514,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>61903584</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',62433071,35699611,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>35005597</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',193684531,166208089,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>168053559</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',124874841,97745428,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>98670821</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',150807799,123548395,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>124813909</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',155844217,128576346,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>129946307</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',198880793,171398742,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>173318425</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',166201373,138914173,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>140419397</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',99650857,72489738,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>72848516</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',209242253,180809219,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>182863278</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',130345763,103203920,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>104198669</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',130723260,103581432,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>104581137</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',84309416,57196850,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>57140891</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',124874875,97745464,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>98670857</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',209244994,180811973,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>182866034</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',84864430,57750441,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>57731419</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',51871049,24558232,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>23834331</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',46307928,18956994,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>18217735</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',152560174,125299561,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>126610731</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',128656229,101518259,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>102496518</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',150807949,123548549,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>124814064</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',148547636,121290920,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>122534377</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',218766281,190320534,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>192542248</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',2221398,1969541,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>1179189</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',173619064,146319638,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>147905553</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',99018896,71859115,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>72213066</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',166991211,139702637,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>141220771</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',166991207,139702633,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>141220767</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',118779155,91641744,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>92449083</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',205520024,178036328,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>180058052</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',190107475,162633636,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>164446860</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',218765755,190320008,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>192541720</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',182210905,154875246,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>156598946</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',69515628,42442819,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>41878737</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',110452627,83305061,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>83950261</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162813408,135531616,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136999972</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',158952015,131677782,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>133096913</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',221418866,192958962,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>195218208</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',178265249,150940744,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>152618553</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',220507698,192048375,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>194288204</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',226573515,198102062,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>200578170</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',180025986,152695202,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>154392001</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',226577005,198105540,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>200581689</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162448120,135166338,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136631359</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',163679225,136396985,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>137873135</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',174361367,147062682,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>148663113</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',223396351,194930651,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>197213204</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',223395501,194929787,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>197212337</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',187683643,160213209,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>161989563</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',149998150,122741652,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>123997627</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',226573692,198102242,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>200578350</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',226573694,198102244,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>200578352</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',114496060,87351955,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>88083424</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',83145984,56035195,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>55933138</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',231306999,202833455,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>205362125</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',229521477,201050416,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>203551946</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',191971614,164495681,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>166325956</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',107032362,79874270,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>80464264</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',1835196,1646274,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>854214</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',107774538,80615951,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>81213288</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',113850183,86707315,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>87424417</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',113850344,86707486,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>87424589</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',1829081,15245300,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>14496525</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',97423003,70267398,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>70595966</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',139488655,112250117,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>113380129</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',179002468,151673440,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>153356793</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',241783066,213299272,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>215915937</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',145069602,117817769,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>119010983</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',174361350,147062666,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>148663098</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',146783470,119529365,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>120742517</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',192824011,165348030,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>167185783</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',240589155,212105033,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>214711853</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',236737919,209810849,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>212410784</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',182210964,154875307,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>156599007</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',60942047,33832535,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>33130622</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',198880771,93765877,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>94603352</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',194647412,167170467,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>169032552</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',241783224,213299433,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>215916095</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',221418836,192958929,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>195218172</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',203059405,175581284,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>177551301</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',107774374,80615775,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>81213110</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',79079530,51953375,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>51698171</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',121581519,94453553,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>95321957</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',236736941,208254670,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>210841126</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',209243224,180810200,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>182864260</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',99018742,71858970,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>72212903</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',47578053,20242080,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>19509099</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',118779469,91642089,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>92449430</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',201319363,173836357,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>175780214</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',199771054,172289448,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>174218430</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',149084542,121829866,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>123077441</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',118779569,91642198,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>92449539</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162448742,135166974,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136631995</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',132535319,105390373,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>106410572</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',257597622,229097396,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>231902580</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',204744079,177260846,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>179263836</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',260199754,231697488,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>234539449</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',260199505,231697230,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>234539189</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',240588805,212104684,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>214711475</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',120122595,92997308,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>93824026</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',158952942,131678739,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>133097871</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',164464774,137181257,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>138667440</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',260200024,231697768,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>234539731</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',261172349,232669412,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>235522893</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',151707240,124448266,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>125740780</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',166991113,139702538,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>141220672</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',254378979,225884223,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>228655050</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',124874232,97744756,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>98670149</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',149998331,122741830,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>123997805</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',127088872,99956562,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>100909930</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',267456966,238936076,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>241862424</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',198880793,171398742,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>173318425</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',99018896,71859115,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>72213066</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',128658061,101520116,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>102498387</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',207399609,171397905,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>173317395</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',213202869,184764135,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>186870589</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',219819302,191371672,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>193605483</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',47907818,20569457,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>19837105</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',227549250,199081482,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>201563310</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',155005240,127736298,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>129091581</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',125942506,98811780,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>99747646</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162813175,135531378,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136999734</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',213348189,184909028,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>187018272</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',216699301,188254110,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>190427938</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',217833453,189389502,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>191573531</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',118779163,91641751,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>92449090</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',266254602,237734576,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>240644700</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',107774369,80615770,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>81213105</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',171054220,143762302,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>145320345</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',219819258,191371624,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>193605435</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',219819385,191371755,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>193605566</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',251106497,222613633,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>225309410</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',269305496,240776478,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>243803495</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',210963329,182528948,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>184603341</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',220510114,192050785,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>194290606</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',156611934,129342598,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>130723710</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',175925269,148609220,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>150256303</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',231306999,202833455,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>205362125</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',175925452,148609401,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>150256483</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',229521477,201050416,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>203551946</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162449339,135167589,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136632612</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',269682526,241155950,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>244236107</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',83610176,56497883,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>56416918</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',220510159,192050829,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>194290650</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',148547891,121291176,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>122534635</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',187683643,160213209,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>161989563</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162448120,135166338,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136631359</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',223395579,194929868,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>197212418</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',13327106,12712052,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>11956834</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',184271522,156932827,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>158678101</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',142776242,115525789,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>116684479</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',271079520,242421747,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>245654559</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',83145738,56034935,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>55932875</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',1887086,1707034,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>915583</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',115214924,88069738,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>88811884</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',242998983,214514341,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>217143647</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',181528525,154194279,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>155911900</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',213202704,184763968,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>186870421</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162447968,135166172,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136631193</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',213348149,184908990,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>187018234</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162813755,135531982,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>137000338</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',110452602,83305037,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>83950239</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',269017039,240489456,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>243484315</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',252212780,223720266,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>226434864</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',271519047,242855122,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>246148329</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',260199742,231697474,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>234539435</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',272280544,243606112,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>247009698</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',247873828,219388082,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>222043026</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',151707300,124448328,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>125740842</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',154165074,126898411,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>128238210</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',272941956,244249697,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>247785009</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',251108927,222616074,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>225311851</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',186895002,159426528,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>161195911</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',252212715,223720203,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>226434801</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',180025510,152694726,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>154391524</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',273753661,245056972,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>249516001</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',261172349,232669412,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>235522893</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',198880859,171398808,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>173318492</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',273045632,244352695,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>247905751</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',210194473,181760447,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>183826674</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',142776242,115525789,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>116684479</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',258901181,230400555,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>233225531</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',148548017,121291303,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>122534763</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',274035152,245337781,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>249831506</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',226573646,198102196,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>200578304</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',202196884,174716224,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>176676410</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',146783845,119529737,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>120742891</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',274981742,246277476,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>250846540</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',128993984,101854122,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>102836606</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',275462547,246760288,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>251376093</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',118779490,91642114,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>92449455</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',208427747,179995371,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>182038741</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',151707240,124448266,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>125740780</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',156611934,129342598,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>130723710</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',276473909,247767803,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>252485434</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',148547748,121291034,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>122534492</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',275944213,247241029,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>251889982</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',273753305,245056599,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>249515629</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',216698988,188253788,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>190427614</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',277017502,248310935,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>253097650</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',277660662,248948405,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>253803655</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',254379196,225884437,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>228655264</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',270258117,241614834,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>244776018</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',149084741,121830068,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>123077644</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',162448120,135166338,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>136631359</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',227554945,199087171,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>201569000</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',268557731,240032882,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>243003025</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',179002460,151673432,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>153356785</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',220510199,192050869,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>194290690</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',266254243,237734196,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>240644318</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',107774630,80616054,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>81213392</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',278296799,249574219,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>254488014</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',198880793,171398742,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>173318425</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',275135951,246433275,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>251025488</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',147675137,120420027,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>121643107</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',276723514,248019197,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>252767407</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',271261907,242601093,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>245866167</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',223396604,194930886,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>197213439</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',202208944,174730609,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>176690854</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',117331885,90193995,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>90977715</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',144344531,117093570,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>118277073</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',185921955,158562926,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>160323907</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',272116051,243440574,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>246801900</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',201319363,173836357,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>175780214</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',175925304,167925078,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>169786887</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',221418836,192958929,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>195218172</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',238294134,18655266,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>17918717</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',231308394,202834854,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>205363524</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',271519080,242855155,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>246148363</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',138744147,105390127,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>106410326</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',279928252,251169359,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>256325053</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',222431743,193966793,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>196239636</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',280534234,251759036,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>256995411</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',273601704,244905803,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>249335678</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',280718760,251940781,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>257186400</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',57670374,30463324,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>29760432</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',280718740,251940759,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>257186378</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',231306890,202833347,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>205362017</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',111782752,84638434,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>85313069</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281128634,252345704,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>257617301</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',272942267,244250014,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>247785326</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',158952642,131678427,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>133097558</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',275780264,247077413,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>251704531</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281221244,252435258,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>257716692</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281301664,252514392,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>257801495</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',117331809,90193912,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>90977631</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281740437,252947203,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>258279228</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281740492,252947261,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>258279287</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281599024,252806881,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>258117302</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',165395160,138111112,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>139605899</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',280886598,252107106,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>257362008</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',252212653,223720141,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>226434739</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',276197737,247496429,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>252178477</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',282723022,253920637,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>259320482</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281979863,253183896,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>258530501</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',281848867,253054049,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>258394063</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',282412735,253612124,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>258991148</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.'),
('MEMO',282577027,253775371,GETDATE(),'N','N','N',GETDATE(),@Ticket,GETDATE(),@Ticket,1,'N','<SH><RC>259164645</RC></SH>','A collateral code cpi credit was applied resulting in a premium credit to the borrower. Explanation letter sent to borrower.');





/*  Calculate number of rows to be Inserted */
select @RowsToChange = count(*) from #INTERACTION_HISTORY_INSERT

/* Existence Check for Storage Tables */
IF NOT EXISTS (
		SELECT *
		FROM UNITRACHDSTORAGE.sys.tables
		WHERE SCHEMA_NAME(SCHEMA_ID) = ('UNITRAC')
			AND NAME LIKE @Ticket + '_%'
			AND TYPE IN (N'U')
		)
BEGIN
/* Create EMPTY Storage Table  */
	EXEC (
			'SELECT TYPE_CD, LOAN_ID, PROPERTY_ID, EFFECTIVE_DT, ALERT_IN, PENDING_IN, IN_HOUSE_ONLY_IN, 
CREATE_DT, CREATE_USER_TX, UPDATE_DT, UPDATE_USER_TX, LOCK_ID, ARCHIVED_IN,SPECIAL_HANDLING_XML, NOTE_TX
	          		INTO UNITRACHDSTORAGE.UNITRAC.' + @Ticket + '_INTERACTION_HISTORY
	          		FROM INTERACTION_HISTORY
	          		WHERE 1=0'
			);-- WHERE 1=0 creates table without moving data

 /* poulate storage table */
    EXEC ('INSERT INTO UNITRACHDSTORAGE.UNITRAC.'+ @ticket +'_INTERACTION_HISTORY SELECT * FROM #INTERACTION_HISTORY_INSERT')

    /* Does Storage Table meet expectations */
	IF( @@RowCount = @RowsToChange )
		BEGIN
            PRINT 'Storage table meets expections - continue'

/****** MERGE RECORDS TARGET TABLE  ******/
MERGE [dbo].[INTERACTION_HISTORY] AS TARGET
USING #INTERACTION_HISTORY_INSERT AS SOURCE
ON (TARGET.LOAN_ID = SOURCE.[LOAN_ID] 
AND TARGET.PROPERTY_ID = SOURCE.[PROPERTY_ID]
AND TARGET.NOTE_TX = SOURCE.[NOTE_TX]) 

/****** INSERT NEW RECORDS INTO TARGET   ******/
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([TYPE_CD],[LOAN_ID],[PROPERTY_ID],[EFFECTIVE_DT],[ALERT_IN],[PENDING_IN],[IN_HOUSE_ONLY_IN],[CREATE_DT],[CREATE_USER_TX],[UPDATE_DT],[UPDATE_USER_TX],[LOCK_ID],[ARCHIVED_IN],[SPECIAL_HANDLING_XML],[NOTE_TX])
    VALUES ( SOURCE.[TYPE_CD], SOURCE.[LOAN_ID], SOURCE.[PROPERTY_ID], SOURCE.[EFFECTIVE_DT], SOURCE.[ALERT_IN], SOURCE.[PENDING_IN], SOURCE.[IN_HOUSE_ONLY_IN], SOURCE.[CREATE_DT], SOURCE.[CREATE_USER_TX], SOURCE.[UPDATE_DT], SOURCE.[UPDATE_USER_TX], SOURCE.[LOCK_ID], SOURCE.[ARCHIVED_IN], SOURCE.[SPECIAL_HANDLING_XML], SOURCE.[NOTE_TX]);

	/* Step 4 - Inspect results - Commit/Rollback */
			IF ( @@ROWCOUNT <= @RowsToChange )
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

