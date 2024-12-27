with recursive aoc7_input(i) as (select '
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc7_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
targets(y,target) as (
   select y, substr(line,1,position(':' in line)-1)::bigint from lines where line like '%: %'
),
arguments(y,x,v) as (
   select y, 0 as x, substr(line,1,position(' ' in line)-1)::bigint as v, substr(line,position(' ' in line)+1) as r
   from (select y, substr(line,position(': ' in line)+2) as line from lines where line like '%: %') s
   union all
   select y, x+1, case when r like '% %' then substr(r,1,position(' ' in r)-1) else r end::bigint, case when r like '% %' then substr(r,position(' ' in r)+1) else '' end
   from arguments where r<>''
),
expansions(y,x,target,c,cc) as (
   select y,0,target,v,false from targets natural join arguments where x=0
   union all
   select y,x,target,nv,cc
   from (
   select e.y,a.x as x,target,case when d=1 then c+v when d=2 then c*v else (c::text||v::text)::bigint end as nv, cc or d=3 as cc
   from expansions e, arguments a, generate_series(1,3) s(d)
   where e.y=a.y and e.x+1=a.x) s where nv<=target
),
successes(y,cc) as (
   select y,cc
   from expansions e
   where target=c
   and x=(select max(x) from arguments a where e.y=a.y)
)
select (select sum(target) from targets where y in (select y from successes where not cc)) as part1,
       (select sum(target) from targets where y in (select y from successes)) as part2
