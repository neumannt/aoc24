with recursive aoc14_input(i) as (select '
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc14_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
robots(x,y,dx,dy) as (
   select x::integer, y::integer, dx::integer, dy::integer
   from (select substr(l,1,position(',' in l)-1) as x, substr(l,position(',' in l)+1) as y, substr(r,1,position(',' in r)-1) as dx, substr(r,position(',' in r)+1) as dy
   from (select substr(l,position('=' in l)+1) as l, substr(r,position('=' in r)+1) as r
   from (select substr(line,1,position(' ' in line)-1) as l, substr(line,position(' ' in line)+1) as r from lines where line<>'') s) s) s),
dimensions(w,h) as (
   select case when large then 101 else 11 end as w, case when large then 103 else 7 end as h
   from (select mx>=11 or my>=7 as large from (select max(x) as mx, max(y) as my from robots) s) s
),
simulation(r,x,y,dx,dy) as (
   select 0,x,y,dx,dy from robots
   union all
   select r+1,(x+dx+w)%w, (y+dy+h)%h, dx, dy from simulation, dimensions where r<greatest(w*h,100)),
part1q(q) as (
   select q, count(*) as c from (
   select case when x<hx and y<hy then 0 when x>hx and y<hy then 1 when x<hx and y>hy then 2 when x>hx and y>hy then 3 end as q
   from simulation, (select h>>1 as hy, w>>1 as hx from dimensions) i where r=100 and (x!=hx and y!=hy)) s
   group by q),
part2c(r,q,c) as (
   select r, q, count(*) as c from (
   select r, case when x<hx and y<hy then 0 when x>hx and y<hy then 1 when x<hx and y>hy then 2 when x>hx and y>hy then 3 end as q
   from simulation, (select h>>1 as hy, w>>1 as hx from dimensions) i where (x!=hx and y!=hy)) s
   group by r, q),
part2c2(r,c) as (select r, max(c) from part2c group by r)
select (select c from part1q where q=0)*(select c from part1q where q=1)*(select c from part1q where q=2)*(select c from part1q where q=3) as part1,
       (select min(r) from part2c2 where c=(select max(c) from part2c2)) as part2
