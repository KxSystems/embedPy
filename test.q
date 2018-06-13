\l p.q
\d .t
n:ne:nf:0
pt:{-2 $[first[x]~`..err;err;fail][x;y]}
i:{` sv"  ",/:` vs x}
ge:{v:.Q.trp[x;y;{(`..err;x,"\n",.Q.sbt 1#y)}];n+:1;if[not(1b~v)|(::)~v;pt[v](y;file)]}
e:ge value;.p.e:ge .p.e
err:{ne+:1;"ERROR:\n test:\n",i[y 0]," message:\n",i[x 1]," file:\n",i y 1}
fail:{nf+:1;"FAIL:\n test:\n",i[y 0]," result:\n",i[.Q.s x]," file:\n",i y 1}
{file::x;system"l ",x}each $[count .z.x;.z.x;"tests/",/:string til`:tests];
tn:{`$(0-x=1)_"tests"}
if[ne+nf;-2" "sv string(`failed;nf;tn nf;`errored;ne;tn ne;n;`total;tn n);exit 1]
\\
