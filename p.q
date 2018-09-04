\d .p
if[not .P.loaded:-1h=type@[`.p@;`numpy;`];
 sc:{"'",x,"'.join([__import__('sysconfig').get_config_var(v)for v in",ssr[.j.j y;"\"";"'"],"])"};pr:{"print(",x,");"};
 c:"-c \"",pr["'.'.join([str(getattr(__import__('sys').version_info,x))for x in ['major','minor']])"],"\"2>",$[.z.o like"w*";"nul <nul";"/dev/null"];
 if[(.z.o like"w*")and `3.6>`$first@[system"python3 ",;c;{system"python ",c}];'"embedPy requires python 3.6 or higher on windows"];
 c:"-c \"",pr[$[.z.o like"w*";sc["/python";`BINDIR`VERSION],"+'.dll'";sc["/";`LIBDIR`INSTSONAME]]],pr[$[.z.o like"m*";sc["/";`PYTHONFRAMEWORKPREFIX`INSTSONAME];.z.o like"l*";sc["/";`LIBPL`LDLIBRARY];"''"]],pr["__import__('sys').prefix"],"\"2>",$[.z.o like"w*";"nul <nul";"/dev/null"];
 `L`M`H set'@[system"python3 ",;c;{system"python ",c}];if[count M;if[k~key k:`$":",M;L::M]];
 .p:(`:./p 2:(`init;2))[L;H]]
loaded:.P.loaded
if[not loaded;
 ei:{eo y _ x;n set .p.get[n:`$(2+x)_(y?"(")#y]value y x;};
 eo:.p.e;
 e:{$["def"~3#x;$[x[3]in"<*>";ei 3;eo];"class"~5#x;$[x[5]in"*>";ei 5;eo];eo]x}];
k)c:{'[y;x]}/|:         / compose list of functions
k)ce:{'[y;x]}/enlist,|: / compose with enlist (for variadic functions)

/ Aliases
if[not loaded;set'[`pyget`pyeval`pyimport;.p.get,.p.eval,import]];
qeval:c`.p.py2q,pyeval

/ Wrapper for foreigns
embedPy:{[f;x]         
 $[-11h<>t:type x0:x 0;
    $[t=102h;
      $[any u:x0~/:(*;<;>);
         [c:(wrap;py2q;::)where[u]0;$[1=count x;.p.c c,;c .[;1_x]@]pyfunc f]; / call type
        (:)~x0;[setattr . f,@[;0;{`$_[":"=s 0]s:string x}]1_x;];
        (@)~x0;$[count 2_x;.[;2_x];]wrap call[getattr[f;`$"__getitem__"];enlist x 1;()!()];
        (=)~x0;[call[getattr[f;`$"__setitem__"];raze 1_x;()!()];];
        '`NYI];
      wrap pyfunc[f]. x];
    ":"~first a0:string x0;                                                / attr lookup and possible call
     $[1=count x;;.[;1_x]]wrap f getattr/` vs`$1_a0;
    x0~`.;f;x0~`;py2q f;                                                   / extract as foreign or q
     wrap pyfunc[f]. x]}                                                   / default, call
unwrap:{$[i.isw x;x`.;x]}
xunwrap:{$[0=t:type x;.z.s each x;98=t;flip .z.s flip x;99=t;.z.s[key x]!.z.s value x;unwrap x]}
wfunc:{[f;x]r:wrap f x 0;$[count x:1_x;.[;x];]r}
i.wf:{[f;x]embedPy[f;x]}
wrap:ce i.wf@
import:ce wfunc pyimport
.p.eval:ce wfunc pyeval
.p.get:ce wfunc pyget
.p.set:{[f;x;y]f[x]unwrap y;}.p.set
//.p.key:{wrap pykey$[i.isf x;x;i.isw x;x`.;'`type]}
//.p.value:{wrap pyvalue$[i.isf x;x;i.isw x;x`.;'`type]}
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
repr:gethelp import[`builtins;`:repr;<]
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

/ Add cwd and $QHOME to sys.path
sp:.p.import[`sys]`:path
spq:distinct("";getenv`QHOME),sp`
sp[`:clear][];
sp[`:extend]spq;
/ write python stdout/err to 1 and 2
{.p.import[`sys;x][:;`:write;{x y;count y}y]}'[`:stdout`:stderr;1 2];
/ set sys.argv
if[not .p.eval["hasattr";.p.import`sys;`argv]`;.p.import[`sys][:;`argv;enlist""]]

/ Cleanup
{![`.p;();0b;x]}`getseq`ntolist`runs`wfunc`gethelp`sp`spq`loaded;
{@[`.p;x;:;.p.import[`builtins]hsym x]}each`tuple`list`dict`isinstance;
