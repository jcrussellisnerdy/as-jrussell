DECLARE @sqlcmd VARCHAR(max);
DECLARE @retval INT;
DECLARE @ServerName SYSNAME = 'UTLSERVER'
DECLARE @DryRun INT =0;
DECLARE @Force INT =1;

--exec sp_linkedservers

--1.-Does an exist check if it has a variable of 0, 1 then it goes to next step. 
IF EXISTS(SELECT 1
          FROM   master.dbo.sysservers
          WHERE  srvname LIKE @ServerName)
  BEGIN
      BEGIN TRY
          EXEC @retval = sys.Sp_testlinkedserver
            @ServerName;
      END TRY
      BEGIN CATCH
          SET @retval = Sign(@@ERROR);
      END CATCH
  END
IF @retval IN ( 0, 1 )
  BEGIN
---2. Checks for the variable of 0, 1 then if has a variable of 0 then it will show that it is a valid server that works.
--You can force it to drop with the hidden variable @force =0
      IF @retval = 0
        BEGIN
            IF @Force = 0
              BEGIN
                  PRINT 'WARNING: This server is connecting but the users want it dropped ' + @ServerName + ''

                  SELECT @SQLCMD = 'BEGIN TRY 
			 EXEC master.dbo.Sp_dropserver
                @server= ''' + @ServerName
                                   + ''',
                @droplogins=''droplogins''
				END TRY
				
				BEGIN CATCH
RETURN
END CATCH'
              END
            ELSE
              BEGIN
                  PRINT 'SUCCESS: LINKED SERVER ''' + Isnull(@ServerName, '')
                        + ''' IS CONNECTING!'
              END
        END
      ELSE
	  --2. If it is 1 then it show that it is broken and begin the process of trying to drop the server. 
        BEGIN
            PRINT 'WARNING: Server Name: ' + @ServerName + ' IS BROKEN CONNECTION'


            SELECT @SQLCMD = 'BEGIN TRY 
			 EXEC master.dbo.Sp_dropserver
                @server= ''' + @ServerName
                             + ''',
                @droplogins=''droplogins''
				END TRY
				
				BEGIN CATCH
RETURN
END CATCH'

			PRINT 'SUCCESS: Dropping Server ' + @ServerName + ''
        END
  END
ELSE
---1. If it is anything else fails with this error message and stops here!
  BEGIN
      PRINT 'FAIL: LINKED SERVER ''' + Isnull(@ServerName, '')
            + ''' DOES NOT EXIST!'
  END



IF @DryRun = 0
--3.If the DryRun is 0 then it will execute the executing query if it is the force or standard.
  BEGIN
      EXEC ( @SQLcmd)
  END
ELSE
--3.If the DryRun is 1 then it will ONLY show the job whether or not if it is the force or standard.
  BEGIN
      PRINT ( @SQLcmd )
  END 
