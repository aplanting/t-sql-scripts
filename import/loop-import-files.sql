--/-----------------------------------------------------
-- LOOP THROUGH AN DIRECTORY ON YOUR SERVER
-- AND IMPORT (CSV) FILES 1 BY ONE INTO AN TABLE
-- OR PROCESS IT ONE BY ONE.
--/-----------------------------------------------------

DECLARE @FILE_LOCATION VARCHAR(250)

--/-----------------------------------------------------------------
-- CHANGE FOLDER LOCATION, RELATIVE TO WHERE YOUR SQL SERVER LIVES
--/-----------------------------------------------------------------
SET @FILE_LOCATION	= 'C:\CodeBase\database-development\Import\'

DECLARE @DirTree
    TABLE (
         Id					INT  IDENTITY(1,1)
      ,  SubDirectory		NVARCHAR(255)
      ,  Depth				SMALLINT
      ,  FileFlag			BIT
      ,  ParentDirectoryID  INT
     )
    INSERT INTO @DirTree (SubDirectory, Depth, FileFlag)
    
EXEC master..xp_dirtree @FILE_LOCATION, 1, 1

--/-----------------------------------------------------------------
-- CREATE FILES TABLE AND TRAVERSE FOLDER
--/-----------------------------------------------------------------
  IF OBJECT_ID('TEMPDB..#FILES') IS NOT NULL DROP TABLE #FILES;
	  CREATE TABLE #FILES (
		  ID				INT IDENTITY(1,1) NOT NULL,
		  SUBDIRECTORY	VARCHAR(255) NOT NULL
	);
  
  --/------------------------------------------------------------------
  -- YOU CAN SKIP SUBFOLDERS LIKE IN THE EXAMPLE (ARCHIVE AND _FAILED )
  -- FILEFLAG=1 MEANS FILES (DUH)
  --/------------------------------------------------------------------
	INSERT INTO #FILES ( SUBDIRECTORY )
  SELECT  SubDirectory
	FROM	@DirTree
	WHERE	SubDirectory != 'Archive' AND SubDirectory != '_failed' AND FileFlag = 1;
  
  --/------------------------------------------------------------------
  -- CREATE SIMPLE LOOP TO START FILE BY FILE PROCESSING
  --/------------------------------------------------------------------
  DECLARE  @CUR     INT = 1
  ,        @CNT     INT = 0
  ,        @FILE    NVARCHAR(255)
  ,        @FULL_PATH_TO_FILE NVARCHAR(255)
  ,        @SQL     NVARCHAR(500)
  
  --/------HOW MANY FILES
  SELECT	@CNT = COUNT(*) FROM #FILES
	
  --/-------------------------------------------------------------------
  -- YOU CAN CREATE AN TABLE TO HOLD THE IMPORTED FILE
  -- USE 1 TABLE AND LOAD ALL THE FILES INTO 1 TABLE
  -- OR TRUNCATE THE TABLE AFTER PROCESSING IF YOU WANT FILE BY FILE
  --/-------------------------------------------------------------------
  IF OBJECT_ID('TEMPDB.#IMPORT') IS NOT NULL DROP TABLE #IMPORT;
	CREATE TABLE #IMPORT (
    [ COVER THE LAYOUT OF THE FILE HERE TO REPRESENT THE COLUMNS],
    MAKE YOUR LIFE EASIER AND TRY NOT TO SET INTEGER OR DATETIME COLUMNS ]
    -- EXAMPLE COLUMNS OF A FILE
    NAME        NVARCHAR(50) NULL,
    EMAIL       VARCHAR(100) NOT NULL,
    CREATED_AT  VARHAR(50) NOT NULL
  );
  
  IF (@CNT > 0 )
  BEGIN
  
    WHILE @CUR <= @CNT
      BEGIN
      
      -- IF YOU HAVE MULTIPLE FILES AND WANT THEM INTO 1 TABLE DO NOT USE TRUNCATE.
      -- 3 FILES WILL RESULT INTO A TEMP TABLE WITH ONLY THE LAST FILE IF YOU DO.
      -- TRUNCATE TABLE #IMPORT;
      
      --/-------------------------------
      -- START BULK IMPORT FILES
      --/-------------------------------
      SELECT  @FILE = SubDirectory FROM #FILES WHERE Id = @CUR
      SET     @FULL_PATH_TO_FILE = @FILE_LOCATION +  @FILE
      
      --/-------------------------------
      -- DYNAMIC SQL EXAMPLE FOR BULK IMPORT
      -- SETTING DEPEND ON YOUR FILE
      -- FIRSTROW = 1 IF NO COLUMN HEADERS
      -- FIELDTERMINATOR = , COULD BY ; OR | ETC.
      -- ROWTERMINATOR, 0X0A ( hexadecimal notation FOR LF )
      --/-------------------------------
      SET @SQL = '
            BULK INSERT #IMPORT
            FROM ''' + @FULL_PATH_TO_FILE + '''
            WITH (
                  DATAFILETYPE = ''char'',
                  FIRSTROW = 2,
                  FIELDTERMINATOR = '','',
                  ROWTERMINATOR=''0x0a''
               )'
       EXEC(@SQL)
        
      --/----------------------------------------------------
      -- PROCESS THE FILE
      -- YOU COULD:
      -- STORE THE FILENAME SOMEWHERE
      --/----------------------------------------------------
      
      
      SET @CUR = @CUR + 1
      END
  
  --/---------IF FILES
  END
