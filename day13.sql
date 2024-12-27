with recursive aoc13_input(i) as (select '
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc13_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
parsed(line,x,y) as (
   select line, x::bigint, y::bigint
   from (select line, substr(b,4,position(',' in b)-4) as x, substr(b,position(',' in b)+4) as y
         from (select y as line, substr(i, position(':' in i)+1) as b from lines l(y,i) where i like '%:%') s)
),
problems(ax,ay,bx,by,tx,ty) as (
   select a.x,a.y,b.x,b.y,c.x,c.y
   from parsed a, parsed b, parsed c
   where a.line>>2=b.line>>2 and a.line>>2=c.line>>2 and a.line%4=1 and b.line%4=2 and c.line%4=3
),
expandedproblems(ax,ay,bx,by,tx,ty,part) as (
   select ax,ay,bx,by,tx,ty,1 from problems
   union all
   select ax,ay,bx,by,10000000000000+tx,10000000000000+ty,2 from problems
),
solutions(c,part) as (
   select 3*a+b, part from (
   select *, (da/det)::bigint as a, (db/det)::bigint as b from (
      select *, ax*by-bx*ay as det, tx*by-bx*ty as da, ax*ty-tx*ay as db
      from expandedproblems
   ) as s where det!=0
   ) s where a*ax+b*bx=tx and a*ay+b*by=ty and a>=0 and b>=0 and ((part>1) or ((a<=100) and (b<=100)))
)
select (select sum(c) from solutions where part=1) as part1,
       (select sum(c) from solutions where part=2) as part2
