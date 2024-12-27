with recursive aoc18_input(i) as (select '
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc18_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
bytes(bx,by,bt) as (
   select substr(line, 1, position(',' in line)-1)::smallint as x, substr(line, position(',' in line)+1)::smallint as y, y as t from lines where line like '%,%'
),
config(width, height, part1limit) as (select w, w, case when w>7 then 1024 else 12 end from (select case when (select max(bx) from bytes)>=7 then 71 else 7 end as w)),
directions(dx,dy) as (values(1::smallint,0::smallint),(0::smallint,1::smallint),(-1::smallint,0::smallint),(0::smallint,-1::smallint)),
flood(x,y,step,l) as (
   select 0::smallint,0::smallint,0::smallint,(width*height+5)::smallint from config
   union all
   select nx, ny, (step+1)::smallint, max(nl)::smallint from (
   select x+dx as nx,y+dy as ny,step, least(l,bt) as nl from
   (flood cross join directions) left join bytes on x+dx=bx and y+dy=by, config
   where x+dx>=0 and y+dy>=0 and x+dx<width and y+dy<height and step<=width*height
   ) s group by nx,ny,step
),
part2(s) as (select max(l) from flood, config where x=width-1 and y=height-1)
select
   (select min(step) from flood, config where x=width-1 and y=height-1 and l>part1limit) as part1,
   (select bx||','||by from bytes, part2 where bt=s) as part2
