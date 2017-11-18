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
  $[count a:1_a;.[;a];]wrapX[c;r]x}
wrap:(wrapX:{[c;r;x]ce wf[c;r;x]})[0;0]
unwrap:{$[105=type x;x`.;x]}
impo:ce{r:wrap import a:x 0;$[count x:1_x;.[;x];]r}
geto:ce{r:wrap .p.get a:x 0;$[count x:1_x;.[;x];]r}
oval:{wrap pyeval x}

/ obj2dict
/ Produce dict with callable methods and accessors for attributes/properties
obj2dict:{[x]
 if[not 112=type x;'"can only use inspection on python objects"];
 / filter class content by type (methods, data, properties)
 f:i.anames i.ccattrs pyattr[x]`$"__class__";
 mn:f("method";"class method";"static method");
 / data and classes handled identically at the moment
 dpn:f `data`property;
 / build callable method functions, these will return python objects not q ones
 / override with .p.c .p.py2q,x.methodname if you expect q convertible returns
 / keep a reference to the python object somewhere easy to access
 res:``_pyobj!((::);x);
 res,:mn!{pycallable pyattr[x]y}[x]each mn;
 / properties and data have to be accessed with [] (in case updated, TODO maybe not for data)
 bf:{[x;y]ce .[i.paccess[x;y]],`.p.i.pparams};
 /:res,dpn!{{[o;n;d]$[d~(::);atr[o]n}[x;y]}[x]each dpn;
 :res,dpn!{[o;n]ce .[`.p.i.paccess[o;n]],`.p.i.pparams}[x]each dpn;
 }
/ class content info helpers
i.ccattrs:pycallable pyattr[import`inspect;`classify_class_attrs]
i.anames:{[f;x;y]`${x where not x like"_*"}f[x;y]}callable .p.pyeval"lambda xlist,y: [xi.name for xi in xlist if xi.kind in y]"
i.pparams:{`.property_access;2#x}
i.paccess:{[ob;n;op;v]$[op~(:);setattr[ob;n;v];:pyattr[ob]n];}

/ Help & Print
gethelp:{[h;x]h$[112=0N!t:type x;x;105=t;x`.;99=t;x`$"_pyobj";:"no help available"]}
help:{[h;x]gethelp[h]x;}impo[`builtins][`help;*]
helpstr:gethelp impo[`inspect][`getdoc;<]
printpy:impo[`builtins][`print;*]
/ Comment to remove names from top level dir
@[`.;`help;:;help];
@[`.;`print;:;printpy];

/ callable class wrappers for q projections and 'closures' (see below)
/ q projections should be passed as (func;args...) to python
p)from itertools import count
/ when called in python will call the internal q projection and update the projection based on what's returned from q
p)class qclosure(object):
 def __init__(self,qfunc=None):
  self.qlist=qfunc
 def __call__(self,*args):
  res=self.qlist[0](*self.qlist[1:]+args)
  self.qlist=res[0] #update the projection
  return res[-1]
 def __getitem__(self,ind):
  return self.qlist[ind]
 def __setitem__(self,ind):
  pass
 def __delitem__(self,ind):
  pass

p)class qprojection(object):
 def __init__(self,qfunc=None):
  self.qlist=qfunc
 def __call__(self,*args):
  return self.qlist[0](*self.qlist[1:]+args)
 def __getitem__(self,ind):
  return self.qlist[ind]
 def __setitem__(self,ind):
  pass
 def __delitem__(self,ind):
  pass

/ closures don't exist really in q, however they're useful for implementing
/ python generators. we model a closure as a projection like this
// 
/ f:{[state;dummy]...;((.z.s;modified state);func result)}[initialstate]
//
/ example generator functions gftil and gffact, they should be passed to qgenf or qgenfi 
i.gftil:{[state;d](.z.s,u;u:state+1)}0 / 0,1,...,N-1
i.gffact:{[state;d]((.z.s;u);last u:prds 1 0+state)}0 1 / factorial

/ generator lambda, to be partially applied with a qclosure in python this should then be applied to an int N to give a generator which yields N times
i.gl:.p.eval"lambda genarg,clsr:[(yield clsr(x)) for x in range(genarg)]"
/ generator lambda, yields for as long as it's called
i.gli:.p.eval"lambda genarg,clsr:[(yield clsr(x)) for x in count()]"
i.partial:pycallable pyattr[import`functools;`partial]
/ should be in it's own module
i.qclosure:pycallable .p.get`qclosure; 
i.qprojection:pycallable .p.get`qprojection; 
/ returns a python generator function from q 'closure' x and argument y where y is the
/ number of times the generator will be called
qgenfunc:{pycallable[i.partial[i.gl;`clsr pykw i.qclosure$[104=type x;get x;'`shouldbeprojection]]]y}
qgenfuncinf:{pycallable[i.partial[i.gli;`clsr pykw i.qclosure$[104=type x;get x;'`shouldbeprojection]]]0}
/ examples
/ q)pysum:.p.impo[`builtins;`sum;<]
/ / sum of first N ints using python generators
/ q)pysum .p.qgenfunc[.p.i.gftil;10]
/ 55
/ q)sum 1+til 10
/ 55
/ / sum of factorials of first N numbers
/ q)pysum .p.qgenfunc[.p.i.gffact;10]
/ 4037913
/ q)sum {prd 1+til x}each 1+til 10
