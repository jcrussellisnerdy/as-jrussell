DECLARE 
    @DryRun BIT = 1,          -- 1 = show what would happen, 0 = actually apply change
    @Verbose BIT = 0;         -- 1 = show messages, 0 = grid result only

DECLARE @CurrentMaxMB INT;
DECLARE @TotalMemoryGB DECIMAL(10, 1);
DECLARE @OSReserveGB DECIMAL(10, 1);
DECLARE @RecommendedMaxGB DECIMAL(10, 1);
DECLARE @RecommendedMaxMB INT;
DECLARE @StatusMessage VARCHAR(100);

-- Get current max server memory setting
SELECT @CurrentMaxMB = CAST(value_in_use AS INT)
FROM sys.configurations
WHERE name = 'max server memory (MB)';

-- Get total physical memory
SELECT @TotalMemoryGB = ROUND(total_physical_memory_kb / 1024.0 / 1024.0, 1)
FROM sys.dm_os_sys_memory;

-- Calculate OS reserve
SET @OSReserveGB = 
    CASE 
        WHEN @TotalMemoryGB <= 16 THEN 6.0
        WHEN @TotalMemoryGB <= 64 THEN 6.0
        WHEN @TotalMemoryGB <= 128 THEN 8.0
        WHEN @TotalMemoryGB <= 256 THEN 16.0
        WHEN @TotalMemoryGB <= 512 THEN 32.0
        ELSE 64.0
    END;

-- Calculate recommended max server memory for SQL Server
SET @RecommendedMaxGB = ROUND(@TotalMemoryGB - @OSReserveGB, 1);
SET @RecommendedMaxMB = CAST(@RecommendedMaxGB * 1024 AS INT);

-- Determine status message
IF ROUND(@CurrentMaxMB / 1024.0, 1) <> @RecommendedMaxGB
BEGIN
    SET @StatusMessage =
        CASE 
            WHEN @DryRun <> 0 THEN 'DRY RUN: Would apply change'
            ELSE 'APPLYING CHANGE: Change executed'
        END;

    -- When Verbose = 0 and DryRun = 1, only return grid output
    IF @Verbose = 0 AND @DryRun <> 0
    BEGIN
        SELECT
            @TotalMemoryGB AS TotalMemoryGB,
            @OSReserveGB AS OS_Reserve_GB,
            @RecommendedMaxGB AS Recommended_SQL_Max_Memory_GB,
            ROUND(@CurrentMaxMB / 1024.0, 1) AS Current_SQL_Max_Memory_GB,
            @StatusMessage AS MemorySettingStatus;
    END
    ELSE
    BEGIN
        -- When Verbose = 1, print detailed info
        PRINT '--- Memory Configuration Info ---';
        PRINT 'Total Physical Memory (GB): ' + CAST(@TotalMemoryGB AS VARCHAR);
        PRINT 'OS Reserved (GB): ' + CAST(@OSReserveGB AS VARCHAR);
        PRINT 'Current SQL Max Memory (GB): ' + CAST(ROUND(@CurrentMaxMB / 1024.0, 1) AS VARCHAR);
        PRINT 'Recommended SQL Max Memory (GB): ' + CAST(@RecommendedMaxGB AS VARCHAR);
        PRINT 'Status: ' + @StatusMessage;
    END;

    -- Apply change if DryRun = 0
    IF @DryRun = 0
    BEGIN
        --EXEC sp_configure 'show advanced options', 1;
        --RECONFIGURE;
        --EXEC sp_configure 'max server memory (MB)', @RecommendedMaxMB;
        --RECONFIGURE;
		print 'Not enabled until we are ready to put this into a proc'
    END
    ELSE
    BEGIN
        PRINT 'The following change would be applied (Dry Run):';
        PRINT 'EXEC sp_configure ''show advanced options'', 1;';
        PRINT 'RECONFIGURE;';
        PRINT 'EXEC sp_configure ''max server memory (MB)'', ' + CAST(@RecommendedMaxMB AS VARCHAR) + ';';
        PRINT 'RECONFIGURE;';
    END
END
ELSE
BEGIN
    -- Indicate that no change is needed
    SET @StatusMessage = 'No change needed';

    -- Return grid result when no change needed
    IF @Verbose = 0
    BEGIN
        SELECT
            @TotalMemoryGB AS TotalMemoryGB,
            @OSReserveGB AS OS_Reserve_GB,
            @RecommendedMaxGB AS Recommended_SQL_Max_Memory_GB,
            ROUND(@CurrentMaxMB / 1024.0, 1) AS Current_SQL_Max_Memory_GB,
            @StatusMessage AS MemorySettingStatus;
    END
    ELSE
    BEGIN
        PRINT 'No changes are needed as the current max server memory setting matches the recommended value.';
        PRINT 'Current SQL Max Memory (GB): ' + CAST(ROUND(@CurrentMaxMB / 1024.0, 1) AS VARCHAR);
        PRINT 'Recommended SQL Max Memory (GB): ' + CAST(@RecommendedMaxGB AS VARCHAR);
        PRINT 'Status: ' + @StatusMessage;
    END;
END;
