R:@[{.p.e x;1b};"import resource";0b]
pmem:{$[R;.p.qeval"resource.getrusage(resource.RUSAGE_SELF).ru_maxrss";0]}
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
