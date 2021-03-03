--/-------------------------------------------------------------------
-- DOWNLOAD FILE FROM AN SSH LOCATION USING WINSCP
-- USING T-SQL ONLY
--/-------------------------------------------------------------------

--/-------------FILE MASK
DECLARE     @FILENAME VARCHAR(22) = 'DOWNLOAD_REPORT_'
,           @YEAR VARCHAR(4) = CONVERT(VARCHAR(4), YEAR(GETDATE()))
,           @MONTH VARCHAR(2) = FORMAT(GETDATE(),'MM')
,           @DAY   VARCHAR(2) =  FORMAT(GETDATE(),'dd')
,           @FULL_FILENAME VARCHAR(40)

--/--------EXMAPLE FILENAME TO DOWNLOAD
SET @FULL_FILENAME = @FILENAME + @YEAR + '_' + @MONTH + '_' + @DAY + '.csv'
-- DOWNLOAD_REPORT_2021_03_03.csv

DECLARE   @WinscpCmd VARCHAR(500)
,         @output INT

--/-------------------------------------------------------------------
-- SET CMD
-- -delete IS OPTIONAL, THIS WILL DELETE THE REMOTE FILE
--/-------------------------------------------------------------------
SET @WinscpCmd = 'C:\Tools\winscp.com /ini=nul /command "open sftp://{username}:{password}@{serverlocation}/ -hostkey="{"hostkey fingerprint"}"" "get { -delete } ' + @FULL_FILENAME + ' C:\Downloads\" "exit"'

--/-------------------------------------------------------------------
-- EXECUTE
--/-------------------------------------------------------------------                                                        
EXEC @output = xp_cmdshell @WinscpCmd;

PRINT @output                                                        
                                                      
