with recursive aoc23_input(i) as (select '
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
'),
lines(y,line) as (
   select 0, substr(i,1,position(E'\n' in i)-1), substr(i,position(E'\n' in i)+1)
   from aoc23_input
   union all
   select y+1,substr(r,1,position(E'\n' in r)-1), substr(r,position(E'\n' in r)+1)
   from lines l(y,l,r) where position(E'\n' in r)>0
),
rawedges(a,b) as (select substr(line, 1, position('-' in line)-1) as a, substr(line, position('-' in line)+1) as b from lines where line like '%-%'),
edges(a,b) as (select distinct a,b from (select a,b from rawedges union all select b,a from rawedges) s),
nodes(n) as (select distinct a from edges),
rawpart1(p1,p2,p3) as (select e1.a, e2.a, e3.a from edges e1, edges e2, edges e3 where e1.a like 't%' and e1.b=e2.a and e2.b=e3.a and e3.b=e1.a),
part1(p1,p2,p3) as (select distinct
   least(p1,p2,p3), case least(p1,p2,p3) when p1 then least(p2,p3) when p2 then least(p1,p3) else least(p1,p2) end, greatest(p1,p2,p3) from rawpart1),
bronkerbosch(id, v, c) as (
   select '',n,1 from nodes
   union all (
      with tmp as (select * from bronkerbosch),
         r(id, v) as (select id, v from tmp where c=0),
         p(id, v) as (select id, v from tmp where c=1),
         x(id, v) as (select id, v from tmp where c=2),
         pivotvalue(id, u) as (select id, min(v) from (select id, v from p union all select id, v from x) group by id),
         filteredp(id, v) as (select id, v from p natural join pivotvalue where v not in (select b from edges where a=u)),
         rr(id, v) as (
            select id||v, v from filteredp
            union
            select r.id||p.v, r.v from r, filteredp p where r.id=p.id
         ),
         rp(id, v) as (
            select distinct fp.id||fp.v, p.v
            from filteredp fp, p p
            where fp.id=p.id and p.v in (select b from edges where a=fp.v) and p.v>=fp.v
         ),
         rx(id, v) as (
            select distinct fp.id||fp.v, n.b
            from filteredp fp, edges n
            where fp.v=n.a and (n.b in (select v from x where x.id=fp.id) or (n.b<fp.v and n.b in (select v from filteredp fp2 where fp2.id=fp.id)))
         )
         select id, v, 0 from rr
         union all
         select id, v, 1 from rp
         union all
         select id, v, 2 from rx
   )),
cliqueids(id) as (select id from
   (select distinct id from bronkerbosch where c=0) s
   where not exists (select * from bronkerbosch b where (c=1 or c=2) and b.id=s.id)),
cliquesizes(id, c) as (select id, count(*) from bronkerbosch natural join cliqueids where c=0 group by id),
maxclique(id) as (select min(s1.id) from cliquesizes s1 where not exists(select * from cliquesizes s2 where s2.c>s1.c))
select (select count(*) from part1) as part1,
       (select string_agg(v, ',' order by v) from bronkerbosch natural join maxclique where c=0) as part2
