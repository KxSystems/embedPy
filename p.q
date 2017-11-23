.p:(`:./p 2:`lib,1)`
\d .p
e:{x[0]y;}runs
.p.eval:runs 1

k)c:{'[y;x]}/|:         / compose list of functions
k)ce:{'[y;x]}/enlist,|: / compose with enlist (for variadic functions)

/ Aliases
set'[`pykey`pyvalue`pyget`pyeval`pyimport`arraydims;.p.key,.p.value,.p.get,.p.eval,import,getarraydims];
qeval:c`.p.py2q,pyeval

/ Wrapper for foreigns
wf:{[c;r;x;a] / r (0 wrapped, 1 q, 2 foreign)
  if[c;:(wrap;py2q;::)[r].[pycallable x]a];
  $[`.~a0:a 0;:x;`~a0;:py2q x;-11=type a0;x:x getattr/` vs a0;
  (:)~a0;[setattr . x,1_a;:(::)];
  [c:1;r:$[(*)~a0;0;(<)~a0;1;(>)~a0;2;'`NYI]]];
  $[count a:1_a;.[;a];]w[c;r]x}
wrap:(w:{[c;r;x]ce wf[c;r;x]})[0;0]
unwrap:{$[105=type x;x`.;x]}
wfunc:{[f;x]r:wrap f x 0;$[count x:1_x;.[;x];]r}
import:ce wfunc pyimport
.p.eval:ce wfunc pyeval
.p.get:ce wfunc pyget
.p.set:{[f;x;y]f[x]unwrap y;}.p.set
.p.key:{wrap pykey x`.}
.p.value:{wrap pyvalue x`.}
setattr:{[f;x;y;z]f[x;y;z];}import[`builtins;`setattr;*]

/ Converting python to q
py2q:{$[112=type x;conv .p.type[x]0;]x} / convert to q using best guess of type
dict:{({$[all 10=type@'x;`$;]x}py2q pykey x)!py2q pyvalue x}
scalar:.p.eval["lambda x:x.tolist()";<]
/ conv: type -> convfunction
conv:neg[1 3 7 9 21 30h]!getb,getnone,getj,getf,repr,scalar
conv[4 10 30 41 42 99h]:getG,getC,{d#x[z;0]1*/d:y z}[getarray;getarraydims],(2#(py2q each getseq@)),dict

/ Cleanup
{![`.p;();0b;x]}`getseq`getb`getnone`getj`getf`getG`getC`getarraydims`getarray`getbuffer`dict`scalar`ntolist`runs;

/ Calling python functions
pycallable:{if[not 112=type x;'`type];ce .[.p.call x],`.p.q2pargs}
q2pargs:{
 if[x~enlist(::);:(();()!())]; / zero args
 hd:(k:i.gpykwargs x)0; 
 al:neg[hd]_(a:i.gpyargs x)0;
 if[any 1_prev[u]and not u:`..pykw~'first each neg[hd]_x;'"keywords last"]; / check arg order
 cn:{$[()~x;x;11<>type x;'`type;x~distinct x;x;'`dupnames]};
 :(unwrap each x[where not[al]&not u],a 1;cn[named[;1],key k 1]!(unwrap each named:(x,(::))where u)[;2],value k 1)
 }
if[not`pykw      in key`.q;.p.pykw:     (`..pykw;;);.q.pykw:.p.pykw]           / identify keyword args with `name pykw value
if[not`pyarglist in key`.q;.p.pyarglist:(`..pyas;) ;.q.pyarglist:.p.pyarglist] / identify pos arg list (*args in python)
if[not`pykwargs  in key`.q;.p.pykwargs: (`..pyks;) ;.q.pykwargs:.p.pykwargs]   / identify keyword dict (**kwargs in python)
i.gpykwargs:{dd:(0#`)!();
 $[not any u:`..pyks~'first each x;(0;dd);not last u;'"pykwargs last";
  1<sum u;'"only one pykwargs allowed";(1;dd,x[where u;1]0)]}
i.gpyargs:{$[not any u:`..pyas~'first each x;(u;());1<sum u;'"only one pyargs allowed";(u;(),x[where u;1]0)]}

/ Help & Print
gethelp:{[h;x]h$[112=t:type x;x;105=t;x`.;:"no help available"]}
repr:gethelp repr
help:{[h;x]gethelp[h]x;}import[`builtins;`help;*]
helpstr:gethelp import[`inspect;`getdoc;<]
print:{x y;}import[`builtins;`print;*]
{@[`.;x;:;get x]}each`help`print; / comment to remove from global namespace

/ Closures
p)def qclosure(func,*state):
  def cfunc(a0=None,*args):
    nonlocal state
    res=func(*state+(a0,)+args)
    state=(res[0],)
    return res[1]
  return cfunc
closure:.p.get[`qclosure;*] / implement as: closure[{[state;dummy] ...;(newState;result)};initState]

/ Generators
p)import itertools
gl:.p.eval["lambda f,n:(f(x)for x in(itertools.count()if n==None else range(n)))"][>]
generator:{[f;i;n]gl[closure[f;i]`.;n]}
