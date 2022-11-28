CREATE TABLE clients (phone varchar(20), full_name varchar(50));
INSERT INTO clients SELECT concat('79104' , lpad(Rownum, 6, '0')), standard_hash(Rownum, 'MD5') FROM dual Connect By Rownum <= 999999 order by DBMS_RANDOM.VALUE;
CREATE INDEX clients_phone_idx ON clients (phone);
CREATE INDEX clients_phone_full_name_idx ON clients (phone, full_name);

EXEC DBMS_STATS.delete_database_stats;
explain plan for select full_name from clients where phone < '79104900999' order by phone DESC;
--or full_name like '%5%';

@?/rdbms/admin/utlxpls

select ROWNUM from clients order by DBMS_RANDOM.VALUE;