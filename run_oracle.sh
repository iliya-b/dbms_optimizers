docker run --name oracle_dbms \
-p 1521:1521 -p 5500:5500 \
-e ORACLE_PWD=test \
oracle/database:21.3.0-xe