/ test python calling q
-1"## python calls q start";
p)1
.p.set[`bbb]{x+y};
.p.eval"22==bbb(12,10)"
.p.set[`ccc]{x,x+y}
1 2~.p.eval"ccc(1,1)"
.p.set[`ddd]{.z.s,x+y}
3~last .p.eval"ddd(1,2)"
-1"## python calls q end";
