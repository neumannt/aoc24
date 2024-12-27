with recursive aoc8_input(i) as (select '
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc8_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
rawfield(x,y,v) as (
   select x::smallint,y::smallint,substr(line,x::integer,1)
   from (select * from lines l where line<>'') s, lateral generate_series(1,length(line)) g(x)
),
field(x,y,v) as (select x,y,v from rawfield where v<>'.'),
antennacount(v,c) as (select v, count(*) from field group by v),
maxdimensions(mx,my,md) as (select max(x), max(y), greatest(max(x),max(y)) from rawfield),
part1(x,y) as (
   select distinct nx, ny
   from (select x-dx as nx,y-dy as ny
      from (select a1.x as x, a1.y as y, a2.x-a1.x as dx, a2.y-a1.y as dy
      from field a1, field a2
      where a1.v=a2.v and (a1.x<>a2.x or a1.y<>a2.y)) s
      ) s, maxdimensions m
      where nx>=1 and ny>=1 and nx<=mx and ny<=my
),
part2(x,y) as (
   select distinct nx, ny
   from (select mx, my, x-s*dx as nx,y-s*dy as ny
      from (select a1.x as x, a1.y as y, a2.x-a1.x as dx, a2.y-a1.y as dy
      from field a1, field a2
      where a1.v=a2.v and (a1.x<>a2.x or a1.y<>a2.y)) s, maxdimensions, lateral generate_series(0,md) g(s)
      ) s
      where nx>=1 and ny>=1 and nx<=mx and ny<=my
)
select (select count(*) from part1) as part1,
       (select count(*) from part2) as part2
