/ memory tests
-1"## Memory tests start";
p)import resource
pmem:{show enlist .Q.w[];-1"Memory usage reported by Python: ",(string r:.p.eval"resource.getrusage(resource.RUSAGE_SELF).ru_maxrss")," (kb)";r}
a:til 100;
.p.set[`bbb]a;
initmem:pmem[];
initmem~{do[10000;.p.set[`bbb]a];pmem[]}[]
initmem:pmem[];
.p.set[`bbb]{.z.s,x+y};
initmem~{do[100000;.p.set[`bbb]{.z.s,x+y}];pmem[]}[]
a:.p.eval"bbb(10,11)";
initmem:pmem[];
initmem~{do[100000;.p.eval"bbb(10,11)"];pmem[]}[]
/ set then getXXX and check ref counts
rc:.p.callable_imp[`sys;`getrefcount]
rccheck:{.p.set[`bbb]x;u:.p.get[`bbb];rcinit:rc u;.p.py2q u;rcinit~rc u}
rccheck rand 01b
rccheck .p.pyeval"None"
rccheck rand 0Wj
rccheck rand 0Wi
rccheck rand 0Wh
rccheck rand 0x00
rccheck rand 0n
rccheck rand 0Ne
rccheck 10?0x00
rccheck 10?" "
rccheck rand `6
rccheck 1 2 3
rccheck 2 3 4#til 24
rccheck `a`b`c!(`a`b!1 2;3;4)
rccheck 10#enlist`a`b`c!(`a;1;2)
rccheck .p.pyeval"[1,2,3]"
rccheck .p.pyeval"(1,2,3)"




-1"## Memory tests end";


