--

CREATE TABLE clients (phone varchar(20), full_name varchar(50));
INSERT INTO clients SELECT concat('79104' , lpad(Rownum, 6, '0')), standard_hash(Rownum, 'MD5') FROM dual Connect By Rownum <= 999999 order by DBMS_RANDOM.VALUE;
CREATE INDEX clients_phone_idx ON clients (phone);

explain plan for select  full_name from new_clients where phone > '79104000009' and phone like '%123456%';
@?/rdbms/admin/utlxpls
explain plan for select /*+ INDEX (new_clients new_clients_phone_idx)*/ full_name from new_clients where phone > '79104000009' and phone like '%123456%';
@?/rdbms/admin/utlxpls



select ROWNUM from clients order by DBMS_RANDOM.VALUE;

-------

INSERT INTO clients SELECT '79104123456', standard_hash(Rownum, 'MD5') FROM dual Connect By Rownum <= 300000 order by DBMS_RANDOM.VALUE;
INSERT INTO clients SELECT concat('00000' , lpad(Rownum, 6, '0')), standard_hash(Rownum, 'MD5') FROM dual Connect By Rownum <= 50000 order by DBMS_RANDOM.VALUE;

CREATE TABLE new_clients as SELECT * FROM clients ORDER BY DBMS_RANDOM.VALUE;

CREATE INDEX new_clients_phone_idx ON new_clients (phone);



set autotrace trace;
EXEC DBMS_STATS.delete_database_stats;
EXEC DBMS_STATS.delete_dictionary_stats;

