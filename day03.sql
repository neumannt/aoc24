with recursive aoc3_input(i) as (select $aocinput$
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
$aocinput$),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc3_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
rawcommands(y,x,op,a,b) as (
   select y,0,'',0,0,line as r from lines
   union all
       select y, x+1, case sc when 1 then 'mul' when 2 then 'do' when 3 then 'dont' else '' end,
          case when sc=1 then substr(r,5,position(',' in r)-5)::integer else 0 end,
          case when sc=1 then substr(r,position(',' in r)+1,position(')' in r)-(position(',' in r)+1))::integer else 0 end,
          case when sc<4 then substr(r,position(')' in r)+1) else substr(r,2) end
       from (
       select case when r similar to 'mul\([0-9]*,[0-9]*\)%' then 1
                   when r like 'do()%' then 2
                   when r like 'don''t()%' then 3
                   else 4 end  as sc, y,x,op,a,b,r
       from rawcommands where r<>'') s
),
commands(x,op,a,b) as (
   select row_number() over (order by y,x), op, a, b
   from rawcommands where op<>''
),
part2(x,op,a,b) as (
   select * from commands c
   where op='mul' and
   not exists(select * from commands c2
   where c2.op='dont' and c2.x<c.x and
   not exists(select * from commands c3
   where c3.op='do' and c3.x between c2.x and c.x)
))
select (select sum(a*b) from commands) as part1,
       (select sum(a*b) from part2) as part2
