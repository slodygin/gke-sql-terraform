CREATE DATABASE test;
CREATE USER testuser WITH PASSWORD 'testpassword';
GRANT ALL PRIVILEGES ON DATABASE "test" to testuser;
create table test (id int);
