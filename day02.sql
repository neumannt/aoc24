with recursive aoc2_input(i) as (select '
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc2_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
input(y,x,v) as (
   select y,0, substr(line,1,position(' ' in line)-1)::integer as v, substr(line,position(' ' in line)+1) as r
   from lines where line like '% %'
   union all
   select y,x+1, case when r like '% %' then substr(r,1,position(' ' in r)-1)::integer else r::integer end, case when r like '% %' then substr(r,position(' ' in r)+1) else '' end
   from input where r<>''
),
widths(y,w) as (select y,max(x) from input group by y),
safety(y,e) as (
   select y, e
   from (
      select y, e, sum(case when abs(d) between 1 and 3 then 0 else 1 end) as v, min(sign(d)) l, max(sign(d)) u
      from (select i.y as y, e, x, v-lag(v) over (partition by i.y, e order by x) as d
      from widths w, lateral generate_series(0,w+1) e(e), input i where w.y=i.y and i.x!=e
      ) s
      where d is not null
      group by y, e
   ) s
   where v=0 and l=u
)
select (select count(*) from widths natural join safety where e=w+1) as part1,
       (select count(*) from widths where y in (select y from safety)) as part2
