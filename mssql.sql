
-- датасет отсюда https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/ (первый)
-- показываем, что оптимизатор может недооценить селективность индекса

set statistics time on;

CREATE DATABASE [database_name] ON ( FILENAME = N'/tmp/new_datasets/StackOverflow2010.mdf' ), ( FILENAME = N'/tmp/new_datasets/StackOverflow2010_log.ldf' ) FOR ATTACH ;
 
CREATE INDEX CreationDate_Reputation  ON dbo.Users(CreationDate, Reputation);
CREATE INDEX Reputation_CreationDate  ON dbo.Users(Reputation, CreationDate);
go
SET STATISTICS XML ON
go
SET STATISTICS IO ON;

SELECT * FROM dbo.Users WHERE CreationDate > '2010-11-10' AND Reputation > 100 ORDER BY DisplayName;
go
SELECT * FROM dbo.Users WITH (index=CreationDate_Reputation) WHERE CreationDate > '2010-11-10' AND Reputation > 5000 ORDER BY DisplayName;

-- https://www.brentozar.com/pastetheplan/?id=HkVLwUVwj