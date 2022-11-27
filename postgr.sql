-- С помощью скрипта показываем:
-- как читать вывод команды EXPLAIN на примере postgreSQL, см. https://www.postgresql.org/docs/current/using-explain.html
-- как влиять на оптимизатор с помощью настроек, см. https://www.postgresql.org/docs/current/runtime-config-query.html
-- Зачем нужен GEQO и как ведет себя оптимизатор при большом количестве таблиц в запросе 

CREATE TABLE clients (phone text, full_name text);
INSERT INTO clients
  SELECT ('79104' || LPAD(i::text, 6, '0')), md5(random()::text)
  FROM generate_series(1, 999999) AS i;

-- поиск без индекса
EXPLAIN SELECT * from clients where phone < '7910419099';

CREATE INDEX ON clients (phone);

-- поиск с индексом
EXPLAIN SELECT * from clients where phone < '7910419099';

-- forced поиск с индексом
set enable_seqscan=false;
EXPLAIN SELECT * from clients where phone < '7910499099';

CREATE INDEX ON clients (phone) INCLUDE (full_name);

-- поиск с индексом, включающим неключевые колонки
EXPLAIN SELECT * from clients where phone < '7910419099';


-- таблица заказов
CREATE TABLE orders (phone text, time timestamp);
INSERT INTO orders
  SELECT ('79104' || LPAD(i::text, 6, '0')), now() - interval '10 year' + (interval '5 minutes') * i
  FROM generate_series(1, 499999) AS i;

set enable_parallel_hash = false;
explain select * from clients, orders where clients.phone < '7910400099' and clients.phone=orders.phone;

--  Gather  (cost=6472.16..19181.89 rows=65465 width=65)
--    Workers Planned: 2
--    ->  Parallel Hash Join  (cost=5472.16..11635.39 rows=27277 width=65)
--          Hash Cond: (orders.phone = clients.phone)
--          ->  Parallel Seq Scan on orders  (cost=0.00..5268.33 rows=208333 width=20)
--          ->  Parallel Hash  (cost=4900.63..4900.63 rows=45722 width=45)
--                ->  Parallel Index Only Scan using clients_phone_full_name_idx on clients  (cost=0.42..4900.63 rows=45722 width=45)
--                      Index Cond: (phone < '7910419099'::text)


-- создаем 11 таблиц с техническими логами
drop table if exists log1,log2,log3,log4,log5,log6,log7,log8,log9,log10,log11;

CREATE TABLE log1 (phone text, message text, time timestamp);
INSERT INTO log1
  SELECT ('79104' || LPAD(i::text, 6, '0')), md5(random()::text), now() - interval '10 year' + (interval '5 seconds') * i
  FROM generate_series(100, 200) AS i;

create table log2 as select * from log1;
create table log3 as select * from log1;
create table log4 as select * from log1;
create table log5 as select * from log1;
create table log6 as select * from log1;
create table log7 as select * from log1;
create table log8 as select * from log1;
create table log9 as select * from log1;
create table log10 as select * from log1;
create table log11 as select * from log1;

-- 

set geqo=false
explain analyze select full_name, log1 from clients, log1, log2,log3,log4,log5,log6,log7,log8,log9,log10,log11  where clients.phone < '7910400099' and clients.phone=log1.phone and clients.phone=log2.phone and clients.phone=log3.phone and clients.phone=log4.phone and clients.phone=log5.phone and clients.phone=log6.phone and clients.phone=log7.phone and clients.phone=log8.phone and clients.phone=log9.phone and clients.phone=log10.phone and clients.phone=log11.phone;
--  Planning Time: 1638.210 ms
--  Execution Time: 2.135 ms

set geqo=true
explain analyze select full_name, log1 from clients, log1, log2,log3,log4,log5,log6,log7,log8,log9,log10,log11  where clients.phone < '7910400099' and clients.phone=log1.phone and clients.phone=log2.phone and clients.phone=log3.phone and clients.phone=log4.phone and clients.phone=log5.phone and clients.phone=log6.phone and clients.phone=log7.phone and clients.phone=log8.phone and clients.phone=log9.phone and clients.phone=log10.phone and clients.phone=log11.phone;
--  Planning Time: 53.225 ms
--  Execution Time: 2.477 ms