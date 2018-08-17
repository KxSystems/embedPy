\l p.q
\d .t
n:ne:nf:ns:0
pt:{-2 $[first[x]~`..err;err;fail][x;y]}
i:{` sv"  ",/:` vs x}
ge:{if[not P;n+:1;ns+:1;:(::)];v:.Q.trp[x;y;{(`..err;x,"\n",.Q.sbt 1#y)}];n+:1;if[not(1b~v)|(::)~v;pt[v](y;file)]}
P:1;N:0;MM:0#`
requiremod:{if[0~first u:@[.p.import;x;{(0;x)}];P::0;-2"WARN: can't import: ",string[x],", remainder of ",file," skipped, error was:\n\n\t",u[1],"\n";MM,:x]}
e:ge value;.p.e:ge .p.e
err:{ne+:1;"ERROR:\n test:\n",i[y 0]," message:\n",i[x 1]," file:\n",i y 1}
fail:{nf+:1;"FAIL:\n test:\n",i[y 0]," result:\n",i[.Q.s x]," file:\n",i y 1}
{N+:1;P::1;file::x;system"l ",x}each $[count .z.x;.z.x;"tests/",/:string u@:where(u:til`:tests)like"*.t"];
msg:{", "sv{":"sv string(x;y)}'[key x;value x]}`failed`errored`skipped`total!nf,ne,ns,n;
if[(ne+nf);-2 msg;exit 1]
if[ns;-2"These modules required for tests couldn't be imported:\n\t",("\n\t"sv string distinct MM),"\n\ntry running\n\tpip install -r tests/requirements.txt\n\nor with conda\n\tconda install --file tests/requirements.txt\n";-2 msg];
\\
