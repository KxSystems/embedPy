-1"## Memory start";
p)import resource
pmem:{show enlist .Q.w[];-1"Memory usage reported by Python: ",(string r:.p.qeval"resource.getrusage(resource.RUSAGE_SELF).ru_maxrss")," (kb)";r}
a:til 100;
.p.set[`bbb]a;
initmem:pmem[];
do[10000;.p.set[`bbb]a];
initmem=pmem[]
initmem:pmem[];
.p.set[`bbb]{.z.s,x+y};
initmem~{do[100000;.p.set[`bbb]{.z.s,x+y}];pmem[]}[]
a:.p.eval"bbb(10,11)";
initmem:pmem[];
initmem~{do[100000;.p.eval"bbb(10,11)"];pmem[]}[]
do[10000;.p.q2py 1b];
do[10000;.p.q2py(::)];
-1"## Memory end";
