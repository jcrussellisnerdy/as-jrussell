----EXEC [DBA].[info].[getObjectUsage] @DryRun = 1

/*
    EXEC DBA.deploy.SetDatabaseRole @databaseType  = 'ADMIN', @debug = 1 , @force = 1 , @DryRun = 0 
    EXEC DBA.deploy.SetDatabaseRole @databaseType  = 'USER', @debug = 1 , @force = 1 , @DryRun = 0 
EXEC [HDTStorage].[archive].[CreateStorageSchema] @WhatIf = 1, @Debug =1 


SELECT * FROM [PerfStats].[utag].[AGLAgStats]
WHERE CURRENT_DT >= CAST(GETDATE()-7 AS DATE)
order by current_dt desc


      EXEC [PerfStats].[dbo].[CaptureErrorLogFile] @WhatIF= 0 
*/
select SQLServerName from dba.info.Instance
/*Shows server information*/ 
EXEC [DBA].[info].[GetInstance] @DryRun = 1
/*Shows Database with owner, and Database type*/ 
EXEC [DBA].[info].[getDatabase] @DryRun = 1
/*Shows all agent jobs */ 
EXEC [DBA].[info].[getAgentJob] @DryRun = 1
/*Shows drives usage*/ 
EXEC [DBA].[info].[getDriveUsage] @DryRun = 1
/* Shows drives usage and how close we are to running out of space*/ 
EXEC [PerfStats].[dbo].[CaptureDriveUsage] @WhatIf = 1
/*Shows all the linked servers*/ 
EXEC [DBA].[info].[getLinkedServer] @DryRun = 1
/*Shows the AG information*/ 
EXEC [PerfStats]. [dbo].[CaptureAGLagStats] @DryRun = 1



--EXEC DBA.DBO.SP_WHOISACTIVE  @get_task_info =2,@get_plans =2 ,  @get_avg_time=1;



