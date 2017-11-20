.p:(`:./p 2:`lib,1)`
\d .p
e:{x[0;y];}runs /"run" a string, x, as though it were the contents of a file.
.p.eval:runs[1;]

k)c:{'[y;x]}/|:         / compose list of functions
k)ce:{'[y;x]}/enlist,|: / compose with enlist (for variadic functions)

/ Aliases
set'[`pyeval`pyattr`arraydims;.p.eval,getattr,getarraydims];
.p.attr:c`.p.py2q,pyattr;
.p.eval:c`.p.py2q,pyeval;

pycallable:{if[not 112=type x;'`type];ce .[.p.call x],`.p.q2pargs}
callable:{c`.p.py2q,pycallable x}

setattr:pycallable pyattr[import`builtins;`setattr]

/ Converting python to q
py2q:{$[112=type x;conv .p.type[x]0;]x} / convert to q using best guess of type
dict:{({$[all 10=type@'x;`$;]x}py2q .p.key x)!py2q .p.value x}
scalar:callable .p.pyeval"lambda x:x.tolist()"
/ conv is dict from type to conversion function
conv:neg[1 3 7 9 21 30h]!getb,getnone,getj,getf,repr,scalar
conv[4 10 30 41 42 99h]:getG,getC,{d#x[z;0]1*/d:y z}[getarray;getarraydims],(2#(py2q each getseq@)),dict

/ Cleanup
{![`.p;();0b;x]}`getseq`getb`getnone`getj`getf`getG`getC`getarraydims`getattr`getarray`getbuffer`dict`scalar`ntolist`runs;

/ Calling python functions
q2pargs:{
 / for zero arg callables
 if[x~enlist(::);:(();()!())];
 hd:(k:i.gpykwargs x)0; 
 al:neg[hd]_(a:i.gpyargs x)0;
 / we check order as we're messing with it before passing to python and it won't be able to
 if[any 1_prev[u]and not u:`..pykw~'first each neg[hd]_x;'"positional argument follows keyword argument"];
 cn:{$[()~x;x;11h<>type x;'`type;x~distinct x;x;'`dupnames]};
 :(unwrap each x[where not[al]&not u],a 1;cn[named[;1],key k 1]!(unwrap each named:(x,(::))where u)[;2],value k 1)
 }
/ identify named params for python call, without it you have to do .p.pykw[`argname]argvalue which is a tad ugly
if[not`pykw in key`.q;.p.pykw:(`..pykw;;);.q.pykw:.p.pykw];                    / identify keyword args with `name pykw value
if[not`pyarglist in key`.q;.p.pyarglist:(`..pyas;);.q.pyarglist:.p.pyarglist]; / identify positional arg list (*args in python)
if[not`pykwargs in key`.q;.p.pykwargs:(`..pyks;);.q.pykwargs:.p.pykwargs];     / identify keyword dict **kwargs in python
i.gpykwargs:{dd:(0#`)!();
 $[not any u:`..pyks~'first each x;(0;dd);not last u;'"pykwargs may only be last";
  1<sum u;'"only one pykwargs allowed";(1;dd,x[where u;1]0)]}
i.gpyargs:{$[not any u:`..pyas~'first each x;(u;());1<sum u;'"only one pyargs allowed";(u;(),x[where u;1]0)]}

/ Wrapper for foreigns
/ r (0 wrapped, 1 q, 2 foreign)
wf:{[c;r;x;a]
  if[c;:(wrap;py2q;::)[r].[pycallable x]a];
  $[`.~a0:a 0;:x;`~a0;:py2q x;-11=type a0;x:x pyattr/` vs a0;
  (:)~a0;[setattr . x,1_a;:(::)];
  [c:1;r:$[(*)~a0;0;(<)~a0;1;(>)~a0;2;'`NYI]]];
  $[count a:1_a;.[;a];]w[c;r]x}
wrap:(w:{[c;r;x]ce wf[c;r;x]})[0;0]
unwrap:{$[105=type x;x`.;x]}
impo:ce{r:wrap import a:x 0;$[count x:1_x;.[;x];]r}
geto:ce{r:wrap .p.get a:x 0;$[count x:1_x;.[;x];]r}
oval:{wrap pyeval x}

/ Help & Print
gethelp:{[h;x]h$[112=0N!t:type x;x;105=t;x`.;:"no help available"]}
help:{[h;x]gethelp[h]x;}impo[`builtins;`help;*]
helpstr:gethelp impo[`inspect;`getdoc;<]
print:{x y;}impo[`builtins;`print;*]
{@[`.;x;:;get x]}each`help`print; / comment to remove from global namespace

/ Closures
p)def qclosure(func,*state):
  def cfunc(*args):
    nonlocal state
    res=func(*state+args)
    state=(res[0],)
    return res[1]
  return cfunc
qclosure:.p.geto[`qclosure;>]
/ implement 'closure' as:  qclosure[{[state;dummy] ...;(newState;result)};initState]

/ Generators
p)import itertools
gl:.p.oval["lambda f,n:(f(x)for x in(itertools.count()if n==None else range(n)))"][>]
genfunc:{[f;i;n]gl[qclosure[f;i];n]}
