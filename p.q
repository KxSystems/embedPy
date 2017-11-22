.p:(`:./p 2:`lib,1)`
\d .p
e:{x[0;y];}runs /"run" a string, x, as though it were the contents of a file.
.p.eval:runs[1;]
/ in general if 2 functions pyXXX and XXX, XXX will attempt to convert through py2q, in the case of callables this applies to the functions they return
/ compose list of functions
k)c:{'[y;x]}/|:
/ compose with enlist (for composition trick used for 'variadic functions')
k)ce:{'[y;x]}/enlist,|:
py2q:{$[112=type x;conv[first .p.type x];]x}     / convert to q using best guess of type
q2pyc:q2py / keep so people can test conversions with .p.q2pyc[something;conversiondict]
q2py:{q2pyc[x;topy]}
/ aliases
{x set y}'[`.p.attr`arraydims;getattr,getarraydims];
pyattr:.p.attr;
.p.attr:c `.p.py2q,pyattr;
pyeval:.p.eval                    / eval and return foreign
.p.eval:c `.p.py2q,pyeval         / eval and convert to q
/ calling functions and instantiation of classes with default and named parameters
/ in q can only have variadic functions with the composition with enlist trick
/ we want to be able to call python function like this func[posarg1;posarg2;...;namedargs]
/ use .p.pycallable[python function as foreign] to get such a function 
/ use .p.callable[python function as foreign] to get a function which converts the result to q
pycallable:{if[not 112=type x;'`type];ce .[.p.call x],`.p.q2pargs}
callable:{c`.p.py2q,pycallable x}

imp:{pyattr[import x;y]}             / import name x and give me x.y as foreign
/pyattr                              / if x is a foreign then pyattr[x;y] gives x.y as foreign
callable_imp:c callable,imp          / import name y from name x and make it callable returning q
callable_attr:c callable,pyattr      / x.y from foreign x, name y and make it callable returning q
pycallable_imp:c pycallable,imp      / import name y from name x and make it callable returning foreign
pycallable_attr:c pycallable,pyattr  / x.y from foreign x, name y and make it callable returning foreign

dict:{({$[all 10=type@'x;`$;]x}py2q .p.key x)!py2q .p.value x}
scalar:callable .p.pyeval"lambda x:x.tolist()"
/ conv is dict from type to conversion function
conv:neg[1 3 7 9 21 30h]!getb,getnone,getj,getf,repr,scalar
conv[4 10 30 41 42 99h]:getG,getC,{d#x[z;0]1*/d:y z}[getarray;getarraydims],(2#(py2q each getseq@)),dict
.P.runs:0 /open the P namespace - keep the c-api in .P.    uses up a valuable namespace?
(Pp:{@[`.P;x;:;.p x];![`.p;();0b;x];})`getseq`getb`getnone`getj`getf`getG`getC`getarraydims`getattr`getarray`getbuffer`dict`scalar`ntolist`runs
uni:{x enlist .P.G2py"x"$y}call[pyeval"lambda x:x.decode('utf-8')";;()!()];
.P.topy:(neg[1 4 5 6 7h]!5#(j2py"j"$)),(neg[8 9h]!2#(f2py"f"$)),(4 -10 10 11 -11h!G2py,{uni 1#x},uni,{uni@'string x},{uni string x}),0 99 100 101h!(fs2py q2py@'),dict2py,lambda2py,null2py
.P.topy[1 2 4 5 6 7 8 9h]:a2py
Pp`j2py`f2py`null2py`G2py`a2py`fs2py`lambda2py`rr2py
topy:(0#0h)!() / defaults done in c, TODO temporal types here or in c
/ now pyutils stuff
/ python list (q2py gives tuple by default on vectors
pylist:pycallable_imp[`builtins;`list]

/ passed a variable length list of args, find identified key word args, positional arg lists and key word arg dicts and produce arg list and kew word arg list
/ the rules ... 
/ all positionals (including pyarglist) before any key words (including pykwargs)
/ (kwargs always last if it exists)
/ e.g.
/ p)def foo(a,b,c=None,d=3):print(a,b,c,d);return(a,b,c,d)
/ q)foo:.p.callable .p.get`foo
/ q)foo[1;2;3;4]                             / foo called with defaults all positional args
/ q)foo[]                                    / foo called with defaults for a,b,c,d (error as python foo doesn't have defaults)
/ q)foo[1;2]                                 / foo called with defaults for c,d
/ q)foo[1;`b pykw 1;`d pykw 2;`c pykw 3]     / foo called with a=1,b=1,c=3,d=3
/ q)foo[1;pyarglist 3 2;pykwargs (1#`d)!1#1] / foo called with a=1,b=3,c=2,d=1
q2pargs:{
 / for zero arg callables
 if[x~enlist(::);:(();()!())];
 hd:(k:i.gpykwargs x)0; 
 al:neg[hd]_(a:i.gpyargs x)0;
 / we check order as we're messing with it before passing to python and it won't be able to
 if[any 1_prev[u]and not u:`..pykw~'first each neg[hd]_x;'"positional argument follows keyword argument"];
 cn:{$[()~x;x;11h<>type x;'`type;x~distinct x;x;'`dupnames]};
 :(x[where not[al]&not u],a 1;cn[named[;1],key k 1]!(named:(x,(::))where u)[;2],value k 1)
 }

/ identify named params for python call, without it you have to do .p.pykw[`argname]argvalue which is a tad ugly
if[not`pykw in key`.q;.p.pykw:(`..pykw;;);.q.pykw:.p.pykw];                    / identify keyword args with `name pykw value
if[not`pyarglist in key`.q;.p.pyarglist:(`..pyas;);.q.pyarglist:.p.pyarglist]; / identify positional arg list (*args in python)
if[not`pykwargs in key`.q;.p.pykwargs:(`..pyks;);.q.pykwargs:.p.pykwargs];     / identify keyword dict **kwargs in python

i.gpykwargs:{dd:(0#`)!();
 $[not any u:`..pyks~'first each x;(0;dd);not last u;'"pykwargs may only be last";
  1<sum u;'"only one pykwargs allowed";(1;dd,x[where u;1]0)]}
i.gpyargs:{$[not any u:`..pyas~'first each x;(u;());1<sum u;'"only one pyargs allowed";(u;(),x[where u;1]0)]}

/ dict from an object (TODO name suggestions, currently obj2dict)
/ produce a dictionary structure with callable methods and accessors for properties and data members
/ a problem is we cannot directly inspect an instance (using python inspect module) if it
/ has properties as the property getter may not succeed, an example from keras is the regularizers
/ property of a model can't be accessed before the model is built. In any case we need to go through the property
/ getter in python each time in order to be consistent with python behaviour.
/ This solution finds all methods,data and properties of the *class* of an instance using inspect module
/ and creates pycallables for each taking 0 or 2 args for data and properties and the usual variadic behaviour for methods or functions
/ Can get and set properties
/ e.g. for properties
/ q)Sequential:.p.pycallable_imp[`keras.models]`Sequential 
/ q)model:.p.obj2dict Sequential[]
/ / property params
/ / syntax for property and data params is a bit odd but we can at least do
/ / instance.propertyname[] / get the value
/ / instance.propertyname[:;newval] / set the value to newval
/ q)model.trainable[]        / returns foreign
/ / since we know model.trainable returns something convertible to q it's handier to overwrite the default behaviour to return q data
/ q)model.trainable:.p.c .p.py2q,model.trainable
/ q)model.trainable[]
/ 1b
/ q)model.trainable[:;0b]    / set it to false
/ q)model.trainable[]        / see the result
/ 0b

/ make a q dict from a class instance
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
 res,:mn!pycallable_attr[x]each mn; / {pycallable attr[x]y}[x]each mn;
 / properties and data have to be accessed with [] (in case updated, TODO maybe not for data)
 bf:{[x;y]ce .[i.paccess[x;y]],`.p.i.pparams};
 /:res,dpn!{{[o;n;d]$[d~(::);atr[o]n}[x;y]}[x]each dpn;
 :res,dpn!{[o;n]ce .[`.p.i.paccess[o;n]],`.p.i.pparams}[x]each dpn;
 }

/ class content info helpers
i.ccattrs:pycallable_imp[`inspect]`classify_class_attrs
i.anames:{[f;x;y]`${x where not x like"_*"}f[x;y]}callable .p.pyeval"lambda xlist,y: [xi.name for xi in xlist if xi.kind in y]"
i.pparams:{`.property_access;2#x}
i.setattr:pycallable_imp[`builtins;`setattr]; / maybe should be in c? TODO maybe available in Jacks now 
i.paccess:{[ob;n;op;v]$[op~(:);i.setattr[ob;n;v];:pyattr[ob]n];}

/ used internally by help and print functions
help4py:{pycallable_imp[`builtins;`help]x;}
helpstr4py:{callable_imp[`inspect;`getdoc]x} / cleaned docstring
printpy:{x y;}pycallable_imp[`builtins;`print]

/ help function
/ help displays python help on any of these
/ q)Sequential:.p.pycallable_imp[`keras.models]`Sequential
/ / foreign objects e.g.
/ q)help Sequential[]
/ / a pycallable e.g.
/ q)help Sequential
/ wrapped python class instances returned from .p.pycallable_* e.g.
/ q)model:.p.obj2dict Sequential[]
/ q)help model
/ properties accessors e.g.
/ q)help model.trainable
/ methods in wrapped classes e.g.
/ q)help model.add

help:{
 $[112=type x;
   :help4py x;
  105=type x; /might be a pycallable
   $[last[u:get x]~ce 1#`.p.q2pargs;
     :.z.s last get last get first u;
    any u[0]~/:`.p.py2q,py2q; / callable or some other composition with .p.py2q or `.p.py2q as final function
     :.z.s last u;
    105=type last u; / might be property setter
     if[last[u]~ce 1#`.p.i.pparams;:.z.s x[]];
    ];
  99=type x; / might be wrapped class
   if[11h=type key x;:.z.s x`$"_pyobj"]; / doesn't matter if not there
   ];"no help available"}
/ this version *returns* the help string for display on remote clients
helpstr:{
 $[112=type x;
   :helpstr4py x;
  105=type x; /might be a pycallable 
   $[last[u:get x]~ce 1#`.p.q2pargs;
     :.z.s last get last get first u;
    any u[0]~/:`.p.py2q,py2q; / callable or some other composition with .p.py2q or `.p.py2q as final function
     :.z.s last u; 
    105=type last u; / might be property setter
     if[last[u]~ce 1#`.p.i.pparams;:.z.s x[]]; 
    ]; 
  99=type x; / might be wrapped class
   if[11h=type key x;:.z.s x`$"_pyobj"]; / doesn't matter if not there 
   ];""}

/comment if you do not want print or help defined in your top level directory
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
i.partial:pycallable_imp[`functools]`partial;
/ should be in it's own module
i.qclosure:pycallable .p.get`qclosure; 
i.qprojection:pycallable .p.get`qprojection; 
/ returns a python generator function from q 'closure' x and argument y where y is the
/ number of times the generator will be called
qgenfunc:{pycallable[i.partial[i.gl;`clsr pykw i.qclosure$[104=type x;get x;'`shouldbeprojection]]]y}
qgenfuncinf:{pycallable[i.partial[i.gli;`clsr pykw i.qclosure$[104=type x;get x;'`shouldbeprojection]]]0}
/ examples
/ q)pysum:.p.callable_imp[`builtins;`sum]
/ / sum of first N ints using python generators
/ q)pysum .p.qgenfunc[.p.i.gftil;10]
/ 55
/ q)sum 1+til 10
/ 55
/ / sum of factorials of first N numbers
/ q)pysum .p.qgenfunc[.p.i.gffact;10]
/ 4037913
/ q)sum {prd 1+til x}each 1+til 10

\

