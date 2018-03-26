\l p.q
.t.n:0
.t.e:{v:@[value;x;0b];if[not (1b~v)|(::)~v;-1 x;.t.n+:1]}
system each "l ",/:$[count .z.x;.z.x;"tests/",/:string til`:tests];
if[.t.n;-2"failed ",string[.t.n]," ",(neg .t.n=1)_"tests";exit 1]
\\
