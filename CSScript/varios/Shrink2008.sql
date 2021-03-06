use master
go
if object_id( 'sp_force_shrink_log' ) is not null drop proc sp_force_shrink_log
go
create proc sp_force_shrink_log
as
begin

      SET NOCOUNT ON
      
      CREATE TABLE #TransactionLogFiles
      
      (
      DBName VARCHAR(150),
      
      LogFileName VARCHAR(150)
      
      )
      
      DECLARE DBList CURSOR FOR
      
      SELECT name
      
      FROM master..sysdatabases
      
      WHERE NAME NOT IN ('master','tempdb','model','msdb','distribution')
      
      DECLARE @DB VARCHAR(100)
      DECLARE @SQL VARCHAR(8000)
      
      OPEN DBList
      
      FETCH NEXT FROM DBList INTO @DB
      
      WHILE @@FETCH_STATUS <> -1
      
      BEGIN
      SET @SQL = 'USE ' + @DB + '
      
      INSERT INTO #TransactionLogFiles(DBName, LogFileName) SELECT ''' + @DB + ''', Name FROM sysfiles WHERE FileID=2'
      EXEC(@SQL)
      
      FETCH NEXT FROM DBList INTO @DB
      
      END
      DEALLOCATE DBList
      
      DECLARE TranLogList CURSOR FOR
      
      SELECT DBName, LogFileName
      FROM #TransactionLogFiles
      
      DECLARE @LogFile VARCHAR(100)
      
      OPEN TranLogList
      
      FETCH NEXT FROM TranLogList INTO @DB, @LogFile
      
      WHILE @@FETCH_STATUS <> -1
      BEGIN
      
      --PRINT @DB +',' + @LogFile
      
      SELECT @SQL = 'EXEC sp_dbOption ' + @DB + ', ''trunc. log on chkpt.'', ''True'''
      
      EXEC(@SQL)
      
      SELECT @SQL = 'USE ' + @DB + ' DBCC SHRINKFILE(''' + @LogFile + ''',''truncateonly'') WITH NO_INFOMSGS'
      
      EXEC(@SQL)
      
      SELECT @SQL = 'EXEC sp_dbOption ' + @DB + ', ''trunc. log on chkpt.'', ''False'''
      EXEC(@SQL) FETCH NEXT FROM TranLogList INTO @DB, @LogFile
      
      END
      
      DEALLOCATE TranLogList
      
      DROP TABLE #TransactionLogFiles 

end

go

