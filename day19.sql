with recursive aoc19_input(i) as (select '
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc19_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
available(ap) as (
   select substr(line,1,position(', ' in line)-1) as ap, substr(line,position(', ' in line)+2) as r from lines where line like '%, %'
   union all
   select case when r like '%, %' then substr(r,1,position(', ' in r)-1) else r end, case when r like '%, %' then substr(r,position(', ' in r)+2) else '' end
   from available where r<>''
),
requested(pattern) as (select line from lines where line<>'' and line not like '%, %'),
match(pattern, step, pos, c) as (
select pattern, 1, 1, 1::bigint from requested
union all
(with tmp as (select * from match),
 agg as (select pattern, step, pos, sum(c) as c from tmp where pos>=step group by pattern, step, pos)
 select pattern, step+1, pos, c::bigint from agg where pos>step
 union all
 select pattern, step+1, pos+length(ap), c::bigint from agg, available
 where pos=step and pos+length(ap)<=length(pattern)+1 and substr(pattern, pos, length(ap))=ap)),
matched(pattern, c) as (
 select pattern,sum(c) from match where pos=length(pattern)+1 and step=pos group by pattern)
select (select count(*) from matched where c>0) as part1,
       (select sum(c) from matched) as part2
