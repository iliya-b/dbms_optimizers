CREATE TABLE clients (phone varchar(20), full_name varchar(50));
INSERT INTO clients SELECT concat('79104' , format(value, '000000')), CONVERT(VARCHAR(32), HashBytes('MD5', format(value, '000000')), 2) FROM GENERATE_SERIES(1, 999999);
CREATE INDEX clients_phone_idx ON clients (phone);
CREATE INDEX clients_phone_full_name_idx ON clients (phone) include (full_name);
go
set statistics time on;
SELECT * from clients where phone < '7910419099';
go
SELECT * from clients WITH (INDEX=clients_phone_idx) where phone < '7910419099';
go