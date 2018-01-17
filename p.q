if[system["s"]|0>system"p";'"slaves or multithreaded input not currently supported"];
.p:(`:./p 2:`lib,1)`
\d .p
k)c:{'[y;x]}/|:         / compose list of functions
k)ce:{'[y;x]}/enlist,|: / compose with enlist (for variadic functions)

/ Aliases
set'[`pykey`pyvalue`pyget`pyeval`pyimport;.p.key,.p.value,.p.get,.p.eval,import];
qeval:c`.p.py2q,pyeval

/ Wrapper for foreigns
embedPy:{[f;x]         
 $[-11h<>t:type x0:x 0;
    $[t=102h;
      $[any u:x0~/:(*;<;>);
         [c:(wrap;py2q;::)where[u]0;$[1=count x;.p.c c,;c .[;1_x]@]pyfunc f]; / call type
        (:)~x0;[setattr . f,@[;0;{`$_[":"=s 0]s:string x}]1_x;];
        (@)~x0;$[count 2_x;.[;2_x];]wrap call[getattr[f;`$"__getitem__"];raze x 1;()!()];
        (=)~x0;[call[getattr[f;`$"__setitem__"];raze 1_x;()!()];];
        ($)~x0;f;'`NYI];
      wrap pyfunc[f]. x];
    ":"~first a0:string x0;                                                / attr lookup and possible call
     $[1=count x;;.[;1_x]]wrap f getattr/` vs`$1_a0;
    x0~`.;f;x0~`;py2q f;                                                   / extract as foreign or q
     wrap pyfunc[f]. x]}                                                   / default, call
unwrap:{$[i.isw x;x`.;x]}
wfunc:{[f;x]r:wrap f x 0;$[count x:1_x;.[;x];]r}
i.wf:{[f;x]embedPy[f;x]}
wrap:ce i.wf@
import:ce wfunc pyimport
.p.eval:ce wfunc pyeval
.p.get:ce wfunc pyget
.p.set:{[f;x;y]f[x]unwrap y;}.p.set
.p.key:{wrap pykey$[i.isf x;x;i.isw x;x`.;'`type]}
.p.value:{wrap pyvalue$[i.isf x;x;i.isw x;x`.;'`type]}
.p.callable:{$[i.isw x;x;i.isf x;wrap[x];'`type]}
.p.pycallable:{$[i.isw x;x(>);i.isf x;wrap[x](>);'`type]}
.p.qcallable:{$[i.isw x;x(<);i.isf x;wrap[x](<);'`type]}
/ is foreign, wrapped, callable
i.isf:isp
i.isw:{$[105=type x;i.wf~$[104=type u:first get x;first get u;0b];0b]}
i.isc:{$[105=type y;$[x~y;1b;.z.s[x]last get y];0b]}ce 1#`.p.q2pargs
setattr:{[f;x;y;z]f[x;y;z];}import[`builtins]`:setattr

/ Calling python functions
pyfunc:{if[not i.isf x;'`type];ce .[.p.call x],`.p.q2pargs}
q2pargs:{
 if[x~enlist(::);:(();()!())]; / zero args
 hd:(k:i.gpykwargs x)0; 
 al:neg[hd]_(a:i.gpyargs x)0;
 if[any 1_prev[u]and not u:i.isarg[i.kw]each neg[hd]_x;'"keywords last"]; / check arg order
 cn:{$[()~x;x;11<>type x;'`type;x~distinct x;x;'`dupnames]};
 :(unwrap each x[where not[al]&not u],a 1;cn[named[;1],key k 1]!unwrap each(named:get'[(x,(::))where u])[;2],value k 1)
 }
.q.pykw:{x[y;z]}i.kw:(`..pykw;;;)  / identify keyword args with `name pykw value
.q.pyarglist:{x y}i.al:(`..pyas;;) / identify pos arg list (*args in python)
.q.pykwargs: {x y}i.ad:(`..pyks;;) / identify keyword dict (**kwargs in python)
i.gpykwargs:{dd:(0#`)!();
 $[not any u:i.isarg[i.ad]each x;(0;dd);not last u;'"pykwargs last";
  1<sum u;'"only one pykwargs allowed";(1;dd,get[x where[u]0]1)]}
i.gpyargs:{$[not any u:i.isarg[i.al]each x;(u;());1<sum u;'"only one pyargs allowed";(u;(),get[x where[u]0]1)]}
i.isarg:{$[104=type y;x~first get y;0b]} / y is python argument identifier x

/ Help & Print
gethelp:{[h;x]$[i.isf x;h x;i.isw x;h x`.;i.isc x;h x{get[x]y}/1 0 1 1;"no help available"]}
repr:gethelp repr
help:{[gh;h;x]if[10=type u:gh[h]x;-2 u]}[gethelp]import[`builtins;`:help]
helpstr:gethelp import[`inspect;`:getdoc;<]
print:{x y;}import[`builtins]`:print
{@[`.;x;:;get x]}each`help`print; / comment to remove from global namespace

/ Closures
p)def qclosure(func,*state):
  def cfunc(a0=None,*args):
    nonlocal state
    res=func(*state+(a0,)+args)
    state=(res[0],)
    return res[1]
  return cfunc
closure:.p.get[`qclosure] / implement as: closure[{[state;dummy] ...;(newState;result)};initState]

/ Generators
p)import itertools
i.gl:.p.eval["lambda f,n:(f(x)for x in(itertools.count()if n==None else range(n)))"][>]
generator:{[f;i;n]i.gl[closure[f;i]`.;n]}

/ Cleanup
{![`.p;();0b;x]}`getseq`ntolist`runs`wfunc`gethelp;
