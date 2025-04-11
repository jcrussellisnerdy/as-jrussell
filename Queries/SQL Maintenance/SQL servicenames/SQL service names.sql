-- Step 1: Temp table to store raw service info
IF OBJECT_ID('tempdb..#SQLServiceInfo') IS NOT NULL DROP TABLE #SQLServiceInfo;
CREATE TABLE #SQLServiceInfo (
    RawOutput NVARCHAR(4000)
);

-- Step 2: Run WMIC via xp_cmdshell to gather service info
INSERT INTO #SQLServiceInfo (RawOutput)
EXEC xp_cmdshell 'wmic service where "name like ''%%SQL%%''" get Name,DisplayName,State,StartMode,StartName /format:table';

-- Step 3: Create clean final table
IF OBJECT_ID('tempdb..#ParsedSQLServiceInfo') IS NOT NULL DROP TABLE #ParsedSQLServiceInfo;
CREATE TABLE #ParsedSQLServiceInfo (
    ServiceName     NVARCHAR(200),
    DisplayName     NVARCHAR(200),
    State           NVARCHAR(200),
    StartMode       NVARCHAR(50),
    ServiceAccount  NVARCHAR(200)
);

-- Step 4: Do it raw and inline — no CTEs, just the good stuff
INSERT INTO #ParsedSQLServiceInfo (ServiceName, DisplayName, State, StartMode, ServiceAccount)
SELECT 
    LTRIM(RTRIM(SUBSTRING(RawOutput, 1, CHARINDEX('  ', RawOutput)))) AS DisplayName,
    
    -- ServiceName: between DisplayName and first double space
    CASE 
        WHEN CHARINDEX('  ', RawOutput) > 0 AND CHARINDEX('  ', RawOutput, CHARINDEX('  ', RawOutput) + 2) > 0 THEN
            LTRIM(RTRIM(SUBSTRING(
                RawOutput,
                CHARINDEX('  ', RawOutput) + 2,
                CHARINDEX('  ', RawOutput, CHARINDEX('  ', RawOutput) + 2) - CHARINDEX('  ', RawOutput) - 2
            )))
        ELSE NULL
    END AS ServiceName,

    -- State
    CASE 
        WHEN CHARINDEX(' Running', RawOutput) > 0 THEN 'Running'
        WHEN CHARINDEX(' Stopped', RawOutput) > 0 THEN 'Stopped'
        ELSE 'Unknown'
    END AS State,

    -- StartMode
    CASE 
        WHEN CHARINDEX(' Auto', RawOutput) > 0 THEN 'Auto'
        WHEN CHARINDEX(' Manual', RawOutput) > 0 THEN 'Manual'
        WHEN CHARINDEX(' Disabled', RawOutput) > 0 THEN 'Disabled'
        ELSE 'Unknown'
    END AS StartMode,
    -- Extracting ServiceName between parentheses
    --CASE 
    --    WHEN CHARINDEX('(', RawOutput) > 0 AND CHARINDEX(')', RawOutput) > CHARINDEX('(', RawOutput) THEN 
    --        LTRIM(RTRIM(SUBSTRING(RawOutput, CHARINDEX('(', RawOutput) + 1, CHARINDEX(')', RawOutput) - CHARINDEX('(', RawOutput) - 1)))
    --    ELSE NULL
    --END AS ServiceName,

    ---- Extracting DisplayName (everything before '(')
    --CASE 
    --    WHEN CHARINDEX('(', RawOutput) > 0 THEN 
    --        LTRIM(RTRIM(SUBSTRING(RawOutput, 1, CHARINDEX('(', RawOutput) - 1)))
    --    ELSE RawOutput
    --END AS DisplayName,

    ---- Extracting State
    --CASE 
    --    WHEN CHARINDEX('Running', RawOutput) > 0 THEN 'Running'
    --    WHEN CHARINDEX('Stopped', RawOutput) > 0 THEN 'Stopped'
    --    ELSE 'Unknown'
    --END AS State,

    ---- Extracting StartMode (Auto/Manual)
    --CASE 
    --    WHEN CHARINDEX('Manual', RawOutput) > 0 THEN 'Manual'
    --    WHEN CHARINDEX('Auto', RawOutput) > 0 THEN 'Auto'
    --    ELSE 'Unknown'
    --END AS StartMode,
-- ServiceAccount: extract full account name before 'Running' or 'Stopped'
    LTRIM(RTRIM(
        SUBSTRING(
            RawOutput,
            -- Start after StartMode
            CASE 
                WHEN CHARINDEX(' Auto', RawOutput) > 0 THEN CHARINDEX(' Auto', RawOutput) + LEN(' Auto')
                WHEN CHARINDEX(' Manual', RawOutput) > 0 THEN CHARINDEX(' Manual', RawOutput) + LEN(' Manual')
                WHEN CHARINDEX(' Disabled', RawOutput) > 0 THEN CHARINDEX(' Disabled', RawOutput) + LEN(' Disabled')
                ELSE 0
            END,
            -- Length: up to start of State
            CASE 
                WHEN CHARINDEX(' Running', RawOutput) > 0 THEN CHARINDEX(' Running', RawOutput)
                WHEN CHARINDEX(' Stopped', RawOutput) > 0 THEN CHARINDEX(' Stopped', RawOutput)
                ELSE LEN(RawOutput)
            END
            -
            CASE 
                WHEN CHARINDEX(' Auto', RawOutput) > 0 THEN CHARINDEX(' Auto', RawOutput) + LEN(' Auto')
                WHEN CHARINDEX(' Manual', RawOutput) > 0 THEN CHARINDEX(' Manual', RawOutput) + LEN(' Manual')
                WHEN CHARINDEX(' Disabled', RawOutput) > 0 THEN CHARINDEX(' Disabled', RawOutput) + LEN(' Disabled')
                ELSE 0
            END
        )
    )) AS ServiceAccount

    -- Extracting ServiceAccount (removes State like 'Running', 'Stopped')
 --   CASE 
 --       WHEN CHARINDEX('NT AUTHORITY', RawOutput) > 0 THEN
 --           -- Get service account, stop at the State part like 'Running', 'Stopped'
 --           LTRIM(RTRIM(SUBSTRING(RawOutput, CHARINDEX('NT AUTHORITY', RawOutput), 
 --               CHARINDEX('Running', RawOutput + 'Running') - CHARINDEX('NT AUTHORITY', RawOutput))))
 --WHEN CHARINDEX('NT Service', RawOutput) > 0 THEN
 --           -- Get service account, stop at the State part like 'Running', 'Stopped'
 --           LTRIM(RTRIM(SUBSTRING(RawOutput, CHARINDEX('NT Service', RawOutput), 
 --               CHARINDEX('Running', RawOutput + 'Running') - CHARINDEX('NT Service', RawOutput))))
 --WHEN CHARINDEX('LocalSystem', RawOutput) > 0 THEN
 --           -- Get service account, stop at the State part like 'Running', 'Stopped'
 --           LTRIM(RTRIM(SUBSTRING(RawOutput, CHARINDEX('LocalSystem', RawOutput), 
 --               CHARINDEX('Running', RawOutput + 'Running') - CHARINDEX('LocalSystem', RawOutput))))
 --WHEN CHARINDEX('ELDREDGE_A\', RawOutput) > 0 THEN
 --           -- Get service account, stop at the State part like 'Running', 'Stopped'
 --           LTRIM(RTRIM(SUBSTRING(RawOutput, CHARINDEX('ELDREDGE_A\', RawOutput), 
 --               CHARINDEX('Running', RawOutput + 'Running') - CHARINDEX('ELDREDGE_A\', RawOutput))))

 --   WHEN CHARINDEX('@', RawOutput) > 0 THEN
 --       -- For domain accounts in the format domain\username or @domainname.local
 --     SUBSTRING(RawOutput, CHARINDEX('@', RawOutput), 
 --           CHARINDEX('Running', RawOutput + 'Running') - CHARINDEX('@', RawOutput))
 --      ELSE 'Unknown'

 --   END AS ServiceAccount
FROM #SQLServiceInfo
WHERE RawOutput NOT LIKE '%Name%' 
  AND RawOutput NOT LIKE '%====%'  -- Exclude header rows
  AND RawOutput IS NOT NULL;

-- Step 5: Show the final output
SELECT * FROM #ParsedSQLServiceInfo
WHERE ServiceAccount <> ''
AND ServiceAccount LIKE '%@%'
OR ServiceAccount LIKE 'ELDREDGE_A\%';

