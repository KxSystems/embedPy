/ memory tests
-1"## Memory tests start";
p)import resource
pmem:{show enlist .Q.w[];-1"Memory usage reported by Python: ",(string r:.p.eval"resource.getrusage(resource.RUSAGE_SELF).ru_maxrss")," (kb)";r}
a:til 100;
.p.set[`bbb]a;
initmem:pmem[];
do[10000;.p.set[`bbb]a];
initmem=pmem[]
-1"## Memory tests end";


