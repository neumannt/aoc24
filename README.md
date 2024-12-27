# Advent of Code 2024 in SQL

This is a pure SQL implementation of the Advent of Code 2024.
All queries were tested on [Umbra](https://www.umbra-db.com) v0.2-957,
[PostgreSQL](https://www.postgresql.org/) 17.2, and [DuckDB](https://duckdb.org/) v1.1.3.

## Usage

Each day is a self-contained SQL file that contains both the puzzle input and the
query text to compute the answert. The files currently hold the (small) reference
inputs provided by the puzzles. To solve the real challenge, replace the reference
input with the inidividual puzeel input. For example the query from day 11 is:

```sql
with recursive aoc10_input(i) as (select '
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc10_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
field(x,y,v) as (
   select x,y,ascii(substr(line,x::integer,1))-48
   from (select * from lines l where line<>'') s, lateral generate_series(1,length(line)) g(x)
),
paths(x,y,v,sx,sy) as (
   select x,y,9,x,y from field where v = 9
   union all
   select f.x,f.y,f.v,p.sx,p.sy
   from field f, paths p
   where f.v=p.v-1 and ((f.x=p.x and abs(f.y-p.y)=1) or (f.y=p.y and abs(f.x-p.x)=1)) and p.v>0),
results as (select * from paths where v=0),
part1 as (select distinct * from results)
select (select count(*) from part1)  as part1, (select count(*) from results) as part2;
```

Replace lines 2-9 with your individual input to solve the general case.

## Comments on Individual Days

Nearly all solutions are reasonably fast, at least when executed in Umbra, with runtimes
of at most a few seconds. The other systems can usually solve the reference input, but
sometimes struggle with the full input, exhibiting very high response times. For two days
Umbra requires a system with a lot of main memory, and execution takes a few minutes.
The problematic cases are listed below, "slow" usually means "it took longer than I was willing
to wait".

- day 5 is slow in Postgres and DuckDB.
- day 6 needs a machine with ca. 80GB of main memory for Umbra, and produces an internal error in DuckDB.
- day 9 is slow in Postgres and DuckDB.
- day 14 is slow in DuckDB.
- day 15 is slow in DuckDB even for the reference input.
- day 16 needs a machine with ca. 240GB of main memory for Umbra, and runs for 2 minutes. It is slow in Postgres and DuckDB.
- day 17 is not supported by DuckDB due to a missing xor operator.
- day 20 is slow in DuckDB.
- day 22 is not supported by DuckDB due to a missing xor operator.
- day 23 is slow in Postgres.
- day 24 is not supported by DuckDB due to a missing xor operator.
- day 25 is slow in Postgres.
