create database db_0;
create database db_1;

\c db_0

create table test as select 42 as answer;

\c db_1

create table test as select 'foo' as bar;
