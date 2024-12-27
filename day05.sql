with recursive aoc5_input(i) as (select '
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc5_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
rules(b, a) as (
   select substr(line,1,position('|' in line)-1)::integer as a, substr(line,position('|' in line)+1)::integer as b
   from lines where line like '%|%'
),
updates(y,x,v) as (
   select y, 0 as x, substr(line,1,position(',' in line)-1)::integer as v, substr(line,position(',' in line)+1) as r
   from lines where line like '%,%'
   union all
   select y, x+1, case when r like '%,%' then substr(r,1,position(',' in r)-1) else r end::integer, case when r like '%,%' then substr(r,position(',' in r)+1) else '' end
   from updates where r<>''
),
violations(y) as (
   select distinct u1.y
   from updates u1, updates u2, rules r
   where u1.y=u2.y and u1.x<u2.x and r.b=u2.v and r.a=u1.v
),
correct(y,x,v) as (select * from updates where y not in (select y from violations)),
part1(v) as (
   select sum(v)
   from correct c natural join (select y, percentile_disc(0.5) WITHIN GROUP (ORDER BY x) as x from correct group by y) s
),
rawcorrected(y,step,x,v) as (
   select y,0,x,v from updates where y in (select y from violations)
   union all
   (with tmp as (select * from rawcorrected),
    rawtoswap as (select o1.y as y, o1.x as x1, o1.v as v1, o2.x as x2, o2.v as v2, row_number() over (partition by o1.y order by o1.x, o2.x) as r
               from tmp o1, tmp o2, rules r where o1.y=o2.y and o1.x<o2.x and r.b=o1.v and r.a=o2.v),
    toswap as (select y, x1, v1, x2, v2 from rawtoswap where r=1)
    select y, step+1, x, case when x=x1 then v2 when x=x2 then v1 else v end
    from tmp natural join toswap)
),
corrected(y,x,v) as (select y,x,v from rawcorrected c1 where step=(select max(step) from rawcorrected c2 where c2.y=c1.y)),
part2(v) as (
   select sum(v)
   from corrected c natural join (select y, percentile_disc(0.5) WITHIN GROUP (ORDER BY x) as x from corrected group by y) s
)
select (select v from part1) as part1,
       (select v from part2) as part2

