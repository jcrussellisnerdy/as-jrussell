USE ROLE owner_edw_prod;
USE WAREHOUSE EDW_PROD_INFA_WH;
USE DATABASE EDW_PROD;
USE SCHEMA STG;

--DESC EDW_TEST.STG.D_OPEN_CERTIFICATE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_OPEN_CERTIFICATE_TEMP
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

--DESC EDW_TEST.STG.D_UT_AGENCY_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_AGENCY_TEMP
(
 AGENCY_ID                                                    NUMBER(38,0)         NOT NULL;
,D_AGENCY_ID                                                  NUMBER(38,0)         NOT NULL;
,SHORT_NAME_TX                                                TEXT(8000)           NOT NULL;
,NAME_TX                                                      TEXT(8000)           NOT NULL;
,WEB_ADDRESS_TX                                               TEXT(8000)           ;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,SRC_UPDATE_DT                                                DATETIME             ;
,UPDATE_USER_TX                                               TEXT(8000)           ;
,LOCK_ID                                                      NUMBER(38,0)         NOT NULL;
,MAIN_OFFICE_ID                                               NUMBER(38,0)         ;
,D_MAIN_OFFICE_ID                                             NUMBER(38,0)         ;
,TAX_ID_TX                                                    TEXT(8000)           ;
,ACTIVE_IN                                                    TEXT(8000)           NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
,EFFECTIVE_FROM_DT                                            DATE                 NOT NULL;
,EFFECTIVE_TO_DT                                              DATE                 NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.STG.D_UT_CARRIER_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_CARRIER_TEMP
(
 D_CARRIER_ID                                                 NUMBER(38,0)         ;
,CARRIER_ID                                                   NUMBER(38,0)         ;
,NAME_TX                                                      TEXT(100)            ;
,BATCH_ID                                                     NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             ;
,UPDATE_DT                                                    DATETIME             ;
,UPDATE_USER_TX                                               TEXT(15)             ;
,AGENCY_ID                                                    NUMBER(38,0)         ;
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
,EFFECTIVE_FROM_DT                                            DATETIME             ;
,EFFECTIVE_TO_DT                                              DATETIME             ;
,CURRENT_FLG                                                  TEXT(1)              ;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);

--DESC EDW_TEST.STG.D_UT_COLLATERAL_CODE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_COLLATERAL_CODE_TEMP
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

--DESC EDW_TEST.STG.D_UT_CPI_ACTIVITY_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_CPI_ACTIVITY_TEMP
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

--DESC EDW_TEST.STG.D_UT_CPI_QUOTE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_CPI_QUOTE_TEMP
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

--DESC EDW_TEST.STG.D_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE_TEMP
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

--DESC EDW_TEST.STG.D_UT_FORCE_PLACED_CERTIFICATE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_FORCE_PLACED_CERTIFICATE_TEMP
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

--DESC EDW_TEST.STG.D_UT_INTERACTION_HISTORY_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_INTERACTION_HISTORY_TEMP
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
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,CURRENT_FLG                                                  TEXT(1)              ;
);

--DESC EDW_TEST.STG.D_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE_TEMP
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

/*
--DESC EDW_TEST.STG.D_UT_OWNER_POLICY_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_OWNER_POLICY_TEMP
(
 D_UT_OWNER_POLICY_ID                                         NUMBER(38,0)         NOT NULL;
,OWNER_POLICY_ID                                              NUMBER(38,0)         NOT NULL;
,POLICY_NUMBER_TX                                             TEXT(60)             ;
,STATUS_CD                                                    TEXT(2)              NOT NULL;
,SUB_STATUS_CD                                                TEXT(2)              NOT NULL;
,SOURCE_CD                                                    TEXT(8)              NOT NULL;
,EFFECTIVE_DT                                                 DATETIME             ;
,EXPIRATION_DT                                                DATETIME             ;
,CANCELLATION_DT                                              DATETIME             ;
,CANCEL_REASON_CD                                             TEXT(8)              NOT NULL;
,BIC_ID                                                       NUMBER(38,0)         ;
,D_BIC_ID                                                     NUMBER(38,0)         ;
,BIC_NAME_TX                                                  TEXT(200)            ;
,BIC_TAX_ID_TX                                                TEXT(60)             ;
,D_BIA_ID                                                     NUMBER(38,0)         ;
,BIA_ID                                                       NUMBER(38,0)         ;
,ADDITIONAL_NAMED_INSURED_IN                                  TEXT(1)              NOT NULL;
,EXCESS_IN                                                    TEXT(1)              NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,FLOOD_ZONE_TX                                                TEXT(20)             ;
,FLOOD_ZONE_GRANDFATHER_IN                                    TEXT(1)              ;
,BASE_PROPERTY_TYPE_CD                                        TEXT(8)              NOT NULL;
,LIENHOLDER_STATUS_CD                                         TEXT(20)             ;
,UNIT_OWNERS_IN                                               TEXT(1)              ;
,EXCLUDED_DRIVER_IN                                           TEXT(1)              ;
,DOC_PROBLEM_CD                                               TEXT(24)             ;
,MOST_RECENT_MAIL_DT                                          DATETIME             ;
,MOST_RECENT_TXN_TYPE_CD                                      TEXT(8)              ;
,OTHER_IMPAIRMENT_CD                                          TEXT(8)              ;
,MOST_RECENT_EFFECTIVE_DT                                     DATETIME             ;
,LAST_UPDATED_FROM_LENDER_FILE_IN                             TEXT(1)              NOT NULL;
,LAST_UPDATE_FROM_LENDER_FILE_DT                              DATETIME             ;
,FLOOD_INSURANCE_TYPE_CD                                      TEXT(20)             NOT NULL;
,GRACE_PERIOD_END_DT                                          DATETIME             ;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
,EFFECTIVE_FROM_DT                                            DATE                 NOT NULL;
,EFFECTIVE_TO_DT                                              DATE                 NOT NULL;
,CURRENT_FLG                                                  TEXT(1)              NOT NULL;
);

*/

--DESC EDW_TEST.STG.D_UT_QUALITY_CONTROL_ITEM_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_QUALITY_CONTROL_ITEM_TEMP
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

--DESC EDW_TEST.STG.D_UT_REF_CODE_ATTRIBUTE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_REF_CODE_ATTRIBUTE_TEMP
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

--DESC EDW_TEST.STG.D_UT_REF_CODE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_REF_CODE_TEMP
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

--DESC EDW_TEST.STG.D_UT_UTL_MATCH_RESULT_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_UTL_MATCH_RESULT_TEMP
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

--DESC EDW_TEST.STG.D_UT_WORK_ITEM_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_WORK_ITEM_TEMP
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

--DESC EDW_TEST.STG.D_UT_WORK_QUEUE_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_WORK_QUEUE_TEMP
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

--DESC EDW_TEST.STG.D_UT_WORKFLOW_DEFINITION_TEMP;

CREATE OR REPLACE TABLE EDW_PROD.STG.D_UT_WORKFLOW_DEFINITION_TEMP
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

--DESC EDW_TEST.STG.LND_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE;

CREATE OR REPLACE TABLE EDW_PROD.STG.LND_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE
(
 ID                                                           NUMBER(38,0)         NOT NULL;
,TYPE_CD                                                      TEXT(60)             NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,LENDER_PRODUCT_ID                                            NUMBER(38,0)         NOT NULL;
,LCCG_ID                                                      NUMBER(38,0)         NOT NULL;
,BRANCH_LENDER_ORG_ID                                         NUMBER(38,0)         ;
,DIVISION_LENDER_ORG_ID                                       NUMBER(38,0)         ;
,CREDIT_SCORE_TX                                              TEXT(40)             ;
,LIEN_POSITION_NO                                             NUMBER(11,0)         ;
,FLOOD_ZONE_AV_IN                                             TEXT(1)              ;
,OPTIONAL_IN                                                  TEXT(1)              NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
);

--DESC EDW_TEST.STG.LND_UT_OPEN_CERTIFICATE;

CREATE OR REPLACE TABLE EDW_PROD.STG.LND_UT_OPEN_CERTIFICATE
(
 AGENCY_CODE_TX                                               TEXT(20)             NOT NULL;
,LENDER_CODE_TX                                               TEXT(10)             NOT NULL;
,LENDER_NAME_TX                                               TEXT(100)            NOT NULL;
,LOAN_ID                                                      NUMBER(38,0)         NOT NULL;
,LOAN_NUMBER_TX                                               TEXT(18)             NOT NULL;
,LOAN_STATUS_CD                                               TEXT(50)             ;
,BRANCH_CODE_TX                                               TEXT(20)             ;
,COLLATERAL_STATUS_CD                                         TEXT(2)              ;
,COLLATERAL_NUMBER_NO                                         NUMBER(38,0)         ;
,FPC_ID                                                       NUMBER(38,0)         NOT NULL;
,CPI_QUOTE_ID                                                 NUMBER(38,0)         NOT NULL;
,FPC_NUMBER_TX                                                TEXT(18)             NOT NULL;
,EFFECTIVE_DT                                                 DATETIME             ;
,EXPIRATION_DT                                                DATETIME             ;
,CANCELLATION_DT                                              DATETIME             ;
,ISSUE_DT                                                     DATETIME             ;
,ISSUE_REASON_CD                                              TEXT(10)             ;
,BILLING_STATUS_CD                                            TEXT(4)              ;
,QUICK_ISSUE_IN                                               TEXT(1)              ;
,HOLD_IN                                                      TEXT(1)              ;
,PROPERTY_ID                                                  NUMBER(38,0)         ;
,RC_ID                                                        NUMBER(38,0)         ;
,RC_COVERAGE_TYPE_CD                                          TEXT(30)             ;
,RC_STATUS_CD                                                 TEXT(2)              ;
,DELAY_DAYS_NO                                                NUMBER(38,0)         ;
,LENDER_PRODUCT_ID                                            NUMBER(38,0)         ;
,LENDER_PRODUCT_BASIC_TYPE_CD                                 TEXT(18)             ;
,BILL_DT                                                      DATETIME             ;
,ACTIVITY_AMOUNT_NO                                           NUMBER(30,2)         ;
,AR_AMOUNT_NO                                                 NUMBER(30,2)         ;
,CASH_AMOUNT_NO                                               NUMBER(30,2)         ;
,TO_BE_BILLED_AMOUNT_NO                                       NUMBER(32,2)         ;
,SHOULD_BE_BILLED_AMOUNT_NO                                   NUMBER(32,2)         ;
,AGE_0_42_NO                                                  NUMBER(32,2)         ;
,AGE_43_60_NO                                                 NUMBER(32,2)         ;
,AGE_61_90_NO                                                 NUMBER(32,2)         ;
,AGE_91_120_NO                                                NUMBER(32,2)         ;
,AGE_120_NO                                                   NUMBER(32,2)         ;
,REFUND_AMOUNT_NO                                             NUMBER(30,2)         ;
,BILLED_AMOUNT_NO                                             NUMBER(30,2)         ;
,WEEKLY_ID                                                    NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             ;
,UPDATE_DT                                                    DATETIME             ;
,UPDATE_USER_TX                                               TEXT(15)             ;
,BATCH_ID                                                     NUMBER(38,0)         ;
,HASH_ID                                                      TEXT(32)             ;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
,RUN_DTX                                                      DATE                 ;
);

--DESC EDW_TEST.STG.STG_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE
(
 ID                                                           NUMBER(38,0)         NOT NULL;
,TYPE_CD                                                      TEXT(60)             NOT NULL;
,SRC_CREATE_DT                                                DATETIME             NOT NULL;
,SRC_UPDATE_DT                                                DATETIME             NOT NULL;
,UPDATE_USER_TX                                               TEXT(30)             NOT NULL;
,PURGE_DT                                                     DATETIME             ;
,LOCK_ID                                                      NUMBER(3,0)          NOT NULL;
,LENDER_PRODUCT_ID                                            NUMBER(38,0)         NOT NULL;
,LCCG_ID                                                      NUMBER(38,0)         NOT NULL;
,BRANCH_LENDER_ORG_ID                                         NUMBER(38,0)         ;
,DIVISION_LENDER_ORG_ID                                       NUMBER(38,0)         ;
,CREDIT_SCORE_TX                                              TEXT(40)             ;
,LIEN_POSITION_NO                                             NUMBER(11,0)         ;
,FLOOD_ZONE_AV_IN                                             TEXT(1)              ;
,OPTIONAL_IN                                                  TEXT(1)              NOT NULL;
,BATCH_ID                                                     NUMBER(38,0)         NOT NULL;
,HASH_ID                                                      TEXT(32)             NOT NULL;
,CREATE_DT                                                    DATETIME             NOT NULL;
,UPDATE_DT                                                    DATETIME             NOT NULL;
,SRC_UPDATE_USER_TX                                           TEXT(30)             ;
);

--DESC EDW_TEST.STG.STG_UT_OPEN_CERTIFICATE;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_OPEN_CERTIFICATE
(
 AGENCY_CODE_TX                                               TEXT(20)             ;
,RUN_DTX                                                      DATE                 ;
,LENDER_CODE_TX                                               TEXT(10)             NOT NULL;
,LENDER_NAME_TX                                               TEXT(100)            NOT NULL;
,LOAN_ID                                                      NUMBER(38,0)         NOT NULL;
,LOAN_NUMBER_TX                                               TEXT(18)             NOT NULL;
,LOAN_STATUS_CD                                               TEXT(50)             ;
,BRANCH_CODE_TX                                               TEXT(20)             ;
,COLLATERAL_STATUS_CD                                         TEXT(2)              ;
,COLLATERAL_NUMBER_NO                                         NUMBER(38,0)         ;
,FPC_ID                                                       NUMBER(38,0)         NOT NULL;
,CPI_QUOTE_ID                                                 NUMBER(38,0)         NOT NULL;
,FPC_NUMBER_TX                                                TEXT(18)             NOT NULL;
,EFFECTIVE_DT                                                 DATETIME             ;
,EXPIRATION_DT                                                DATETIME             ;
,CANCELLATION_DT                                              DATETIME             ;
,ISSUE_DT                                                     DATETIME             ;
,ISSUE_REASON_CD                                              TEXT(10)             ;
,BILLING_STATUS_CD                                            TEXT(4)              ;
,QUICK_ISSUE_IN                                               TEXT(1)              ;
,HOLD_IN                                                      TEXT(1)              ;
,PROPERTY_ID                                                  NUMBER(38,0)         ;
,RC_ID                                                        NUMBER(38,0)         ;
,RC_COVERAGE_TYPE_CD                                          TEXT(30)             ;
,RC_STATUS_CD                                                 TEXT(2)              ;
,DELAY_DAYS_NO                                                NUMBER(38,0)         ;
,LENDER_PRODUCT_ID                                            NUMBER(38,0)         ;
,LENDER_PRODUCT_BASIC_TYPE_CD                                 TEXT(18)             ;
,BILL_DT                                                      DATETIME             ;
,ACTIVITY_AMOUNT_NO                                           NUMBER(30,2)         ;
,AR_AMOUNT_NO                                                 NUMBER(30,2)         ;
,CASH_AMOUNT_NO                                               NUMBER(30,2)         ;
,TO_BE_BILLED_AMOUNT_NO                                       NUMBER(32,2)         ;
,SHOULD_BE_BILLED_AMOUNT_NO                                   NUMBER(32,2)         ;
,AGE_0_42_NO                                                  NUMBER(32,2)         ;
,AGE_43_60_NO                                                 NUMBER(32,2)         ;
,AGE_61_90_NO                                                 NUMBER(32,2)         ;
,AGE_91_120_NO                                                NUMBER(32,2)         ;
,AGE_120_NO                                                   NUMBER(32,2)         ;
,REFUND_AMOUNT_NO                                             NUMBER(30,2)         ;
,BILLED_AMOUNT_NO                                             NUMBER(30,2)         ;
,WEEKLY_ID                                                    NUMBER(38,0)         ;
,CREATE_DT                                                    DATETIME             ;
,UPDATE_DT                                                    DATETIME             ;
,UPDATE_USER_TX                                               TEXT(15)             ;
,BATCH_ID                                                     NUMBER(38,0)         ;
,HASH_ID                                                      TEXT(32)             ;
,SRC_UPDATE_USER_TX                                           TEXT(15)             ;
);


--DESC EDW_TEST.STG.LND_UT_VUT_TBLIMAGEQUEUE;

create or replace TABLE EDW_PROD.STG.LND_UT_VUT_TBLIMAGEQUEUE (
	ID NUMBER(38,0) NOT NULL,
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
	UPDATE_USER_TX VARCHAR(15)
);


--DESC EDW_TEST.STG.STG_UT_VUT_TBLIMAGEQUEUE;

create or replace TABLE EDW_PROD.STG.STG_UT_VUT_TBLIMAGEQUEUE (
	ID NUMBER(38,0) NOT NULL,
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
	UPDATE_USER_TX VARCHAR(15)
);



--DESC EDW_TEST.STG.D_UT_VUT_IMAGE_QUEUE_TEMP;

create or replace TABLE EDW_PROD.STG.D_UT_VUT_IMAGE_QUEUE_TEMP (
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





--DESC EDW_TEST.STG.LND_UT_AGENCY;

ALTER TABLE EDW_PROD.STG.LND_UT_AGENCY                                      ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_CARRIER;

ALTER TABLE EDW_PROD.STG.LND_UT_CARRIER                                     ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_COLLATERAL;

ALTER TABLE EDW_PROD.STG.LND_UT_COLLATERAL                                  ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_COLLATERAL_CODE;

ALTER TABLE EDW_PROD.STG.LND_UT_COLLATERAL_CODE                             ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_CPI_ACTIVITY;

ALTER TABLE EDW_PROD.STG.LND_UT_CPI_ACTIVITY                                ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(30);


--DESC EDW_TEST.STG.LND_UT_CPI_QUOTE;

ALTER TABLE EDW_PROD.STG.LND_UT_CPI_QUOTE                                   ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.FINANCIAL_TXN;

ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN CURRENT_FLG                                        TEXT(1);
ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_PURGE_DT                                    DATETIME;
ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_TXN_TYPE_CD                                 TEXT(10);
ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_UPDATE_DT                                   DATETIME;
ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_UPDATE_USER_TX                              TEXT(15);
ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN FINANCIAL_TXN_ID                                   NUMBER(38,0);
ALTER TABLE EDW_PROD.STG.LND_UT_FINANCIAL_TXN                               ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE;

ALTER TABLE EDW_PROD.STG.LND_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE  ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_FORCE_PLACED_CERTIFICATE;

ALTER TABLE EDW_PROD.STG.LND_UT_FORCE_PLACED_CERTIFICATE                    ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_INTERACTION_HISTORY;

ALTER TABLE EDW_PROD.STG.LND_UT_INTERACTION_HISTORY                         ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_LENDER;

ALTER TABLE EDW_PROD.STG.LND_UT_LENDER                                      ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_LENDER_PRODUCT;

ALTER TABLE EDW_PROD.STG.LND_UT_LENDER_PRODUCT                              ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_OWNER_ADDRESS;

ALTER TABLE EDW_PROD.STG.LND_UT_OWNER_ADDRESS                               ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(30);


--DESC EDW_TEST.STG.LND_UT_OWNER_LOAN_RELATE;

ALTER TABLE EDW_PROD.STG.LND_UT_OWNER_LOAN_RELATE                           ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_PROPERTY;

ALTER TABLE EDW_PROD.STG.LND_UT_PROPERTY                                    ADD COLUMN ALT_MATCH_TXT                                      TEXT(32000);
ALTER TABLE EDW_PROD.STG.LND_UT_PROPERTY                                    ADD COLUMN FIELD_PROTECTION_TXT                               TEXT(32000);
ALTER TABLE EDW_PROD.STG.LND_UT_PROPERTY                                    ADD COLUMN SPECIAL_HANDLING_TXT                               TEXT(32000);
ALTER TABLE EDW_PROD.STG.LND_UT_PROPERTY                                    ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_QUALITY_CONTROL_ITEM;

ALTER TABLE EDW_PROD.STG.LND_UT_QUALITY_CONTROL_ITEM                        ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_REF_CODE_ATTRIBUTE;

ALTER TABLE EDW_PROD.STG.LND_UT_REF_CODE_ATTRIBUTE                          ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_RELATED_DATA;

ALTER TABLE EDW_PROD.STG.LND_UT_RELATED_DATA                                ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_REQUIRED_COVERAGE;

ALTER TABLE EDW_PROD.STG.LND_UT_REQUIRED_COVERAGE                           ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_TRADING_PARTNER;

ALTER TABLE EDW_PROD.STG.LND_UT_TRADING_PARTNER                             ADD COLUMN SRC_UPDATE_USER_TX                                 NUMBER(3,0);


--DESC EDW_TEST.STG.LND_UT_USERS;

ALTER TABLE EDW_PROD.STG.LND_UT_USERS                                       ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.LND_UT_WORK_ITEM;

ALTER TABLE EDW_PROD.STG.LND_UT_WORK_ITEM                                   ADD COLUMN XML_MEANING_TX                                     TEXT(100);


--DESC EDW_TEST.STG.LND_UT_WORK_QUEUE;

ALTER TABLE EDW_PROD.STG.LND_UT_WORK_QUEUE                                  ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(30);


--DESC EDW_TEST.STG.LND_UT_WORKFLOW_DEFINITION;

ALTER TABLE EDW_PROD.STG.LND_UT_WORKFLOW_DEFINITION                         ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_AGENCY;

ALTER TABLE EDW_PROD.STG.STG_UT_AGENCY                                      ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_CARRIER;

ALTER TABLE EDW_PROD.STG.STG_UT_CARRIER                                     ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_COLLATERAL;

ALTER TABLE EDW_PROD.STG.STG_UT_COLLATERAL                                  ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_COLLATERAL_CODE;

ALTER TABLE EDW_PROD.STG.STG_UT_COLLATERAL_CODE                             ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_CPI_ACTIVITY;

ALTER TABLE EDW_PROD.STG.STG_UT_CPI_ACTIVITY                                ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(30);


--DESC EDW_TEST.STG.STG_UT_CPI_QUOTE;

ALTER TABLE EDW_PROD.STG.STG_UT_CPI_QUOTE                                   ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_FINANCIAL_TXN;

ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN CURRENT_FLG                                        TEXT(1);
ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_PURGE_DT                                    DATETIME;
ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_TXN_TYPE_CD                                 TEXT(10);
ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_UPDATE_DT                                   DATETIME;
ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN DETAIL_UPDATE_USER_TX                              TEXT(15);
ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN FINANCIAL_TXN_ID                                   NUMBER(38,0);
ALTER TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN                               ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);

--DESC EDW_TEST.STG.STG_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE;

ALTER TABLE EDW_PROD.STG.STG_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE  ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);

--DESC EDW_TEST.STG.STG_UT_FORCE_PLACED_CERTIFICATE;

ALTER TABLE EDW_PROD.STG.STG_UT_FORCE_PLACED_CERTIFICATE                    ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_INTERACTION_HISTORY;

ALTER TABLE EDW_PROD.STG.STG_UT_INTERACTION_HISTORY                         ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_LENDER;

ALTER TABLE EDW_PROD.STG.STG_UT_LENDER                                      ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_LENDER_PRODUCT;

ALTER TABLE EDW_PROD.STG.STG_UT_LENDER_PRODUCT                              ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_OWNER_ADDRESS;

ALTER TABLE EDW_PROD.STG.STG_UT_OWNER_ADDRESS                               ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(30);


--DESC EDW_TEST.STG.STG_UT_OWNER_LOAN_RELATE;

ALTER TABLE EDW_PROD.STG.STG_UT_OWNER_LOAN_RELATE                           ADD COLUMN SRC_UPDATE_DT                                      DATETIME;
ALTER TABLE EDW_PROD.STG.STG_UT_OWNER_LOAN_RELATE                           ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_PROPERTY;

ALTER TABLE EDW_PROD.STG.STG_UT_PROPERTY                                    ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_QUALITY_CONTROL_ITEM;

ALTER TABLE EDW_PROD.STG.STG_UT_QUALITY_CONTROL_ITEM                        ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_REF_CODE_ATTRIBUTE;

ALTER TABLE EDW_PROD.STG.STG_UT_REF_CODE_ATTRIBUTE                          ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_REQUIRED_COVERAGE;

ALTER TABLE EDW_PROD.STG.STG_UT_REQUIRED_COVERAGE                           ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_TRADING_PARTNER;

ALTER TABLE EDW_PROD.STG.STG_UT_TRADING_PARTNER                             ADD COLUMN SRC_UPDATE_USER_TX                                 DATETIME;


--DESC EDW_TEST.STG.STG_UT_USERS;

ALTER TABLE EDW_PROD.STG.STG_UT_USERS                                       ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_WORK_ITEM;

ALTER TABLE EDW_PROD.STG.STG_UT_WORK_ITEM                                   ADD COLUMN XML_MEANING_TX                                     TEXT(100);


--DESC EDW_TEST.STG.STG_UT_WORK_QUEUE;

ALTER TABLE EDW_PROD.STG.STG_UT_WORK_QUEUE                                  ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(30);


--DESC EDW_TEST.STG.STG_UT_WORKFLOW_DEFINITION;

ALTER TABLE EDW_PROD.STG.STG_UT_WORKFLOW_DEFINITION                         ADD COLUMN SRC_UPDATE_USER_TX                                 TEXT(15);


--DESC EDW_TEST.STG.STG_UT_AGENCY_H;

CREATE OR REPLACE TABLE EDW_PROD.STG. STG_UT_AGENCY_H (
	ID NUMBER(38, 0) NOT NULL
	,SHORT_NAME_TX VARCHAR(40) NOT NULL
	,NAME_TX VARCHAR(100) NOT NULL
	,WEB_ADDRESS_TX VARCHAR(8000)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,MAIN_OFFICE_ID NUMBER(38, 0)
	,TAX_ID_TX VARCHAR(40)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_COLLATERAL_CODE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_COLLATERAL_CODE_H (
	ID NUMBER(38, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,CODE_TX VARCHAR(60) NOT NULL
	,--DESCRIPTION_TX VARCHAR(100)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,CONTRACT_TYPE_CD VARCHAR(60) NOT NULL
	,APAPER_IN VARCHAR(1) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,VUT_KEY NUMBER(38, 0)
	,PRIMARY_CLASS_CD VARCHAR(12)
	,SECONDARY_CLASS_CD VARCHAR(12)
	,VEHICLE_LOOKUP_IN VARCHAR(1)
	,ADDRESS_LOOKUP_IN VARCHAR(1)
	,VACANT_IN VARCHAR(1) NOT NULL
	,REO_IN VARCHAR(1) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_CPI_QUOTE_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_CPI_QUOTE_H (
	ID NUMBER(38, 0) NOT NULL
	,BASIS_TYPE_CD VARCHAR(60) NOT NULL
	,BASIS_NO NUMBER(18, 2) NOT NULL
	,TERM_TYPE_CD VARCHAR(20) NOT NULL
	,TERM_NO NUMBER(11, 0) NOT NULL
	,CLOSE_DT TIMESTAMP_NTZ(9)
	,CLOSE_REASON_CD VARCHAR(8) NOT NULL
	,COVERAGE_AMOUNT_NO NUMBER(18, 2)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,PAYMENT_INCREASE_METHOD_CD VARCHAR(8)
	,PAYMENT_INCREASE_METHOD_VALUE_NO NUMBER(18, 2)
	,FIRST_PAYMENT_DIFFERENCE_NO NUMBER(18, 2)
	,NEW_PAYMENT_AMOUNT_NO NUMBER(18, 2)
	,MASTER_POLICY_ASSIGNMENT_ID NUMBER(38, 0)
	,TOTAL_COVERAGE_AMOUNT_NO NUMBER(18, 2)
	,FIRST_MONTH_BILL_NO NUMBER(18, 2)
	,NEXT_MONTH_BILL_NO NUMBER(18, 2)
	,IS_LAPSE_IN VARCHAR(2) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_LENDER_COLLATERAL_GROUP_COVERAGE_TYPE_H (
	ID NUMBER(38, 0) NOT NULL
	,TYPE_CD VARCHAR(60) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,LENDER_PRODUCT_ID NUMBER(38, 0) NOT NULL
	,LCCG_ID NUMBER(38, 0) NOT NULL
	,BRANCH_LENDER_ORG_ID NUMBER(38, 0)
	,DIVISION_LENDER_ORG_ID NUMBER(38, 0)
	,CREDIT_SCORE_TX VARCHAR(40)
	,LIEN_POSITION_NO NUMBER(11, 0)
	,FLOOD_ZONE_AV_IN VARCHAR(1)
	,OPTIONAL_IN VARCHAR(1) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_USER_TX VARCHAR(30)
	);

--DESC EDW_TEST.STG.STG_UT_OWNER_ADDRESS_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_OWNER_ADDRESS_H (
	ID NUMBER(38, 0) NOT NULL
	,LINE_1_TX VARCHAR(200)
	,LINE_2_TX VARCHAR(200)
	,CITY_TX VARCHAR(80)
	,STATE_PROV_TX VARCHAR(60)
	,COUNTRY_TX VARCHAR(60)
	,POSTAL_CODE_TX VARCHAR(60)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,ATTENTION_TX VARCHAR(60)
	,ADDRESS_TYPE_CD VARCHAR(12)
	,PO_BOX_TX VARCHAR(60)
	,RURAL_ROUTE_TX VARCHAR(60)
	,UNIT_TX VARCHAR(60)
	,PARSED_STATUS_CD VARCHAR(60)
	,CERTIFIED_IN VARCHAR(1)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_OWNER_POLICY_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_OWNER_POLICY_H (
	ID NUMBER(38, 0) NOT NULL
	,POLICY_NUMBER_TX VARCHAR(60)
	,STATUS_CD VARCHAR(2) NOT NULL
	,SUB_STATUS_CD VARCHAR(2) NOT NULL
	,SOURCE_CD VARCHAR(8) NOT NULL
	,EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,EXPIRATION_DT TIMESTAMP_NTZ(9)
	,CANCELLATION_DT TIMESTAMP_NTZ(9)
	,CANCEL_REASON_CD VARCHAR(8) NOT NULL
	,BIC_ID NUMBER(38, 0)
	,BIC_NAME_TX VARCHAR(200)
	,BIC_TAX_ID_TX VARCHAR(60)
	,BIA_ID NUMBER(38, 0)
	,ADDITIONAL_NAMED_INSURED_IN VARCHAR(1) NOT NULL
	,EXCESS_IN VARCHAR(1) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,FLOOD_ZONE_TX VARCHAR(20)
	,FLOOD_ZONE_GRANDFATHER_IN VARCHAR(1)
	,BASE_PROPERTY_TYPE_CD VARCHAR(8) NOT NULL
	,LIENHOLDER_STATUS_CD VARCHAR(20)
	,UNIT_OWNERS_IN VARCHAR(1)
	,EXCLUDED_DRIVER_IN VARCHAR(1)
	,DOC_PROBLEM_CD VARCHAR(24)
	,MOST_RECENT_MAIL_DT TIMESTAMP_NTZ(9)
	,MOST_RECENT_TXN_TYPE_CD VARCHAR(8)
	,OTHER_IMPAIRMENT_CD VARCHAR(8)
	,MOST_RECENT_EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,LAST_UPDATED_FROM_LENDER_FILE_IN VARCHAR(1) NOT NULL
	,LAST_UPDATE_FROM_LENDER_FILE_DT TIMESTAMP_NTZ(9)
	,FLOOD_INSURANCE_TYPE_CD VARCHAR(20) NOT NULL
	,GRACE_PERIOD_END_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	,SPECIAL_HANDLING_XML VARIANT
	,SRC_UPDATE_USER_TX VARCHAR(30)
	);
	
--DESC EDW_TEST.STG.STG_UT_REF_CODE_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_REF_CODE_H (
	CODE_CD VARCHAR(100) NOT NULL
	,DOMAIN_CD VARCHAR(60) NOT NULL
	,MEANING_TX VARCHAR(2000) NOT NULL
	,--DESCRIPTION_TX VARCHAR(2000) NOT NULL
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,ID NUMBER(38, 0) NOT NULL
	,ORDER_NO NUMBER(11, 0) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	,SRC_UPDATE_USER_TX VARCHAR(20)
	);

--DESC EDW_TEST.STG.STG_UT_USERS_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_USERS_H (
	ID NUMBER(38, 0) NOT NULL
	,USER_NAME_TX VARCHAR(100) NOT NULL
	,PASSWORD_TX VARCHAR(100) NOT NULL
	,FAMILY_NAME_TX VARCHAR(100) NOT NULL
	,GIVEN_NAME_TX VARCHAR(60)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,EMAIL_TX VARCHAR(200)
	,EXTERN_MAINT_IN VARCHAR(1) NOT NULL
	,LOGIN_COUNT_NO NUMBER(7, 0)
	,LAST_LOGIN_DT TIMESTAMP_NTZ(9)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,DEFAULT_AGENCY_ID NUMBER(38, 0) NOT NULL
	,SYSTEM_IN VARCHAR(1)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_WORK_ITEM_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_WORK_ITEM_H (
	ID NUMBER(38, 0) NOT NULL
	,BORROWERNAME VARCHAR(100)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_USER_TX VARCHAR(15)
	,DEFAULT_SORTBY_TX VARCHAR(32)
	,TEMPCOLLATERAL_LINE1_TX VARCHAR(100)
	,TEMPCOLLATERAL_LINE2_TX VARCHAR(100)
	,TEMPCOLLATERAL_CITY_TX VARCHAR(40)
	,TEMPCOLLATERAL_STATE_TX VARCHAR(30)
	,TEMPCOLLATERAL_ZIP_TX VARCHAR(30)
	,TEMPCOLLATERAL_YEAR_TX VARCHAR(4)
	,TEMPCOLLATERAL_MAKE_TX VARCHAR(30)
	,TEMPCOLLATERAL_MODEL_TX VARCHAR(30)
	,TEMPCOLLATERAL_VIN_TX VARCHAR(18)
	,TEMPCOLLATERAL_--DESC VARCHAR(100)
	,TEMPPROPERTY_TYPE VARCHAR(20)
	,TEMPPROPERTY_TYPE_CD VARCHAR(20)
	,TEMPLOAN_NO VARCHAR(20)
	,TEMPREQUIREDCOVERAGE_TYPE_TX VARCHAR(30)
	,TEMPREQUIREDCOVERAGE_STATUSMEANING_TX VARCHAR(30)
	,TEMPPROPERTY_ID NUMBER(38, 0)
	,TEMPRC_ID NUMBER(38, 0)
	,TEMPOWNER_NAME VARCHAR(100)
	,TEMPLENDER_NAME VARCHAR(100)
	,TEMPLENDER_CODE VARCHAR(20)
	,TEMPLENDER_ID NUMBER(38, 0)
	,TEMPLENDER_LASTCYCLEDATE TIMESTAMP_NTZ(9)
	,TEMPLENDER_NEXTCYCLEDATE TIMESTAMP_NTZ(9)
	,COLLATERAL_EFFECTIVEDATE TIMESTAMP_NTZ(7)
	,COLLATERAL_ENDDATE TIMESTAMP_NTZ(7)
	,COLLATERAL_CANCELREASON VARCHAR(50)
	,COLLATERAL_POLICYTYPE VARCHAR(50)
	,COLLATERAL_RELATECLASS VARCHAR(50)
	,COLLATERAL_RELATEID VARCHAR(50)
	,BATCH_ID NUMBER(38, 0)
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15) NOT NULL
	,TEMP_EVALUATION_ERROR VARCHAR(4000)
	,TEMP_INFORMATION VARCHAR(4000)
	,RELATE_ID NUMBER(38, 0)
	,RELATE_TYPE_CD VARCHAR(50)
	,STATUS_CD VARCHAR(20)
	,CURRENT_QUEUE_ID NUMBER(38, 0)
	,CURRENT_OWNER_ID NUMBER(38, 0)
	,WORKFLOW_DEFINITION_ID NUMBER(38, 0)
	,LENDER_ID NUMBER(38, 0)
	,CPI_CANCEL_STATUS VARCHAR(40)
	,RELATE_ID1 NUMBER(38, 0)
	,REGENERATED VARCHAR(30)
	,REGENERATED_IN VARCHAR(5)
	,DETAIL VARCHAR(50)
	,USER_ROLE_CD VARCHAR(30)
	,DELAY_UNTIL_DT TIMESTAMP_NTZ(9)
	,BILLINGGROUP_WORKITEMID VARCHAR(100)
	,BILLINGGROUP_RELATECLASSID VARCHAR(100)
	,BILLINGGROUP_LOANID VARCHAR(100)
	,BILLINGGROUP_PROPERTYID VARCHAR(100)
	,BILLINGGROUP_REQUIREDCOVERAGEID VARCHAR(100)
	,BILLINGGROUP_CERTIFICATE VARCHAR(100)
	,BILLINGGROUP_LOANNUMBER VARCHAR(100)
	,BILLINGGROUP_COLLATERALNUMBER VARCHAR(100)
	,BILLINGGROUP_OWNERNAME VARCHAR(100)
	,BILLINGGROUP_--DESCRIPTION VARCHAR(100)
	,BILLINGGROUP_VIN VARCHAR(100)
	,BILLINGGROUP_BASIS VARCHAR(100)
	,BILLINGGROUP_EFFECTIVEDATE TIMESTAMP_NTZ(7)
	,BILLINGGROUP_CPIPOLICYEXPCXLDATE TIMESTAMP_NTZ(7)
	,BILLINGGROUP_TERM VARCHAR(100)
	,BILLINGGROUP_ISSUEREASON VARCHAR(100)
	,BILLINGGROUP_EARNEDISSUEAMOUNT VARCHAR(100)
	,BILLINGGROUP_PASTDUE VARCHAR(100)
	,BILLINGGROUP_PASTDUESTATUS VARCHAR(100)
	,BILLINGGROUP_BRANCH VARCHAR(100)
	,BILLINGGROUP_DIVISION VARCHAR(100)
	,BILLINGGROUP_PROPERTYTYPE VARCHAR(100)
	,BILLINGGROUP_LINE1 VARCHAR(100)
	,BILLINGGROUP_LINE2 VARCHAR(100)
	,BILLINGGROUP_CITY VARCHAR(100)
	,BILLINGGROUP_STATE VARCHAR(100)
	,BILLINGGROUP_POSTALCODE VARCHAR(100)
	,BILLINGGROUP_COUNTRY VARCHAR(100)
	,BILLINGGROUP_LENDERRESPONSE VARCHAR(100)
	,BILLINGGROUP_ACTION VARCHAR(100)
	,BILLINGGROUP_P--DESCRPTION VARCHAR(100)
	,BILLINGGROUP_LENDERSTARTDATE TIMESTAMP_NTZ(7)
	,BILLINGGROUP_LENDERENDDATE TIMESTAMP_NTZ(7)
	,BILLINGGROUP_LENDERCOMMENT VARCHAR(100)
	,DETAIL_CHECKED VARCHAR(10)
	,DETAIL_RELATETYPE VARCHAR(50)
	,DETAIL_ACTIONNEEDED VARCHAR(500)
	,DETAIL_FIELDDISPLAYNAME VARCHAR(100)
	,DETAIL_RELATEID NUMBER(38, 0)
	,DETAIL_CURRENTVALUE NUMBER(18, 2)
	,DETAIL_UTVALUE NUMBER(18, 2)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,HASH_ID VARCHAR(32)
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);


--DESC EDW_TEST.STG.STG_UT_INTERACTION_HISTORY_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_INTERACTION_HISTORY_H (
	ID NUMBER(38, 0) NOT NULL
	,BATCH_ID NUMBER(38, 0)
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15) NOT NULL
	,PROPERTY_ID NUMBER(38, 0)
	,REQUIRED_COVERAGE_ID NUMBER(38, 0)
	,TYPE_CD VARCHAR(15)
	,REASON VARCHAR(2048)
	,INSURANCE_COMPANY VARCHAR(2048)
	,KEYED_POLICY_EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,CALL_TYPE VARCHAR(2048)
	,RESOLUTION_TYPE VARCHAR(2048)
	,IH_ACTION VARCHAR(2048)
	,RESOLUTION_CODE VARCHAR(2048)
	,REVIEW_STATUS VARCHAR(2048)
	,RC VARCHAR(2048)
	,HASH_ID VARCHAR(32)
	,DATA_SOURCE VARCHAR(2048)
	,CALL_WITH VARCHAR(2048)
	,MAIL_STATUS VARCHAR(2048)
	,STATUS VARCHAR(2048)
	,SENT_TO_--DESC VARCHAR(2048)
	,AGENT_LETTER_OPTION_VALUE VARCHAR(2048)
	,ADDITIONAL_COMMENT VARCHAR(2048)
	,CALL_ATTEMPTS VARCHAR(2048)
	,SH_TYPE VARCHAR(2048)
	,AGENT_NAME VARCHAR(2048)
	,AGENT_EMAIL VARCHAR(2048)
	,AGENT_FAX VARCHAR(2048)
	,STATUS_DATE VARCHAR(2048)
	,SEQUENCE VARCHAR(2048)
	,ISSUE_DT TIMESTAMP_NTZ(9)
	,DOCUMENT_ID NUMBER(38, 0)
	,CREATE_USER_TX VARCHAR(50)
	,RELATE_ID NUMBER(38, 0)
	,RELATE_CLASS_TX VARCHAR(100)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9)
	,PREMIUMDUEAMOUNT NUMBER(19, 2)
	,TRADINGPARTNER_ID NUMBER(38, 0)
	,DATE_CERT_MAILED_DT VARCHAR(2048)
	,SUBTYPE VARCHAR(2048)
	,EVENTSTATUS VARCHAR(2048)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SPECIAL_HANDLING_TXT VARCHAR(200000)
	,SPECIAL_HANDLING_XML VARIANT
	,SOURCE_CODE VARCHAR(40)
	,REASON_CODE VARCHAR(40)
	,WEB_VERIFICATION VARCHAR(10)
	,LOAN_ID NUMBER(38, 0)
	,EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,EFFECTIVE_ORDER_NO NUMBER(18, 2)
	,NOTE_TX VARCHAR(8000)
	,ALERT_IN VARCHAR(1)
	,PENDING_IN VARCHAR(1)
	,IN_HOUSE_ONLY_IN VARCHAR(1)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0)
	,DELETE_ID NUMBER(38, 0)
	,ARCHIVED_IN VARCHAR(1)
	,TRANSACTION_ID NUMBER(38, 0)
	,CURRENT_FLG VARCHAR(1)
	);

--DESC EDW_TEST.STG.STG_UT_OPEN_CERTIFICATE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_OPEN_CERTIFICATE_H (
	AGENCY_CODE_TX VARCHAR(20)
	,RUN_DTX DATE
	,LENDER_CODE_TX VARCHAR(10) NOT NULL
	,LENDER_NAME_TX VARCHAR(100) NOT NULL
	,LOAN_ID NUMBER(38, 0) NOT NULL
	,LOAN_NUMBER_TX VARCHAR(18) NOT NULL
	,LOAN_STATUS_CD VARCHAR(50)
	,BRANCH_CODE_TX VARCHAR(20)
	,COLLATERAL_STATUS_CD VARCHAR(2)
	,COLLATERAL_NUMBER_NO NUMBER(38, 0)
	,FPC_ID NUMBER(38, 0) NOT NULL
	,CPI_QUOTE_ID NUMBER(38, 0) NOT NULL
	,FPC_NUMBER_TX VARCHAR(18) NOT NULL
	,EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,EXPIRATION_DT TIMESTAMP_NTZ(9)
	,CANCELLATION_DT TIMESTAMP_NTZ(9)
	,ISSUE_DT TIMESTAMP_NTZ(9)
	,ISSUE_REASON_CD VARCHAR(10)
	,BILLING_STATUS_CD VARCHAR(4)
	,QUICK_ISSUE_IN VARCHAR(1)
	,HOLD_IN VARCHAR(1)
	,PROPERTY_ID NUMBER(38, 0)
	,RC_ID NUMBER(38, 0)
	,RC_COVERAGE_TYPE_CD VARCHAR(30)
	,RC_STATUS_CD VARCHAR(2)
	,DELAY_DAYS_NO NUMBER(38, 0)
	,LENDER_PRODUCT_ID NUMBER(38, 0)
	,LENDER_PRODUCT_BASIC_TYPE_CD VARCHAR(18)
	,BILL_DT TIMESTAMP_NTZ(9)
	,ACTIVITY_AMOUNT_NO NUMBER(30, 2)
	,AR_AMOUNT_NO NUMBER(30, 2)
	,CASH_AMOUNT_NO NUMBER(30, 2)
	,TO_BE_BILLED_AMOUNT_NO NUMBER(32, 2)
	,SHOULD_BE_BILLED_AMOUNT_NO NUMBER(32, 2)
	,AGE_0_42_NO NUMBER(32, 2)
	,AGE_43_60_NO NUMBER(32, 2)
	,AGE_61_90_NO NUMBER(32, 2)
	,AGE_91_120_NO NUMBER(32, 2)
	,AGE_120_NO NUMBER(32, 2)
	,REFUND_AMOUNT_NO NUMBER(30, 2)
	,BILLED_AMOUNT_NO NUMBER(30, 2)
	,WEEKLY_ID NUMBER(38, 0)
	,CREATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(15)
	,BATCH_ID NUMBER(38, 0)
	,HASH_ID VARCHAR(32)
	,SRC_UPDATE_USER_TX VARCHAR(15)
	);

--DESC EDW_TEST.STG.STG_UT_CARRIER_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_CARRIER_H (
	ID NUMBER(38, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,CODE_TX VARCHAR(40) NOT NULL
	,NAME_TX VARCHAR(200) NOT NULL
	,PHONE_TX VARCHAR(40)
	,ALTERNATE_PHONE_TX VARCHAR(40)
	,FAX_TX VARCHAR(40)
	,WEB_ADDRESS_TX VARCHAR(640)
	,PERSON_ID NUMBER(38, 0)
	,PHYSICAL_ADDRESS_ID NUMBER(38, 0)
	,MAILING_ADDRESS_ID NUMBER(38, 0)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,IN_USE_IN VARCHAR(1) NOT NULL
	,ALLOW_REINSTATEMENT_IN VARCHAR(1)
	,REPORT_LENDERPAY_ENDORSMENT_IN VARCHAR(1)
	,MANUAL_ISSUE_ONLY_IN VARCHAR(1)
	,CARRIER_PROGRAM_TX VARCHAR(140)
	,DATA_PATH_TX VARCHAR(512)
	,VENDOR_SETTING_NO NUMBER(11, 0)
	,VUT_KEY NUMBER(38, 0)
	,PHONE_EXT_TX VARCHAR(20)
	,ALTERNATE_PHONE_EXT_TX VARCHAR(20)
	,FAX_EXT_TX VARCHAR(20)
	,DISPLAY_NAME_TX VARCHAR(200)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_RELATED_DATA_DEF_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_RELATED_DATA_DEF_H (
	ID NUMBER(38, 0) NOT NULL
	,NAME_TX VARCHAR(50) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,RELATE_CLASS_NM VARCHAR(30)
	,CURRENT_FLG VARCHAR(1)
	);
	
--DESC EDW_TEST.STG.STG_UT_PROPERTY_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_PROPERTY_H (
	ID NUMBER(38, 0) NOT NULL
	,LENDER_ID NUMBER(38, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,ADDRESS_ID NUMBER(38, 0)
	,--DESCRIPTION_TX VARCHAR(100)
	,ACV_NO NUMBER(19, 2)
	,ACV_DT TIMESTAMP_NTZ(9)
	,ACV_VALUATION_REQUIRED_IN VARCHAR(1) NOT NULL
	,ASSET_NUMBER_TX VARCHAR(3)
	,RECORD_TYPE_CD VARCHAR(1)
	,SOURCE_CD VARCHAR(4) NOT NULL
	,YEAR_TX VARCHAR(4)
	,MAKE_TX VARCHAR(30)
	,MODEL_TX VARCHAR(30)
	,BODY_TX VARCHAR(40)
	,VIN_TX VARCHAR(18)
	,REVERSE_VIN_TX VARCHAR(18)
	,TITLE_CD VARCHAR(50)
	,FIELD_PROTECTION_XML VARCHAR(356)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(15)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(38, 0) NOT NULL
	,SPECIAL_HANDLING_XML VARCHAR(256)
	,REPLACEMENT_COST_VALUE_NO NUMBER(19, 2)
	,LAND_VALUE_NO NUMBER(19, 2)
	,VACANT_IN VARCHAR(1) NOT NULL
	,ACRES_AMOUNT_NO NUMBER(8, 2)
	,TIED_DOWN_IN VARCHAR(1) NOT NULL
	,IN_PARK_IN VARCHAR(1) NOT NULL
	,ACV_INCLUDES_LAND_IN VARCHAR(1) NOT NULL
	,IN_CONSTRUCTION_IN VARCHAR(1) NOT NULL
	,ZONE_ASSUMED_IN VARCHAR(1)
	,COASTAL_BARRIER_IN VARCHAR(1)
	,PARTICIPATING_COMMUNITY_IN VARCHAR(1)
	,FLOOD_ZONE_TX VARCHAR(10)
	,WIND_ZONE_TX VARCHAR(10)
	,PROPERTY_ASSOC_ID NUMBER(38, 0)
	,ALT_MATCH_XML VARCHAR(256)
	,UCC_CD VARCHAR(4)
	,CALCULATED_COLL_BALANCE_NO NUMBER(19, 2)
	,FLOOD_ACTIVE_IN VARCHAR(1) NOT NULL
	,VEHICLETYPE_TX VARCHAR(250)
	,VEHICLECLASS_TX VARCHAR(250)
	,HASH_ID VARCHAR(32) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_REF_CODE_ATTRIBUTE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_REF_CODE_ATTRIBUTE_H (
	ATTRIBUTE_CD VARCHAR(60) NOT NULL
	,REF_CD VARCHAR(100) NOT NULL
	,DOMAIN_CD VARCHAR(60) NOT NULL
	,VALUE_TX VARCHAR(200) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,ID NUMBER(38, 0) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);


--DESC EDW_TEST.STG.STG_UT_RELATED_DATA_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_RELATED_DATA_H (
	ID NUMBER(38, 0) NOT NULL
	,RELATE_ID NUMBER(38, 0)
	,DEF_ID NUMBER(38, 0)
	,VALUE_TX VARCHAR(100)
	,CREATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0)
	,HASH_ID VARCHAR(50)
	,UPDATE_USER_TX VARCHAR(50)
	,START_DT TIMESTAMP_NTZ(9)
	,END_DT TIMESTAMP_NTZ(9)
	,COMMENT_TX VARCHAR(8000)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(4, 0)
	,CURRENT_FLG VARCHAR(1)
	);

--DESC EDW_TEST.STG.STG_UT_REQUIRED_COVERAGE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_REQUIRED_COVERAGE_H (
	ID NUMBER(38, 0) NOT NULL
	,TYPE_CD VARCHAR(30)
	,REQUIRED_AMOUNT_NO NUMBER(18, 2)
	,STATUS_CD VARCHAR(2)
	,SUB_STATUS_CD VARCHAR(2)
	,ESCROW_IN VARCHAR(1)
	,SUMMARY_STATUS_CD VARCHAR(4)
	,SUMMARY_SUB_STATUS_CD VARCHAR(4)
	,MOST_RECENT_ATTACHED_DOC_TYPE_CD VARCHAR(20)
	,NOTICE_DT TIMESTAMP_NTZ(9)
	,NOTICE_TYPE_CD VARCHAR(4)
	,NOTICE_SEQ_NO NUMBER(38, 0)
	,EXPOSURE_DT TIMESTAMP_NTZ(9)
	,BALANCEOPTIONMAXIMUMBALANCE NUMBER(38, 0)
	,BALANCEOPTIONMINIMUMBALANCE NUMBER(18, 2)
	,VEHICLETITLEOPTIONSTARTDATE TIMESTAMP_NTZ(9)
	,BALANCEOPTIONBALANCETYPE VARCHAR(100)
	,DELAYEDBILLING NUMBER(38, 0)
	,FORCEDPLCYOPTREPORTNONPAYDAYS NUMBER(38, 0)
	,FORCEDPLCYOPTCERTAUTHDAYS NUMBER(38, 0)
	,BATCH_ID NUMBER(18, 2) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15)
	,PROPERTY_ID NUMBER(38, 0)
	,BIA_ID NUMBER(38, 0)
	,CPI_QUOTE_ID NUMBER(38, 0)
	,RECORD_TYPE_CD VARCHAR(1)
	,INSURANCE_STATUS_CD VARCHAR(2)
	,INSURANCE_SUB_STATUS_CD VARCHAR(2)
	,CPI_STATUS_CD VARCHAR(2)
	,CPI_SUB_STATUS_CD VARCHAR(2)
	,START_DT TIMESTAMP_NTZ(9)
	,LENDER_PRODUCT_ID NUMBER(38, 0)
	,HASH_ID VARCHAR(32) NOT NULL
	,ESCROWCOLLECTIONTIMEWINDOW NUMBER(38, 0)
	,MORTGAGEOPTIONPREMDUEDAYS NUMBER(38, 0)
	,MORTGAGEOPTIONPREMVARIANCE NUMBER(18, 2)
	,TRACKESCROWINSURANCEBILLS NUMBER(38, 0)
	,FORCEDPLCYNONPAYDAYS NUMBER(38, 0)
	,FORCEDPLCYOPTBORRCOPY VARCHAR(100)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9)
	,ACVOPTIONACVREVALUATIONMONTHS NUMBER(38, 0)
	,ACVOPTIONSERIESMETHOD VARCHAR(100)
	,ACVOPTIONUSEACVRATING NUMBER(38, 0)
	,BALANCEOPTIONMAXIMUMOFF NUMBER(38, 0)
	,BALANCEOPTIONMAXIMUMOPTION VARCHAR(100)
	,BALANCEOPTIONMINIMUMOPTION VARCHAR(100)
	,BALANCEOPTIONREAUDITMIN NUMBER(18, 2)
	,BEGAN_NEW_IN VARCHAR(1)
	,BINDERIMPAIREDBINDERDAYS NUMBER(38, 0)
	,BINDERIMPAIREDBINDERRESET NUMBER(38, 0)
	,BINDERIMPAIREDIMPDAYS NUMBER(38, 0)
	,BINDERIMPAIREDIMPRESET NUMBER(38, 0)
	,BINDERIMPAIREDSENDBINDERNTC VARCHAR(100)
	,BINDERIMPAIREDSENDIMPNTC VARCHAR(100)
	,CERTIFICATEDAYSADJUSTMENT NUMBER(38, 0)
	,CHANGEDCARRIERMONTH NUMBER(38, 0)
	,CHECK_BALANCE_IN VARCHAR(1)
	,COLLATERALCODESURCHARGE NUMBER(18, 2)
	,CONDOCPICOVERAGEDISREGARDUNITOWNERS VARCHAR(1)
	,CONDOFLOODSTANDALONEPOLICY VARCHAR(1)
	,CONTACTEMAIL VARCHAR(100)
	,CONTACTEXT VARCHAR(100)
	,CONTACTNAME VARCHAR(100)
	,CONTACTPHONE VARCHAR(100)
	,CONTINUOUSCOVERAGENOTALLOWED NUMBER(38, 0)
	,COPYINSURANCERCVTOPROPERTY NUMBER(38, 0)
	,COVERAGEDUEDAYS NUMBER(38, 0)
	,DEFAULTRCVRESANDCONDOPOLICIES VARCHAR(1)
	,DISABLEVERIFYDATA VARCHAR(1)
	,DONOTIMPAIRFORUNKNOWNFLOODZONE VARCHAR(1)
	,ESCROW_PAID_THRU_DT TIMESTAMP_NTZ(9)
	,ESCROW_STATUS_CD VARCHAR(4)
	,ESCROW_SUB_STATUS_CD VARCHAR(4)
	,ESCROWDUEDAYS NUMBER(38, 0)
	,EVENTOPTIONAUDIT NUMBER(38, 0)
	,EVENTOPTIONBALANCE NUMBER(38, 0)
	,EVENTOPTIONDELAY NUMBER(38, 0)
	,EVENTOPTIONREAUDIT NUMBER(38, 0)
	,EXPOSURE_STATUS_DT TIMESTAMP_NTZ(9)
	,FANNIEMAEDEDUCTIBLERULE VARCHAR(1)
	,FEMADEDUCTIBLERULE VARCHAR(1)
	,FORCEDPLCYOPTAUDITBACKDATE TIMESTAMP_NTZ(9)
	,FORCEDPLCYOPTAUDITBACKDAYS NUMBER(38, 0)
	,FORCEDPLCYOPTLNDRCOPY VARCHAR(100)
	,FORCEDPLCYOPTNOISSUEONCANCELNOPAY VARCHAR(1)
	,FORCEDPLCYOPTNOPRINTLENDER NUMBER(38, 0)
	,FORCEDPLCYOPTREAUDITBACKDATE TIMESTAMP_NTZ(9)
	,FORCEDPLCYOPTREAUDITBACKDAYS NUMBER(38, 0)
	,FORCEDPLCYOPTUNINSUREDBACKDATE TIMESTAMP_NTZ(9)
	,FORCEDPLCYOPTUNINSUREDBACKDAYS NUMBER(38, 0)
	,FORCEDPLCYOPTUSECERTAUTH NUMBER(38, 0)
	,GENOPTHONORBINDER NUMBER(38, 0)
	,GENOPTMINCONTROPT VARCHAR(100)
	,GENOPTMINCONTRTERM NUMBER(38, 0)
	,GENOPTOUTGOINGCALL NUMBER(38, 0)
	,GENOPTTRACKONLY NUMBER(38, 0)
	,GOOD_THRU_DT TIMESTAMP_NTZ(9)
	,INCLUDEPOLICYCOVERAGEOTHERSTRUCTURE VARCHAR(1)
	,INSURABLE_VALUE_NO NUMBER(18, 2)
	,LAST_EVENT_DT TIMESTAMP_NTZ(9)
	,LAST_EVENT_SEQ_ID NUMBER(38, 0)
	,LAST_GOOD_INSURANCE_DT TIMESTAMP_NTZ(9)
	,LAST_SEQ_CONTAINER_ID NUMBER(38, 0)
	,LAST_STATUS_CALC_DT TIMESTAMP_NTZ(9)
	,LCGCT_ID NUMBER(38, 0)
	,LFPEVENTOPTIONREAUDIT NUMBER(38, 0)
	,LIABILITYMINBODILYINJURYPERACCIDENT NUMBER(18, 2)
	,LIABILITYMINBODILYINJURYPERPERSON NUMBER(18, 2)
	,LIABILITYMINCOMBINEDSL NUMBER(18, 2)
	,LIABILITYMINPROPERTYDAMAGE NUMBER(18, 2)
	,MANUALLENDER NUMBER(38, 0)
	,MAXCOLLATERALAGE NUMBER(38, 0)
	,MAXCOLLATERALAGEOPTION VARCHAR(100)
	,MAXDEDUCTOPTMAXDEDUCTIBLEPERCENT NUMBER(18, 2)
	,MAXDEDUCTOPTMORTHIGHBALANCE NUMBER(18, 2)
	,MAXDEDUCTOPTMORTHIGHBASIS VARCHAR(100)
	,MAXDEDUCTOPTMORTHIGHDEDUCT NUMBER(18, 2)
	,MAXDEDUCTOPTMORTMAXDEDUCTIBLE NUMBER(18, 2)
	,MAXDEDUCTOPTVEHHIGHCOLLISION NUMBER(18, 2)
	,MAXDEDUCTOPTVEHHIGHCOMP NUMBER(18, 2)
	,MAXDEDUCTOPTVEHHIGHDEDUCTBALANCE NUMBER(18, 2)
	,MAXDEDUCTOPTVEHHIGHDEDUCTBASIS VARCHAR(100)
	,MAXDEDUCTOPTVEHMAXCOLLISION NUMBER(18, 2)
	,MAXDEDUCTOPTVEHMAXCOMP NUMBER(18, 2)
	,MORTGAGEOPTIONISSUELINECREDIT NUMBER(38, 0)
	,NO_CYCLE_DT TIMESTAMP_NTZ(9)
	,NOTICEDAYSADJUSTMENT NUMBER(38, 0)
	,OLDCANCELREAUDITDAYS NUMBER(38, 0)
	,OVERRIDE_EXPOSURE_CD VARCHAR(10)
	,PIRSTARTDATE TIMESTAMP_NTZ(9)
	,PIRWAITPERIOD NUMBER(38, 0)
	,PMTOPTDELAYMONTHS NUMBER(38, 0)
	,PMTOPTINCRDELAYEDBILLING NUMBER(38, 0)
	,PMTOPTPMTINCREFFDT TIMESTAMP_NTZ(9)
	,PMTOPTPMTMETHOD VARCHAR(100)
	,PMTOPTPMTMETHODVALUE NUMBER(18, 2)
	,REGULARRCVALWAYSACCEPTABLE VARCHAR(1)
	,REPORTEDMORTMAXDEDUCTIBLE NUMBER(18, 2)
	,REPORTEDVEHMAXCOLLISION NUMBER(18, 2)
	,REPORTEDVEHMAXCOMP NUMBER(18, 2)
	,REQCOVAMTVARIANCEFIXEDAMT NUMBER(18, 2)
	,REQCOVAMTVARIANCEPCT NUMBER(18, 2)
	,REQUIREDCOVERAGEAMOUNTRULE VARCHAR(100)
	,SENDAGENTEMAILFAX NUMBER(38, 0)
	,SENDONENOTICESAMEADDRESS VARCHAR(1)
	,TRACKASSOCIATIONESCROWINSURANCEBILLS NUMBER(38, 0)
	,VEHICLETITLEOPTIONMAXCOLLAGE NUMBER(38, 0)
	,VEHICLETITLEOPTIONTITLEUPDATEHISTORY NUMBER(38, 0)
	,VEHICLETITLEOPTIONTRACKDEALER NUMBER(38, 0)
	,VEHICLETITLEOPTIONTRACKTITLE NUMBER(38, 0)
	,WRITEPREMIUMONPREMIUM VARCHAR(1)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0)
	,DISABLEFREEFORMLOANENTRY NUMBER(11, 0)
	,MIDTERMCANCELLATIONSDAYS NUMBER(11, 0)
	,MOBILEHOMEFLOODSTANDALONEPOLICY VARCHAR(1)
	,PREMIUMBILLORIGINATIONDATE NUMBER(11, 0)
	,REQUIRE--DESCROWCOVERAGEAMOUNT NUMBER(18, 2)
	,CURRENT_FLG VARCHAR(1)
	);
	
--DESC EDW_TEST.STG.STG_UT_CPI_ACTIVITY_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_CPI_ACTIVITY_H (
	ID NUMBER(38, 0) NOT NULL
	,CPI_QUOTE_ID NUMBER(38, 0) NOT NULL
	,TYPE_CD VARCHAR(2) NOT NULL
	,PROCESS_DT TIMESTAMP_NTZ(9) NOT NULL
	,TOTAL_PREMIUM_NO NUMBER(18, 2) NOT NULL
	,START_DT TIMESTAMP_NTZ(9)
	,END_DT TIMESTAMP_NTZ(9)
	,REASON_CD VARCHAR(20)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,PAYMENT_EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,PAYMENT_CHANGE_AMOUNT_NO NUMBER(18, 2)
	,PRIOR_PAYMENT_AMOUNT_NO NUMBER(18, 2)
	,NEW_PAYMENT_AMOUNT_NO NUMBER(18, 2)
	,REPORTING_CANCEL_DT TIMESTAMP_NTZ(9)
	,EXECUTION_STEPS_TX VARCHAR(8000)
	,COMMENT_TX VARCHAR(8000)
	,EARNED_PAYMENT_AMOUNT_NO NUMBER(18, 2)
	,SUB_REASON_CD VARCHAR(8)
	,IN_QUOTE_IN VARCHAR(2) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);


--DESC EDW_TEST.STG.STG_UT_OWNER_LOAN_RELATE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_OWNER_LOAN_RELATE_H (
	ID NUMBER(38, 0) NOT NULL
	,OWNER_ID NUMBER(38, 0) NOT NULL
	,LOAN_ID NUMBER(38, 0) NOT NULL
	,OWNER_TYPE_CD VARCHAR(4)
	,PRIMARY_IN VARCHAR(1) NOT NULL
	,RECEIVE_NOTICES_IN VARCHAR(1) NOT NULL
	,TAKE_UPDATES_IN VARCHAR(1) NOT NULL
	,LOCK_ID NUMBER(38, 0) NOT NULL
	,EXPIRATION_DT TIMESTAMP_NTZ(9)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(50) NOT NULL
	,CURRENT_FLG VARCHAR(1)
	);

--DESC EDW_TEST.STG.STG_UT_LOAN_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_LOAN_H (
	ID NUMBER(38, 0) NOT NULL
	,STATUS_CD VARCHAR(1) NOT NULL
	,EXTRACT_UNMATCH_COUNT_NO NUMBER(38, 0)
	,BRANCH_CODE_TX VARCHAR(20)
	,DIVISION_CODE_TX VARCHAR(20)
	,NUMBER_TX VARCHAR(18) NOT NULL
	,EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,MATURITY_DT TIMESTAMP_NTZ(9)
	,BALANCE_AMOUNT_NO NUMBER(19, 2)
	,ORIGINAL_BALANCE_AMOUNT_NO NUMBER(19, 2)
	,BALANCE_LAST_UPDATE_DT TIMESTAMP_NTZ(9)
	,APR_AMOUNT_NO NUMBER(15, 8)
	,PAYMENT_FREQUENCY_CD VARCHAR(1) NOT NULL
	,NOTE_TX VARCHAR(4000)
	,OFFICER_CODE_TX VARCHAR(20)
	,DEALER_CODE_TX VARCHAR(20)
	,CREDIT_SCORE_CD VARCHAR(20)
	,LAST_PAYMENT_DT TIMESTAMP_NTZ(9)
	,NEXT_SCHEDULED_PAYMENT_DT TIMESTAMP_NTZ(9)
	,LENDER_BRANCH_CODE_TX VARCHAR(20)
	,PREDICTIVE_SCORE_NO NUMBER(38, 0)
	,PREDICTIVE_DECILE_NO NUMBER(38, 0)
	,ORIGINAL_PAYMENT_AMOUNT_NO NUMBER(10, 2)
	,CONTRACT_TYPE_CD VARCHAR(30)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15) NOT NULL
	,LENDER_ID NUMBER(38, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,RECORD_TYPE_CD VARCHAR(1)
	,ESCROW_IN VARCHAR(1)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,STATUS_DT TIMESTAMP_NTZ(9)
	,TYPE_CD VARCHAR(4)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,BANKRUPTCY_VERIFY_DT TIMESTAMP_NTZ(9)
	,BANKRUPTCY_DT TIMESTAMP_NTZ(9)
	,CHARGEOFF_DT TIMESTAMP_NTZ(9)
	,SOURCE_CD VARCHAR(4)
	,BALANCE_TYPE_CD VARCHAR(1)
	,DEALER_REPORTED_DT TIMESTAMP_NTZ(9)
	,PAYMENT_AMOUNT_NO NUMBER(38, 0)
	,INTEREST_TYPE_CD VARCHAR(1)
	,PAYOFF_DT TIMESTAMP_NTZ(9)
	,DEPARTMENT_CODE_TX VARCHAR(20)
	,SERVICECENTER_CODE_TX VARCHAR(20)
	,CREDIT_LINE_AMOUNT_NO NUMBER(38, 0)
	,FANNIE_MAE_IN VARCHAR(1)
	,RETAIN_IN VARCHAR(1)
	,RETAIN_UTL_IN VARCHAR(1)
	,ASSOCIATE_IN VARCHAR(1)
	,EXCLUDE_ASSOCIATE_IN VARCHAR(1)
	,FIELD_PROTECTION_XML VARCHAR(32000)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(38, 0)
	,SPECIAL_HANDLING_XML VARCHAR(32000)
	,GSE_CD VARCHAR(4)
	,DELINQUENCY_DT TIMESTAMP_NTZ(9)
	,DELETED_DT TIMESTAMP_NTZ(9)
	,CURRENT_PAYMENT_INCREASE_AMOUNT_NO NUMBER(38, 0)
	,STATUS_OFFICER_CODE_TX VARCHAR(20)
	,EXTRACT_LOAN_UPDATE_ONLY_IN VARCHAR(1)
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_LENDER_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_LENDER_H (
	ID NUMBER(38, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,NAME_TX VARCHAR(200) NOT NULL
	,CODE_TX VARCHAR(20)
	,TYPE_CD VARCHAR(8)
	,REGULATORY_AUTHORITY_CD VARCHAR(8)
	,DESTINATION_CD VARCHAR(20)
	,TAX_ID_TX VARCHAR(60)
	,WEB_ADDRESS_TX VARCHAR(640)
	,PHONE_TX VARCHAR(40)
	,PHONE_EXT_TX VARCHAR(20)
	,FAX_TX VARCHAR(40)
	,FAX_EXT_TX VARCHAR(20)
	,TEST_IN VARCHAR(1) NOT NULL
	,NPO_REVIEW_IN VARCHAR(1) NOT NULL
	,PHYSICAL_ADDRESS_ID NUMBER(38, 0)
	,MAILING_ADDRESS_ID NUMBER(38, 0)
	,ACTIVE_DT TIMESTAMP_NTZ(9)
	,CANCEL_DT TIMESTAMP_NTZ(9)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,LENDER_CERT_CD VARCHAR(4)
	,CHARTER_NUMBER_TX VARCHAR(20)
	,SECONDARY_PHONE_TX VARCHAR(40)
	,SECONDARY_PHONE_EXT_TX VARCHAR(20)
	,STATUS_CD VARCHAR(20) NOT NULL
	,CANCEL_REASON_CD VARCHAR(20)
	,CANCEL_REASON_OTHER_TX VARCHAR(100)
	,REO_ADDRESS_ID NUMBER(38, 0)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_FORCE_PLACED_CERTIFICATE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_FORCE_PLACED_CERTIFICATE_H (
	ID NUMBER(38, 0) NOT NULL
	,LOAN_ID NUMBER(38, 0)
	,CPI_QUOTE_ID NUMBER(38, 0) NOT NULL
	,NUMBER_TX VARCHAR(36) NOT NULL
	,PRODUCER_NUMBER_TX VARCHAR(20) NOT NULL
	,LOAN_NUMBER_TX VARCHAR(36) NOT NULL
	,EXPECTED_ISSUE_DT TIMESTAMP_NTZ(9)
	,ISSUE_DT TIMESTAMP_NTZ(9)
	,EFFECTIVE_DT TIMESTAMP_NTZ(9)
	,EXPIRATION_DT TIMESTAMP_NTZ(9)
	,CANCELLATION_DT TIMESTAMP_NTZ(9)
	,STATUS_CD VARCHAR(2) NOT NULL
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,MONTHLY_BILLING_IN VARCHAR(1) NOT NULL
	,HOLD_IN VARCHAR(1) NOT NULL
	,CLAIM_PENDING_IN VARCHAR(1) NOT NULL
	,GENERATION_SOURCE_CD VARCHAR(2) NOT NULL
	,CURRENT_PAYMENT_AMOUNT_NO NUMBER(18, 2) NOT NULL
	,PREVIOUS_PAYMENT_AMOUNT_NO NUMBER(18, 2) NOT NULL
	,CREATED_BY_TX VARCHAR(30) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,PDF_GENERATE_CD VARCHAR(4) NOT NULL
	,TEMPLATE_ID NUMBER(38, 0)
	,COVER_LETTER_TEMPLATE_ID NUMBER(38, 0)
	,MSG_LOG_TX VARCHAR(4000)
	,CARRIER_ID NUMBER(38, 0)
	,MASTER_POLICY_ID NUMBER(38, 0)
	,AUTH_REQ_DT TIMESTAMP_NTZ(9)
	,QUICK_ISSUE_IN VARCHAR(1)
	,BILL_CD VARCHAR(8)
	,BILLING_STATUS_CD VARCHAR(8)
	,EARNED_PAYMENT_NO NUMBER(11, 0)
	,AUTHORIZED_BY_TX VARCHAR(20)
	,MASTER_POLICY_ASSIGNMENT_ID NUMBER(38, 0)
	,LENDER_INTENT VARCHAR(8000)
	,PAYMENT_REPORT_CD VARCHAR(1)
	,PAYMENT_REPORT_DT TIMESTAMP_NTZ(9)
	,PIR_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_FORCE_PLACED_CERT_REQUIRED_COVERAGE_RELATE_H (
	ID NUMBER(38, 0) NOT NULL
	,FPC_ID NUMBER(38, 0) NOT NULL
	,REQUIRED_COVERAGE_ID NUMBER(38, 0) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_COLLATERAL_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_COLLATERAL_H (
	ID NUMBER(38, 0) NOT NULL
	,LOAN_ID NUMBER(38, 0) NOT NULL
	,PROPERTY_ID NUMBER(38, 0) NOT NULL
	,PRIMARY_LOAN_IN VARCHAR(1) NOT NULL
	,STATUS_CD VARCHAR(2) NOT NULL
	,CPI_SUSPEND_DT TIMESTAMP_NTZ(9)
	,LOAN_BALANCE_NO NUMBER(19, 2)
	,LOAN_PERCENTAGE_NO NUMBER(12, 8)
	,COLLATERAL_CODE_ID NUMBER(38, 0) NOT NULL
	,LENDER_COLLATERAL_CODE_TX VARCHAR(10)
	,PURPOSE_CODE_TX VARCHAR(50)
	,EXTRACT_UNMATCH_COUNT_NO NUMBER(38, 0)
	,RETAIN_IN VARCHAR(1) NOT NULL
	,RELEASE_DT TIMESTAMP_NTZ(9)
	,RELEASE_OFFICER_CODE_TX VARCHAR(20)
	,REPO_DT TIMESTAMP_NTZ(9)
	,LEGAL_STATUS_CODE_TX VARCHAR(50)
	,LENDER_STATUS_DT TIMESTAMP_NTZ(9)
	,LENDER_STATUS_OFFICER_TX VARCHAR(20)
	,CATEGORY_TX VARCHAR(1)
	,DUE_NOT_PAID_AMOUNT_NO NUMBER(10, 2)
	,COLLATERAL_NUMBER_NO NUMBER(38, 0)
	,FIELD_PROTECTION_XML VARCHAR(256)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(15)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(38, 0) NOT NULL
	,OTHER_LENDER_LOAN_AMOUNT_NO NUMBER(19, 2)
	,DO_NOT_TRACK_BY_USER_TX VARCHAR(20)
	,LIEN_POSITION_NO NUMBER(38, 0)
	,SPECIAL_HANDLING_XML VARCHAR(256)
	,FLOOD_DETERMINATION_COMPANY_CD VARCHAR(10)
	,FLOOD_DETERMINATION_CONTRACT_NUMBER_TX VARCHAR(20)
	,ASSET_NUMBER_TX VARCHAR(20)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1)
	);

--DESC EDW_TEST.STG.STG_UT_WORK_ITEM_ACTION_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_WORK_ITEM_ACTION_H (
	ID NUMBER(38, 0) NOT NULL
	,WORK_ITEM_ID NUMBER(38, 0) NOT NULL
	,ACTION_CD VARCHAR(60)
	,FROM_STATUS_CD VARCHAR(40)
	,TO_STATUS_CD VARCHAR(40)
	,CURRENT_QUEUE_ID NUMBER(38, 0) NOT NULL
	,CURRENT_OWNER_ID NUMBER(38, 0)
	,ACTION_NOTE_TX VARCHAR(2000)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,ACTION_USER_ID NUMBER(38, 0)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_WORKFLOW_DEFINITION_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_WORKFLOW_DEFINITION_H (
	ID NUMBER(38, 0) NOT NULL
	,NAME_TX VARCHAR(60) NOT NULL
	,--DESCRIPTION_TX VARCHAR(160)
	,STATE_TRANSITION_DOMAIN_CD VARCHAR(60)
	,QUEUE_ASSIGNMENT_DOMAIN_CD VARCHAR(60)
	,SAS70_CONTROL_TX VARCHAR(60)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,WORKFLOW_TYPE_CD VARCHAR(50) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_WORK_QUEUE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_WORK_QUEUE_H (
	ID NUMBER(38, 0) NOT NULL
	,NAME_TX VARCHAR(60) NOT NULL
	,--DESCRIPTION_TX VARCHAR(160)
	,STATUS_CD VARCHAR(40)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9)
	,UPDATE_USER_TX VARCHAR(30)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,EXCLUSIVE_IN VARCHAR(1) NOT NULL
	,EVALUATION_ORDER_NO NUMBER(10, 2) NOT NULL
	,WORKFLOW_DEFINITION_ID NUMBER(38, 0) NOT NULL
	,WEB_IN VARCHAR(1) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_NOTICE_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_NOTICE_H (
	ID NUMBER(38, 0) NOT NULL
	,LOAN_ID NUMBER(38, 0)
	,FPC_ID NUMBER(38, 0)
	,CPI_QUOTE_ID NUMBER(38, 0)
	,TYPE_CD VARCHAR(60) NOT NULL
	,NAME_TX VARCHAR(100) NOT NULL
	,REFERENCE_ID_TX VARCHAR(100) NOT NULL
	,SEQUENCE_NO NUMBER(11, 0) NOT NULL
	,ISSUE_DT TIMESTAMP_NTZ(9)
	,EXPECTED_ISSUE_DT TIMESTAMP_NTZ(9) NOT NULL
	,REASON_TYPE_CD VARCHAR(8) NOT NULL
	,CLEAR_DT TIMESTAMP_NTZ(9)
	,CLEAR_REASON_CD VARCHAR(60)
	,CONFIGURATION_ID NUMBER(38, 0)
	,SENT_TO_TYPE_CD VARCHAR(8) NOT NULL
	,GENERATION_SOURCE_CD VARCHAR(2) NOT NULL
	,NOT_MAILED_IN VARCHAR(1) NOT NULL
	,NOT_MAILED_CD VARCHAR(8) NOT NULL
	,NOT_MAILED_NOTE_TX VARCHAR(8000)
	,CREATED_BY_TX VARCHAR(30) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,PDF_GENERATE_CD VARCHAR(4) NOT NULL
	,TEMPLATE_ID NUMBER(38, 0)
	,MSG_LOG_TX VARCHAR(4000)
	,DELIVERY_METHOD_TX VARCHAR(60)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	,CPI_QUOTE NUMBER(38, 0)
	,SUMMARY_SUB_STATUS_CD VARCHAR(10)
	,REC_COUNT NUMBER(38, 0)
	,CAPTURED_DATA_TXT VARCHAR(200000)
	,SUMMARY_STATUS_CD VARCHAR(10)
	,CAPTURED_DATA_XML VARIANT
	);
	
--DESC EDW_TEST.STG.STG_UT_UTL_MATCH_RESULT_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_UTL_MATCH_RESULT_H (
	ID NUMBER(38, 0) NOT NULL
	,UTL_LOAN_ID NUMBER(38, 0) NOT NULL
	,PROPERTY_ID NUMBER(38, 0) NOT NULL
	,LOAN_ID NUMBER(38, 0)
	,SCORE_NO NUMBER(11, 0) NOT NULL
	,MATCH_RESULT_CD VARCHAR(20) NOT NULL
	,USER_MATCH_RESULT_CD VARCHAR(20)
	,USER_MATCH_TX VARCHAR(30)
	,MSG_LOG_TX VARCHAR(8000)
	,LOG_TX VARCHAR(8000)
	,APPLY_STATUS_CD VARCHAR(20) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,AGENCY_ID NUMBER(38, 0) NOT NULL
	,UTL_OWNER_POLICY_ID NUMBER(38, 0) NOT NULL
	,SCORE_PERCENT_NO NUMBER(38, 0)
	,UTL_PROPERTY_ID NUMBER(38, 0)
	,ESCROW_IN VARCHAR(1) NOT NULL
	,UTL_VERSION_NO NUMBER(11, 0)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);

--DESC EDW_TEST.STG.STG_UT_FINANCIAL_TXN_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_FINANCIAL_TXN_H (
	FINANCIAL_TXN_ID NUMBER(38, 0) NOT NULL
	,FPC_ID NUMBER(38, 0) NOT NULL
	,LFT_ID NUMBER(38, 0)
	,AP_ID NUMBER(38, 0)
	,TXN_TYPE_CD VARCHAR(10) NOT NULL
	,AMOUNT_NO NUMBER(38, 0) NOT NULL
	,TXN_DT TIMESTAMP_NTZ(9) NOT NULL
	,REASON_TX VARCHAR(10)
	,ORIGINAL_BILLED_DT TIMESTAMP_NTZ(9)
	,GL_NUMBER_TX VARCHAR(50)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_USER_TX VARCHAR(15) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,TERM_NO NUMBER(38, 0)
	,DETAIL_TXN_TYPE_CD VARCHAR(10)
	,DETAIL_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,DETAIL_UPDATE_USER_TX VARCHAR(15) NOT NULL
	,DETAIL_PURGE_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(15) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(15) NOT NULL
	,CURRENT_FLG VARCHAR(1)
	,LOCK_ID NUMBER(10, 0)
	,PRIMARY KEY (FINANCIAL_TXN_ID)
	);
	
--DESC EDW_TEST.STG.STG_UT_TRADING_PARTNER_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_TRADING_PARTNER_H (
	ID NUMBER(38, 0)
	,TYPE_CD VARCHAR(30)
	,ACTIVE_IN VARCHAR(1) NOT NULL
	,DELIVER_TO_TP_ID NUMBER(38, 0)
	,STATUS_CD VARCHAR(30)
	,DELIVER_TO_TP_IN VARCHAR(1) NOT NULL
	,NAME_TX VARCHAR(100)
	,EXTERNAL_ID_TX VARCHAR(200) NOT NULL
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,RECEIVE_FROM_TP_ID NUMBER(38, 0)
	,UPDATE_USER_TX VARCHAR(30)
	,PURGE_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0)
	,CREATE_DT TIMESTAMP_NTZ(9)
	,HASH_ID VARCHAR(32)
	,UPDATE_DT TIMESTAMP_NTZ(9)
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);
	
--DESC EDW_TEST.STG.STG_UT_QUALITY_CONTROL_ITEM_H;	

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_QUALITY_CONTROL_ITEM_H (
	ID NUMBER(38, 0) NOT NULL
	,QC_BATCH_ITEM_ID NUMBER(38, 0) NOT NULL
	,QC_BATCH_TYPE_CD VARCHAR(20) NOT NULL
	,QC_RULE_DEF_CD VARCHAR(100) NOT NULL
	,QC_BATCH_NAME_TX VARCHAR(200) NOT NULL
	,QC_BATCH_RUN_DT TIMESTAMP_NTZ(9) NOT NULL
	,LOAN_ID NUMBER(38, 0) NOT NULL
	,PROPERTY_ID NUMBER(38, 0) NOT NULL
	,REQUIRED_COVERAGE_ID NUMBER(38, 0) NOT NULL
	,SUMMARY_STATUS_CD VARCHAR(8)
	,SUMMARY_SUB_STATUS_CD VARCHAR(8)
	,STATUS_CD VARCHAR(20) NOT NULL
	,MEMO_TX VARCHAR(2000)
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0)
	,QC_BATCH_DEF_ID NUMBER(38, 0)
	,HASH_ID VARCHAR(30) NOT NULL
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,SRC_UPDATE_USER_TX VARCHAR(15)
	,PRIMARY KEY (ID)
	);

--DESC EDW_TEST.STG.STG_UT_LENDER_PRODUCT_H;

CREATE OR REPLACE TABLE EDW_PROD.STG.STG_UT_LENDER_PRODUCT_H (
	ID NUMBER(38, 0) NOT NULL
	,NAME_TX VARCHAR(200) NOT NULL
	,START_DT TIMESTAMP_NTZ(9) NOT NULL
	,END_DT TIMESTAMP_NTZ(9) NOT NULL
	,BASIC_TYPE_CD VARCHAR(20) NOT NULL
	,BASIC_SUB_TYPE_CD VARCHAR(20) NOT NULL
	,SRC_CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,SRC_UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_USER_TX VARCHAR(30) NOT NULL
	,PURGE_DT TIMESTAMP_NTZ(9)
	,LOCK_ID NUMBER(3, 0) NOT NULL
	,LENDER_ID NUMBER(38, 0) NOT NULL
	,--DESCRIPTION_TX VARCHAR(1000)
	,ARCHIVE_DT TIMESTAMP_NTZ(9)
	,DELETE_DT TIMESTAMP_NTZ(9)
	,BATCH_ID NUMBER(38, 0) NOT NULL
	,HASH_ID VARCHAR(32) NOT NULL
	,CREATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,UPDATE_DT TIMESTAMP_NTZ(9) NOT NULL
	,CURRENT_FLG VARCHAR(1) NOT NULL
	);



--DESC EDW_TEST.STG.STG_UT_VUT_TBLIMAGEQUEUE_H;

create or replace TABLE EDW_PROD.STG.STG_UT_VUT_TBLIMAGEQUEUE_H (
	ID NUMBER(38,0) NOT NULL,
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
	UPDATE_USER_TX VARCHAR(15)
);
