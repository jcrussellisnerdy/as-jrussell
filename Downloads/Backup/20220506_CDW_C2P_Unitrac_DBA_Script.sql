USE ROLE owner_edw_prod;
USE WAREHOUSE EDW_PROD_INFA_WH;
USE DATABASE EDW_PROD;
USE SCHEMA CDW;

--DESC EDW_TEST.CDW.D_OPEN_CERTIFICATE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_OPEN_CERTIFICATE
(
 D_OPEN_CERTIFICATE_ID                                        NUMBER(38,0)         NOT NULL;
,RUN_DTX                                                      DATE                 ;
,LENDER_CODE_TX                                               TEXT(10)             NOT NULL;
,LENDER_NAME_TX                                               TEXT(200)            NOT NULL;
,LOAN_ID                                                      NUMBER(38,0)         NOT NULL;
,LOAN_NUMBER_TX                                               TEXT(36)             NOT NULL;
,LOAN_STATUS_CD                                               TEXT(1)              ;
,BRANCH_CODE_TX                                               TEXT(40)             ;
,COLLATERAL_STATUS_CD                                         TEXT(2)              ;
,COLLATERAL_NUMBER_NO                                         NUMBER(38,0)         ;
,FPC_ID                                                       NUMBER(38,0)         NOT NULL;
,CPI_QUOTE_ID                                                 NUMBER(38,0)         NOT NULL;
,FPC_NUMBER_TX                                                TEXT(36)             NOT NULL;
,EFFECTIVE_DT                                                 DATE                 ;
,EXPIRATION_DT                                                DATE                 ;
,CANCELLATION_DT                                              DATE                 ;
,ISSUE_DT                                                     DATE                 ;
,ISSUE_REASON_CD                                              TEXT(20)             ;
,BILLING_STATUS_CD                                            TEXT(8)              ;
,QUICK_ISSUE_IN                                               TEXT(1)              ;
,HOLD_IN                                                      TEXT(1)              ;
,PROPERTY_ID                                                  NUMBER(38,0)         ;
,RC_ID                                                        NUMBER(38,0)         ;
,RC_COVERAGE_TYPE_CD                                          TEXT(60)             ;
,RC_STATUS_CD                                                 TEXT(4)              ;
,DELAY_DAYS_NO                                                NUMBER(38,0)         ;
,LENDER_PRODUCT_ID                                            NUMBER(38,0)         ;
,LENDER_PRODUCT_BASIC_TYPE_CD                                 TEXT(36)             ;
,BILL_DT                                                      DATE                 ;
,ACTIVITY_AMOUNT_NO                                           NUMBER(18,2)         ;
,AR_AMOUNT_NO                                                 NUMBER(18,2)         ;
,CASH_AMOUNT_NO                                               NUMBER(18,2)         ;
,TO_BE_BILLED_AMOUNT_NO                                       NUMBER(18,2)         ;
,SHOULD_BE_BILLED_AMOUNT_NO                                   NUMBER(18,2)         ;
,AGE_0_42_NO                                                  NUMBER(18,2)         ;
,AGE_43_60_NO                                                 NUMBER(18,2)         ;
,AGE_61_90_NO                                                 NUMBER(18,2)         ;
,AGE_91_120_NO                                                NUMBER(18,2)         ;
,AGE_120_NO                                                   NUMBER(18,2)         ;
,REFUND_AMOUNT_NO                                             NUMBER(18,2)         ;
,BILLED_AMOUNT_NO                                             NUMBER(18,2)         ;
,WEEKLY_ID                                                    NUMBER(38,0)         ;
,AGENCY_CODE_TX                                               TEXT(20)             ;
,CURRENT_FLG                                                  TEXT(1)              ;
,EFFECTIVE_FROM_DT                                            DATETIME             ;
,EFFECTIVE_TO_DT                                              DATETIME             ;
,BATCH_ID                                                     NUMBER(38,0)         ;
,HASH_ID                                                      TEXT(32)             ;
,CREATE_DT                                                    DATETIME             ;
,UPDATE_DT                                                    DATETIME             ;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_AGENCY;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_AGENCY
(
 D_UT_AGENCY_ID                                               NUMBER(38,0)         NOT NULL;
,AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,SHORT_NAME_TX                                                TEXT(8000)           NOT NULL;
,NAME_TX                                                      TEXT(8000)           NOT NULL;
,WEB_ADDRESS_TX                                               TEXT(8000)           ;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,SRC_UPDATE_DT                                                DATETIME             ;
,UPDATE_USER_TX                                               TEXT(8000)           ;
,LOCK_ID                                                      NUMBER(38,0)         NOT NULL;
,D_MAIN_OFFICE_ID                                             NUMBER(38,0)         ;
,MAIN_OFFICE_ID                                               NUMBER(38,0)         ;
,TAX_ID_TX                                                    TEXT(8000)           ;
,ACTIVE_IN                                                    TEXT(8000)           NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_CARRIER;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_CARRIER
(
 D_CARRIER_ID                                                 NUMBER(38,0)         NOT NULL;
,CARRIER_ID                                                   NUMBER(38,0)         NOT NULL;
,NAME_TX                                                      TEXT(100)            NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,PERSON_ID                                                    NUMBER(38,0)         ;
,PHYSICAL_ADDRESS_ID                                          NUMBER(38,0)         ;
,MAILING_ADDRESS_ID                                           NUMBER(38,0)         ;
,HASH_ID                                                      TEXT(32)             ;
,PURGE_DT                                                     DATETIME             ;
,CODE_TX                                                      TEXT(40)             ;
,PHONE_TX                                                     TEXT(40)             ;
,ALTERNATE_PHONE_TX                                           TEXT(40)             ;
,FAX_TX                                                       TEXT(40)             ;
,WEB_ADDRESS_TX                                               TEXT(640)            ;
,SRC_CREATE_DT                                                DATETIME             ;
,SRC_UPDATE_DT                                                DATETIME             ;
,ACTIVE_IN                                                    TEXT(1)              ;
,IN_USE_IN                                                    TEXT(1)              ;
,ALLOW_REINSTATEMENT_IN                                       TEXT(1)              ;
,REPORT_LENDERPAY_ENDORSMENT_IN                               TEXT(1)              ;
,MANUAL_ISSUE_ONLY_IN                                         TEXT(1)              ;
,CARRIER_PROGRAM_TX                                           TEXT(140)            ;
,DATA_PATH_TX                                                 TEXT(512)            ;
,VENDOR_SETTING_NO                                            NUMBER(11,0)         ;
,VUT_KEY                                                      NUMBER(38,0)         ;
,PHONE_EXT_TX                                                 TEXT(20)             ;
,ALTERNATE_PHONE_EXT_TX                                       TEXT(20)             ;
,FAX_EXT_TX                                                   TEXT(20)             ;
,DISPLAY_NAME_TX                                              TEXT(200)            ;
,LOCK_ID                                                      NUMBER(3,0)          ;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_COLLATERAL_CODE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_COLLATERAL_CODE
(
 D_UT_COLLATERAL_CODE_ID                                      NUMBER(38,0)         NOT NULL;
,COLLATERAL_CODE_ID                                           NUMBER(38,0)         NOT NULL;
,D_AGENCY_ID                                                  NUMBER(38,0)         NOT NULL;
,AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,CODE_TX                                                      TEXT(30)             NOT NULL;
,--DESCRIPTION_TX                                               TEXT(50)             ;
,ACTIVE_IN                                                    TEXT(1)              NOT NULL;
,CONTRACT_TYPE_CD                                             TEXT(30)             NOT NULL;
,APAPER_IN                                                    TEXT(1)              NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             ;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(38,0)         NOT NULL;
,VUT_KEY                                                      NUMBER(38,0)         ;
,PRIMARY_CLASS_CD                                             TEXT(6)              ;
,SECONDARY_CLASS_CD                                           TEXT(6)              ;
,VEHICLE_LOOKUP_IN                                            TEXT(1)              ;
,ADDRESS_LOOKUP_IN                                            TEXT(1)              ;
,VACANT_IN                                                    TEXT(1)              NOT NULL;
,REO_IN                                                       TEXT(1)              NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_CPI_ACTIVITY;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_CPI_ACTIVITY
(
 D_CPI_ACTIVITY_ID                                            NUMBER(38,0)         NOT NULL;
,CPI_ACTIVITY_ID                                              NUMBER(38,0)         NOT NULL;
,START_DT                                                     DATETIME             ;
,PROCESS_DT                                                   DATETIME             NOT NULL;
,PAYMENT_EFFECTIVE_DT                                         DATETIME             ;
,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
,COMMENT_TX                                                   TEXT(8000)           ;
,REASON_CD                                                    TEXT(20)             ;
,TYPE_CD                                                      TEXT(2)              NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,SRC_CREATE_DT                                                DATETIME             ;
,CPI_QUOTE_ID                                                 NUMBER(38,0)         NOT NULL;
,TOTAL_PREMIUM_NO                                             NUMBER(18,2)         NOT NULL;
,END_DT                                                       DATETIME             ;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,PAYMENT_CHANGE_AMOUNT_NO                                     NUMBER(18,2)         ;
,PRIOR_PAYMENT_AMOUNT_NO                                      NUMBER(18,2)         ;
,NEW_PAYMENT_AMOUNT_NO                                        NUMBER(18,2)         ;
,REPORTING_CANCEL_DT                                          DATETIME             ;
,EXECUTION_STEPS_TX                                           TEXT(8000)           ;
,EARNED_PAYMENT_AMOUNT_NO                                     NUMBER(18,2)         ;
,SUB_REASON_CD                                                TEXT(8)              ;
,IN_QUOTE_IN                                                  TEXT(2)              NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(30)             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CREATE_DT                                                    DATETIME             ;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
);

--DESC EDW_TEST.CDW.D_UT_CPI_QUOTE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_CPI_QUOTE
(
 D_CPI_QUOTE_ID                                               NUMBER(38,0)         NOT NULL;
,CPI_QUOTE_ID                                                 NUMBER(38,0)         NOT NULL;
,BASIS_TYPE_CD                                                TEXT(8000)           NOT NULL;
,BASIS_NO                                                     NUMBER(38,0)         NOT NULL;
,TERM_TYPE_CD                                                 TEXT(8000)           NOT NULL;
,TERM_NO                                                      NUMBER(38,0)         NOT NULL;
,CLOSE_DT                                                     DATETIME             ;
,CLOSE_REASON_CD                                              TEXT(8000)           NOT NULL;
,COVERAGE_AMOUNT_NO                                           NUMBER(38,0)         ;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(38,0)         NOT NULL;
,PAYMENT_INCREASE_METHOD_CD                                   TEXT(8000)           ;
,PAYMENT_INCREASE_METHOD_VALUE_NO                             NUMBER(38,0)         ;
,FIRST_PAYMENT_DIFFERENCE_NO                                  NUMBER(38,0)         ;
,NEW_PAYMENT_AMOUNT_NO                                        NUMBER(38,0)         ;
,MASTER_POLICY_ASSIGNMENT_ID                                  NUMBER(38,0)         ;
,TOTAL_COVERAGE_AMOUNT_NO                                     NUMBER(38,0)         ;
,FIRST_MONTH_BILL_NO                                          NUMBER(38,0)         ;
,NEXT_MONTH_BILL_NO                                           NUMBER(38,0)         ;
,IS_LAPSE_IN                                                  TEXT(1)              ;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE
(
 D_FPC_REQUIED_COVERAGE_RELATE_ID                             NUMBER(38,0)         NOT NULL;
,FPC_REQUIRED_COVERAGE_RELATE_ID                              NUMBER(38,0)         NOT NULL;
,D_FPC_ID                                                     NUMBER(38,0)         NOT NULL;
,D_REQUIRED_COVERAGE_ID                                       NUMBER(38,0)         NOT NULL;
,FPC_ID                                                       NUMBER(38,0)         NOT NULL;
,REQUIRED_COVERAGE_ID                                         NUMBER(38,0)         NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,HASH_ID                                                      TEXT(32)             ;
,PURGE_DT                                                     DATETIME             ;
,SRC_CREATE_DT                                                DATETIME             ;
,SRC_UPDATE_DT                                                DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          ;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
);

--DESC EDW_TEST.CDW.D_UT_FORCE_PLACED_CERTIFICATE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_FORCE_PLACED_CERTIFICATE
(
 D_FORCE_PLACED_CERTIFICATE_ID                                NUMBER(38,0)         NOT NULL;
,FORCE_PLACED_CERTIFICATE_ID                                  NUMBER(38,0)         NOT NULL;
,D_LOAN_ID                                                    NUMBER(38,0)         NOT NULL;
,LOAN_ID                                                      NUMBER(38,0)         ;
,D_CPI_QOUTE_ID                                               NUMBER(38,0)         NOT NULL;
,CPI_QUOTE_ID                                                 NUMBER(38,0)         NOT NULL;
,NUMBER_TX                                                    TEXT(18)             NOT NULL;
,PRODUCER_NUMBER_TX                                           TEXT(10)             NOT NULL;
,LOAN_NUMBER_TX                                               TEXT(18)             NOT NULL;
,EXPECTED_ISSUE_DT                                            DATETIME             ;
,ISSUE_DT                                                     DATETIME             ;
,EFFECTIVE_DT                                                 DATETIME             ;
,EXPIRATION_DT                                                DATETIME             ;
,CANCELLATION_DT                                              DATETIME             ;
,STATUS_CD                                                    TEXT(2)              NOT NULL;
,ACTIVE_IN                                                    TEXT(1)              NOT NULL;
,MONTHLY_BILLING_IN                                           TEXT(1)              NOT NULL;
,HOLD_IN                                                      TEXT(1)              NOT NULL;
,CLAIM_PENDING_IN                                             TEXT(1)              NOT NULL;
,GENERATION_SOURCE_CD                                         TEXT(2)              NOT NULL;
,CURRENT_PAYMENT_AMOUNT_NO                                    NUMBER(18,2)         NOT NULL;
,PREVIOUS_PAYMENT_AMOUNT_NO                                   NUMBER(18,2)         NOT NULL;
,CREATED_BY_TX                                                TEXT(15)             NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,PDF_GENERATE_CD                                              TEXT(4)              NOT NULL;
,TEMPLATE_ID                                                  NUMBER(38,0)         ;
,COVER_LETTER_TEMPLATE_ID                                     NUMBER(38,0)         ;
,MSG_LOG_TX                                                   TEXT(4000)           ;
,CARRIER_ID                                                   NUMBER(38,0)         ;
,D_MASTER_POLICY_ID                                           NUMBER(38,0)         NOT NULL;
,MASTER_POLICY_ID                                             NUMBER(38,0)         ;
,AUTH_REQ_DT                                                  DATETIME             ;
,QUICK_ISSUE_IN                                               TEXT(1)              ;
,BILL_CD                                                      TEXT(4)              ;
,BILLING_STATUS_CD                                            TEXT(4)              ;
,EARNED_PAYMENT_NO                                            NUMBER(10,0)         ;
,AUTHORIZED_BY_TX                                             TEXT(10)             ;
,D_MASTER_POLICY_ASSIGNMENT_ID                                NUMBER(38,0)         NOT NULL;
,MASTER_POLICY_ASSIGNMENT_ID                                  NUMBER(38,0)         ;
,LENDER_INTENT                                                TEXT(8000)           ;
,PAYMENT_REPORT_CD                                            TEXT(1)              ;
,PAYMENT_REPORT_DT                                            DATETIME             ;
,PIR_DT                                                       DATETIME             ;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
);

--DESC EDW_TEST.CDW.D_UT_INTERACTION_HISTORY;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_INTERACTION_HISTORY
(
 D_UT_INTERACTION_HISTORY_ID                                  NUMBER(38,0)         NOT NULL;
,INTERACTION_HISTORY_ID                                       NUMBER(38,0)         NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,PROPERTY_ID                                                  NUMBER(38,0)         ;
,D_PROPERTY_ID                                                NUMBER(38,0)         ;
,REQUIRED_COVERAGE_ID                                         NUMBER(38,0)         ;
,D_REQUIRED_COVERAGE_ID                                       NUMBER(38,0)         ;
,TYPE_CD                                                      TEXT(15)             ;
,REASON                                                       TEXT(2048)           ;
,INSURANCE_COMPANY                                            TEXT(2048)           ;
,KEYED_POLICY_EFFECTIVE_DT                                    DATETIME             ;
,CALL_TYPE                                                    TEXT(2048)           ;
,RESOLUTION_TYPE                                              TEXT(2048)           ;
,IH_ACTION                                                    TEXT(2048)           ;
,RESOLUTION_CODE                                              TEXT(2048)           ;
,REVIEW_STATUS                                                TEXT(2048)           ;
,RC                                                           TEXT(2048)           ;
,DATA_SOURCE                                                  TEXT(2048)           ;
,CALL_WITH                                                    TEXT(2048)           ;
,MAIL_STATUS                                                  TEXT(2048)           ;
,STATUS                                                       TEXT(2048)           ;
,SENT_TO_--DESC                                                 TEXT(2048)           ;
,AGENT_LETTER_OPTION_VALUE                                    TEXT(2048)           ;
,ADDITIONAL_COMMENT                                           TEXT(2048)           ;
,CALL_ATTEMPTS                                                TEXT(2048)           ;
,SH_TYPE                                                      TEXT(2048)           ;
,AGENT_NAME                                                   TEXT(2048)           ;
,AGENT_EMAIL                                                  TEXT(2048)           ;
,AGENT_FAX                                                    TEXT(2048)           ;
,STATUS_DATE                                                  TEXT(2048)           ;
,SEQUENCE                                                     TEXT(2048)           ;
,ISSUE_DT                                                     DATETIME             ;
,DOCUMENT_ID                                                  NUMBER(38,0)         ;
,CREATE_USER_TX                                               TEXT(50)             ;
,RELATE_ID                                                    NUMBER(38,0)         ;
,RELATE_CLASS_TX                                              TEXT(100)            ;
,SRC_CREATE_DT                                                DATETIME             ;
,PREMIUMDUEAMOUNT                                             NUMBER(19,2)         ;
,TRADING_PARTNER_ID                                           NUMBER(38,0)         ;
,D_TRADING_PARTNER_ID                                         NUMBER(38,0)         ;
,DATE_CERT_MAILED_DT                                          TEXT(2048)           ;
,HASH_ID                                                      TEXT(32)             ;
,SUBTYPE                                                      TEXT(2048)           ;
,EVENTSTATUS                                                  TEXT(2048)           ;
,PURGE_DT                                                     DATETIME             ;
,SPECIAL_HANDLING_TXT                                         TEXT(200000)         ;
,SOURCE_CODE                                                  TEXT(40)             ;
,REASON_CODE                                                  TEXT(40)             ;
,WEB_VERIFICATION                                             TEXT(10)             ;
,LOAN_ID                                                      NUMBER(38,0)         ;
,EFFECTIVE_DT                                                 DATETIME             ;
,EFFECTIVE_ORDER_NO                                           NUMBER(18,2)         ;
,NOTE_TX                                                      TEXT(8000)           ;
,ALERT_IN                                                     TEXT(1)              ;
,PENDING_IN                                                   TEXT(1)              ;
,IN_HOUSE_ONLY_IN                                             TEXT(1)              ;
,SRC_UPDATE_DT                                                DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          ;
,DELETE_ID                                                    NUMBER(38,0)         ;
,ARCHIVED_IN                                                  TEXT(1)              ;
,TRANSACTION_ID                                               NUMBER(38,0)         ;
,XML_CALL_ID                                                  TEXT(30)             ;
,XML_INSURANCE_DOCUMENT_ORIGINATOR                            TEXT(1000)           ;
,XML_SUB_RESOLUTION_CD                                        TEXT(1)              ;
,XML_VEHICLE_DEDUCTIBLE                                       TEXT(10)             ;
,XML_VEHICLE_EXPIRATION_DT                                    DATETIME             ;
,XML_VEHICLE_IS_LAPSE                                         TEXT(5)              ;
,XML_VEHICLE_IS_LIEN_HOLDER                                   TEXT(5)              ;
,XML_VEHICLE_LAPSE_DATES                                      TEXT(25)             ;
,XML_VEHICLE_LH_ADDED_DT                                      TEXT(10)             ;
,XML_VEHICLE_NEW_BUSINESS                                     TEXT(30)             ;
,XML_VEHICLE_NO_CVG_PRIOR_DT                                  DATETIME             ;
,XML_VEHICLE_SUSP_COMP_CLSN                                   TEXT(5)              ;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE
(
 D_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE_ID                   NUMBER(38,0)         NOT NULL;
,LENDER_COLLATERAL_GROUP_COVERAGE_TYPE_ID                     NUMBER(38,0)         NOT NULL;
,TYPE_CD                                                      TEXT(60)             NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,LENDER_PRODUCT_ID                                            NUMBER(38,0)         NOT NULL;
,D_LENDER_PRODUCT_ID                                          NUMBER(38,0)         ;
,LCCG_ID                                                      NUMBER(38,0)         NOT NULL;
,D_LCCG_ID                                                    NUMBER(38,0)         ;
,BRANCH_LENDER_ORG_ID                                         NUMBER(38,0)         ;
,D_BRANCH_LENDER_ORG_ID                                       NUMBER(38,0)         ;
,DIVISION_LENDER_ORG_ID                                       NUMBER(38,0)         ;
,D_DIVISION_LENDER_ORG_ID                                     NUMBER(38,0)         ;
,CREDIT_SCORE_TX                                              TEXT(40)             ;
,LIEN_POSITION_NO                                             NUMBER(11,0)         ;
,FLOOD_ZONE_AV_IN                                             TEXT(1)              ;
,OPTIONAL_IN                                                  TEXT(1)              NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CURRENT_RECORD_IND                                           TEXT(1)              NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
);

----DESC EDW_TEST.CDW.D_UT_OWNER_POLICY;

--CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_OWNER_POLICY
--(
-- D_UT_OWNER_POLICY_ID                                         NUMBER(38,0)         NOT NULL;
--,OWNER_POLICY_ID                                              NUMBER(38,0)         NOT NULL;
--,POLICY_NUMBER_TX                                             TEXT(60)             ;
--,STATUS_CD                                                    TEXT(2)              NOT NULL;
--,SUB_STATUS_CD                                                TEXT(2)              NOT NULL;
--,SOURCE_CD                                                    TEXT(8)              NOT NULL;
--,EFFECTIVE_DT                                                 DATETIME             ;
--,EXPIRATION_DT                                                DATETIME             ;
--,CANCELLATION_DT                                              DATETIME             ;
--,CANCEL_REASON_CD                                             TEXT(8)              NOT NULL;
--,BIC_ID                                                       NUMBER(38,0)         ;
--,D_BIC_ID                                                     NUMBER(38,0)         ;
--,BIC_NAME_TX                                                  TEXT(200)            ;
--,BIC_TAX_ID_TX                                                TEXT(60)             ;
--,D_BIA_ID                                                     NUMBER(38,0)         ;
--,BIA_ID                                                       NUMBER(38,0)         ;
--,ADDITIONAL_NAMED_INSURED_IN                                  TEXT(1)              NOT NULL;
--,EXCESS_IN                                                    TEXT(1)              NOT NULL;
--,SRC_CREATE_DT                                                DATETIME             NOT NULL;
--,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
--,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
--,PURGE_DT                                                     DATETIME             ;
--,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
--,FLOOD_ZONE_TX                                                TEXT(20)             ;
--,FLOOD_ZONE_GRANDFATHER_IN                                    TEXT(1)              ;
--,BASE_PROPERTY_TYPE_CD                                        TEXT(8)              NOT NULL;
--,LIENHOLDER_STATUS_CD                                         TEXT(20)             ;
--,UNIT_OWNERS_IN                                               TEXT(1)              ;
--,EXCLUDED_DRIVER_IN                                           TEXT(1)              ;
--,DOC_PROBLEM_CD                                               TEXT(24)             ;
--,MOST_RECENT_MAIL_DT                                          DATETIME             ;
--,MOST_RECENT_TXN_TYPE_CD                                      TEXT(8)              ;
--,OTHER_IMPAIRMENT_CD                                          TEXT(8)              ;
--,MOST_RECENT_EFFECTIVE_DT                                     DATETIME             ;
--,LAST_UPDATED_FROM_LENDER_FILE_IN                             TEXT(1)              NOT NULL;
--,LAST_UPDATE_FROM_LENDER_FILE_DT                              DATETIME             ;
--,FLOOD_INSURANCE_TYPE_CD                                      TEXT(20)             NOT NULL;
--,GRACE_PERIOD_END_DT                                          DATETIME             ;
--,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
--,HASH_ID                                                      TEXT(32)             NOT NULL;
--,CREATE_DT                                                    DATETIME             NOT NULL;
--,UPDATE_DT                                                    DATETIME             NOT NULL;
--,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
--,EFFECTIVE_FROM_DT                                            DATE                 NOT NULL;
--,EFFECTIVE_TO_DT                                              DATE                 NOT NULL;
--,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
--);

--DESC EDW_TEST.CDW.D_UT_QUALITY_CONTROL_ITEM;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_QUALITY_CONTROL_ITEM
(
 D_QUALITY_CONTROL_ITEM_ID                                    NUMBER(38,0)         NOT NULL;
,QUALITY_CONTROL_ITEM_ID                                      NUMBER(38,0)         NOT NULL;
,QC_BATCH_ITEM_ID                                             NUMBER(38,0)         NOT NULL;
,QC_BATCH_TYPE_CD                                             TEXT(20)             NOT NULL;
,QC_RULE_DEF_CD                                               TEXT(100)            NOT NULL;
,QC_BATCH_NAME_TX                                             TEXT(200)            NOT NULL;
,QC_BATCH_RUN_DT                                              DATETIME             NOT NULL;
,LOAN_ID                                                      NUMBER(38,0)         NOT NULL;
,PROPERTY_ID                                                  NUMBER(38,0)         NOT NULL;
,REQUIRED_COVERAGE_ID                                         NUMBER(38,0)         NOT NULL;
,SUMMARY_STATUS_CD                                            TEXT(8)              ;
,SUMMARY_SUB_STATUS_CD                                        TEXT(8)              ;
,STATUS_CD                                                    TEXT(20)             NOT NULL;
,MEMO_TX                                                      TEXT(2000)           ;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,QC_BATCH_DEF_ID                                              NUMBER(38,0)         ;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,HASH_ID                                                      TEXT(30)             NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_REF_CODE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_REF_CODE
(
 D_UT_REF_CODE_ID                                             NUMBER(38,0)         NOT NULL;
,REF_CODE_ID                                                  NUMBER(38,0)         NOT NULL;
,ACTIVE_IN                                                    TEXT(1)              NOT NULL;
,AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,CODE_CD                                                      TEXT(50)             NOT NULL;
,--DESCRIPTION_TX                                               TEXT(1000)           NOT NULL;
,DOMAIN_CD                                                    TEXT(30)             NOT NULL;
,LOCK_ID                                                      NUMBER(38,0)         NOT NULL;
,MEANING_TX                                                   TEXT(1000)           NOT NULL;
,ORDER_NO                                                     NUMBER(38,0)         NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
);

--DESC EDW_TEST.CDW.D_UT_REF_CODE_ATTRIBUTE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_REF_CODE_ATTRIBUTE
(
 D_UT_REF_CODE_ATTRIBUTE_ID                                   NUMBER(38,0)         NOT NULL;
,REF_CODE_ATTRIBUTE_ID                                        NUMBER(38,0)         NOT NULL;
,AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,ATTRIBUTE_CD                                                 TEXT(30)             NOT NULL;
,DOMAIN_CD                                                    TEXT(30)             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,REF_CD                                                       TEXT(50)             NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,VALUE_TX                                                     TEXT(100)            NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
);

--DESC EDW_TEST.CDW.D_UT_UTL_MATCH_RESULT;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_UTL_MATCH_RESULT
(
 D_UT_UTL_MATCH_RESULT_ID                                     NUMBER(38,0)         NOT NULL;
,UTL_MATCH_RESULT_ID                                          NUMBER(38,0)         NOT NULL;
,UTL_LOAN_ID                                                  NUMBER(38,0)         NOT NULL;
,D_PROPERTY_ID                                                NUMBER(38,0)         NOT NULL;
,PROPERTY_ID                                                  NUMBER(38,0)         NOT NULL;
,D_LOAN_ID                                                    NUMBER(38,0)         NOT NULL;
,LOAN_ID                                                      NUMBER(38,0)         ;
,SCORE_NO                                                     NUMBER(11,0)         NOT NULL;
,MATCH_RESULT_CD                                              TEXT(20)             NOT NULL;
,USER_MATCH_RESULT_CD                                         TEXT(20)             ;
,USER_MATCH_TX                                                TEXT(30)             ;
,MSG_LOG_TX                                                   TEXT(8000)           ;
,LOG_TX                                                       TEXT(8000)           ;
,APPLY_STATUS_CD                                              TEXT(20)             NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,UTL_OWNER_POLICY_ID                                          NUMBER(38,0)         NOT NULL;
,SCORE_PERCENT_NO                                             NUMBER(38,0)         ;
,UTL_PROPERTY_ID                                              NUMBER(38,0)         ;
,ESCROW_IN                                                    TEXT(1)              NOT NULL;
,UTL_VERSION_NO                                               NUMBER(11,0)         ;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,CURRENT_RECORD_IND                                           TEXT(1)              NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_WORK_ITEM;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_WORK_ITEM
(
 D_WORK_ITEM_ID                                               NUMBER(38,0)         NOT NULL;
,RELATE_TYPE                                                  TEXT(256)            ;
,STATUS                                                       TEXT(256)            ;
,CURRENT_QUEUE_ID                                             TEXT(256)            ;
,D_REQUIRED_COVERAGE_ID                                       NUMBER(38,0)         ;
,D_FPC_ID                                                     NUMBER(38,0)         ;
,WORK_ITEM_ID                                                 NUMBER(38,0)         ;
,WF_--DESC_WORK_ITEM_TYPE                                       TEXT(80)             ;
,WORK_QUEUE_NM                                                TEXT(30)             ;
,UPDATE_DT                                                    DATETIME             ;
,CREATE_DT                                                    DATETIME             ;
,CPI_CANCEL_STATUS                                            TEXT(50)             ;
,ESCROW_REGENRATED                                            TEXT(15)             ;
,BILLING_GRP_DETAIL                                           TEXT(50)             ;
,USER_ROLE_CD                                                 TEXT(100)            ;
,DELAYED_UNTILL_DT                                            DATETIME             ;
,BORROWERNAME                                                 TEXT(100)            ;
,DEFAULT_SORTBY_TX                                            TEXT(20)             ;
,TEMPCOLLATERAL_LINE1_TX                                      TEXT(100)            ;
,TEMPCOLLATERAL_LINE2_TX                                      TEXT(100)            ;
,TEMPCOLLATERAL_CITY_TX                                       TEXT(40)             ;
,TEMPCOLLATERAL_STATE_TX                                      TEXT(30)             ;
,TEMPCOLLATERAL_ZIP_TX                                        TEXT(30)             ;
,TEMPCOLLATERAL_YEAR_TX                                       TEXT(4)              ;
,TEMPCOLLATERAL_MAKE_TX                                       TEXT(30)             ;
,TEMPCOLLATERAL_MODEL_TX                                      TEXT(30)             ;
,TEMPCOLLATERAL_VIN_TX                                        TEXT(18)             ;
,TEMPCOLLATERAL_--DESC                                          TEXT(100)            ;
,TEMPPROPERTY_TYPE                                            TEXT(20)             ;
,TEMPPROPERTY_TYPE_CD                                         TEXT(20)             ;
,TEMPLOAN_NO                                                  TEXT(20)             ;
,TEMPREQUIREDCOVERAGE_TYPE_TX                                 TEXT(30)             ;
,TEMPREQUIREDCOVERAGE_STATUSMEANING_TX                        TEXT(30)             ;
,TEMPPROPERTY_ID                                              NUMBER(38,0)         ;
,TEMPRC_ID                                                    NUMBER(38,0)         ;
,TEMPOWNER_NAME                                               TEXT(100)            ;
,TEMPLENDER_NAME                                              TEXT(100)            ;
,TEMPLENDER_CODE                                              TEXT(20)             ;
,TEMPLENDER_ID                                                NUMBER(38,0)         ;
,TEMPLENDER_LASTCYCLEDATE                                     DATETIME             ;
,TEMPLENDER_NEXTCYCLEDATE                                     DATETIME             ;
,COLLATERAL_EFFECTIVEDATE                                     DATETIME             ;
,COLLATERAL_ENDDATE                                           DATETIME             ;
,COLLATERAL_CANCELREASON                                      TEXT(50)             ;
,COLLATERAL_POLICYTYPE                                        TEXT(50)             ;
,COLLATERAL_RELATECLASS                                       TEXT(50)             ;
,COLLATERAL_RELATEID                                          NUMBER(38,0)         ;
,TEMP_EVALUATION_ERROR                                        TEXT(4000)           ;
,TEMP_INFORMATION                                             TEXT(4000)           ;
,RELATE_ID                                                    NUMBER(38,0)         ;
,CURRENT_OWNER_ID                                             NUMBER(38,0)         ;
,WORKFLOW_DEFINITION_ID                                       NUMBER(38,0)         ;
,LENDER_ID                                                    NUMBER(38,0)         ;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,UPDATE_USER_TX                                               TEXT(50)             NOT NULL;
,HASH_ID                                                      TEXT(50)             NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,BILLINGGROUP_WORKITEMID                                      TEXT(100)            ;
,BILLINGGROUP_RELATECLASSID                                   TEXT(100)            ;
,BILLINGGROUP_LOANID                                          TEXT(100)            ;
,BILLINGGROUP_PROPERTYID                                      TEXT(100)            ;
,BILLINGGROUP_REQUIREDCOVERAGEID                              TEXT(100)            ;
,BILLINGGROUP_CERTIFICATE                                     TEXT(100)            ;
,BILLINGGROUP_LOANNUMBER                                      TEXT(100)            ;
,BILLINGGROUP_COLLATERALNUMBER                                TEXT(100)            ;
,BILLINGGROUP_OWNERNAME                                       TEXT(100)            ;
,BILLINGGROUP_--DESCRIPTION                                     TEXT(100)            ;
,BILLINGGROUP_VIN                                             TEXT(100)            ;
,BILLINGGROUP_BASIS                                           TEXT(100)            ;
,BILLINGGROUP_EFFECTIVEDATE                                   DATETIME             ;
,BILLINGGROUP_CPIPOLICYEXPCXLDATE                             DATETIME             ;
,BILLINGGROUP_TERM                                            TEXT(100)            ;
,BILLINGGROUP_ISSUEREASON                                     TEXT(100)            ;
,BILLINGGROUP_EARNEDISSUEAMOUNT                               TEXT(100)            ;
,BILLINGGROUP_PASTDUE                                         TEXT(100)            ;
,BILLINGGROUP_PASTDUESTATUS                                   TEXT(100)            ;
,BILLINGGROUP_BRANCH                                          TEXT(100)            ;
,BILLINGGROUP_DIVISION                                        TEXT(100)            ;
,BILLINGGROUP_PROPERTYTYPE                                    TEXT(100)            ;
,BILLINGGROUP_LINE1                                           TEXT(100)            ;
,BILLINGGROUP_LINE2                                           TEXT(100)            ;
,BILLINGGROUP_CITY                                            TEXT(100)            ;
,BILLINGGROUP_STATE                                           TEXT(100)            ;
,BILLINGGROUP_POSTALCODE                                      TEXT(100)            ;
,BILLINGGROUP_COUNTRY                                         TEXT(100)            ;
,BILLINGGROUP_LENDERRESPONSE                                  TEXT(100)            ;
,BILLINGGROUP_ACTION                                          TEXT(100)            ;
,BILLINGGROUP_P--DESCRPTION                                     TEXT(100)            ;
,BILLINGGROUP_LENDERSTARTDATE                                 DATETIME             ;
,BILLINGGROUP_LENDERENDDATE                                   DATETIME             ;
,BILLINGGROUP_LENDERCOMMENT                                   TEXT(100)            ;
,APPROVENOTICECOUNT                                           NUMBER(38,0)         ;
,BILLINGGROUP_STATEMENT_DT                                    DATETIME             ;
,FPC_ID                                                       NUMBER(38,0)         ;
,REQUIRED_COVERAGE_ID                                         NUMBER(38,0)         ;
,D_LENDER_ID                                                  NUMBER(38,0)         ;
,RECORD_TYPE                                                  TEXT(1)              ;
,DETAIL_RELATETYPE                                            TEXT(50)             ;
,DETAIL_CHECKED                                               TEXT(10)             ;
,DETAIL_ACTIONNEEDED                                          TEXT(500)            ;
,DETAIL_FIELDDISPLAYNAME                                      TEXT(100)            ;
,DETAIL_RELATEID                                              NUMBER(38,0)         ;
,WI_PURGE_DT                                                  DATETIME             ;
,BG_PURGE_DT                                                  DATETIME             ;
,WQ_PURGE_DT                                                  DATETIME             ;
,WF_--DESC_PURGE_DT                                             DATETIME             ;
,BG_ID                                                        NUMBER(38,0)         ;
,WQ_ID                                                        NUMBER(38,0)         ;
,WF_--DESC_ID                                                   NUMBER(38,0)         ;
,XML_MEANING_TX                                               TEXT(100)            ;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.CDW.D_UT_WORK_QUEUE;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_WORK_QUEUE
(
 D_UT_WORK_QUEUE_ID                                           NUMBER(38,0)         NOT NULL;
,NAME_TX                                                      TEXT(60)             NOT NULL;
,--DESCRIPTION_TX                                               TEXT(160)            ;
,STATUS_CD                                                    TEXT(40)             ;
,ACTIVE_IN                                                    TEXT(1)              NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,SRC_UPDATE_DT                                                DATETIME             ;
,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,EXCLUSIVE_IN                                                 TEXT(1)              NOT NULL;
,EVALUATION_ORDER_NO                                          NUMBER(10,2)         NOT NULL;
,WORKFLOW_DEFINITION_ID                                       NUMBER(38,0)         NOT NULL;
,WEB_IN                                                       TEXT(1)              NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,WORK_QUEUE_ID                                                NUMBER(38,0)         ;
);

--DESC EDW_TEST.CDW.D_UT_WORKFLOW_DEFINITION;

CREATE OR REPLACE TABLE EDW_PROD.CDW.D_UT_WORKFLOW_DEFINITION
(
 D_UT_WORKFLOW_DEFINITION_ID                                  NUMBER(38,0)         NOT NULL;
,NAME_TX                                                      TEXT(30)             NOT NULL;
,--DESCRIPTION_TX                                               TEXT(80)             ;
,BATCH_ID                                                     NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(15)             NOT NULL;
,HASH_ID                                                      TEXT(32)             ;
,PURGE_DT                                                     DATETIME             ;
,STATE_TRANSITION_DOMAIN_CD                                   TEXT(60)             ;
,QUEUE_ASSIGNMENT_DOMAIN_CD                                   TEXT(60)             ;
,SAS70_CONTROL_TX                                             TEXT(60)             ;
,ACTIVE_IN                                                    TEXT(1)              ;
,SRC_CREATE_DT                                                DATETIME             ;
,SRC_UPDATE_DT                                                DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          ;
,WORKFLOW_TYPE_CD                                             TEXT(50)             ;
,EFFECTIVE_FROM_DT                                            DATETIME             NOT NULL;
,EFFECTIVE_TO_DT                                              DATETIME             NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,WORKFLOW_DEFINITION_ID                                       NUMBER(38,0)         NOT NULL;
);


--DESC EDW_TEST.CDW.D_UT_VUT_IMAGE_QUEUE;

create or replace TABLE EDW_PROD.CDW.D_UT_VUT_IMAGE_QUEUE (
	D_VUT_IMAGE_QUEUE_ID NUMBER(38,0) NOT NULL,
	IMAGE_QUEUE_ID NUMBER(38,0) NOT NULL,
	TEMPESTID VARCHAR(500) NOT NULL,
	LENDERKEY NUMBER(10,0),
	USERIDWORKING VARCHAR(15),
	DOCUMENTTYPE VARCHAR(10),
	IMAGETYPE VARCHAR(4),
	IMAGECOMMENT VARCHAR(2000),
	MODIFIEDDATE TIMESTAMP_NTZ(9),
	CREATEDBY VARCHAR(15),
	CREATEDDATE TIMESTAMP_NTZ(9),
	FORMKEY NUMBER(10,0),
	BATCHID VARCHAR(50),
	BATCHFILEDATE TIMESTAMP_NTZ(9),
	BATCHPAGE NUMBER(10,0),
	LASTMODIFIEDBY VARCHAR(15),
	LASTMODIFIEDDATE TIMESTAMP_NTZ(9),
	TEMPESTIDBAK VARCHAR(50),
	UNCDOCID VARCHAR(100),
	IMAGE_SOURCE_CD VARCHAR(30),
	PROPERTY_TYPE_CD VARCHAR(30),
	DOCUMENT_CONTAINER_ID NUMBER(38,0),
	PURGE_DT TIMESTAMP_NTZ(9),
	MSG_LOG_TX VARCHAR(4000),
	LOCK_ID NUMBER(3,0) NOT NULL,
	STATUS_CD VARCHAR(30),
	REJECT_REASON_CD VARCHAR(4),
	UNITRACDOCUMENTID NUMBER(38,0),
	BATCH_ID NUMBER(38,0) NOT NULL,
	HASH_ID VARCHAR(32) NOT NULL,
	CREATE_DT TIMESTAMP_NTZ(9) NOT NULL,
	UPDATE_DT TIMESTAMP_NTZ(9),
	UPDATE_USER_TX VARCHAR(15),
	EFFECTIVE_FROM_DT TIMESTAMP_NTZ(9) NOT NULL,
	EFFECTIVE_TO_DT TIMESTAMP_NTZ(9) NOT NULL,
	CURRENT_FLG VARCHAR(1)
);