\l p.q
\d .matplotlib
isroutine:.p.imp[`inspect;`isroutine];
getmembers:.p.callable_imp[`inspect;`getmembers];
wrapm:{[x]
 names:getmembers[x;isroutine];
 res:``_pyobj!((::);x);
 res,:(`$names[;0])!{.p.pycallable y 1}[x]each names;
 res}
pyplot:{wrapm .p.import`matplotlib.pyplot}

\d .


