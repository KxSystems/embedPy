-1"## Loading p.q";
\l p.q
-1"## Loaded";

-1"## Basic tests start";
(::)~.p.set[`x;3]
-7h in .p.type .p.get`x
3~.p.py2q .p.get`x
x:(0;1h;"str";`sym)
r:(0;1; "str";"sym")
r~(.p.callable .p.eval"lambda x:x")x
p)import numpy as np
p)a=np.arange(6).reshape(2,3)
any 30 7h in .p.type .p.get`a
(2 3#til 6)~.p.py2q .p.get`a
x:(0;1h;"str";`sym; 1. 2;1 2e)
r:(0;1; "str";"sym";1. 2;1 2e)
r~(.p.callable .p.eval"lambda x:x")x
r~first(.p.py2q .p.get`x;.p.set[`x]x)
p)class foo:
 def __init__(self,x): self.x = x
 def bar(self,y):return self.x+y
foo:(.p.callable_imp[`$"__main__";`foo])42;
142~.p.callable_attr[foo;`bar]100
ver:.p.py2q .p.imp[`sys;`version]
p)import sys
ver~.p.py2q .p.eval"sys.version"
-1"## Basic tests end";


-1"## C types start";
p)x=(__import__("ctypes").pythonapi.Py_DecRef)
24h in .p.type .p.get`x
-1"## C types end";

/-1"## Curve fit start";
/cf:.p.callable_imp[`scipy.optimize;`curve_fit]
/(enlist 2f;enlist enlist 3.4660897158452992e-32)~cf[{x xexp y};0 1 2 3 4;0 1 4 9 16f;1f]
/-1"## Curve fit end";

-1"## Loading additional tests";
\l bs4.t
\l pandas.t
\l matplotlib.t
\l pyfunc.t
\l memory.t
\l qfunc.t
\l tensorflow.t
