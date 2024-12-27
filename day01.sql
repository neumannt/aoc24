with recursive aoc1_input(i) as (select '
3   4
4   3
2   5
1   3
3   9
3   3
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc1_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
input(a,b) as (
   select substr(line,1,position(' ' in line))::integer as a, ltrim(substr(line,position(' ' in line)))::integer as b
   from lines where line<>''
),
part1(v) as (
   select sum(abs(a-b))
   from (select a, row_number() over (order by a) as r1 from input) s1,
        (select b, row_number() over (order by b) as r2 from input) s2
   where r1=r2
),
part2(v) as (
   select sum(a*bf)
   from (select a from input) a,
        (select b, count(*) as bf from input group by b) b
   where a=b
)
select (select v from part1) as part1,
       (select v from part2) as part2
