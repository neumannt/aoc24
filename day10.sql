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
