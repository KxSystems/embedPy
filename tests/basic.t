-1"## Basic tests start";
.p.set[`x;3]
3~.p.py2q .p.pyget`x
3~.p.get[`x]`
x:(0;1h;"str";`sym)
r:(0;1; "str";"sym")
r~.p.eval["lambda x:x";<]x
p)import numpy as np
p)a=np.arange(6).reshape(2,3)
any 30 7h in .p.type .p.pyget`a
(2 3#til 6)~.p.py2q .p.pyget`a
p)s=np.int64(1)
1~.p.py2q .p.pyget`s
x:(0;1h;"str";`sym; 1. 2;1 2e)
r:(0;1; "str";"sym";1. 2;1 2e)
r~.p.eval["lambda x:x";<]x
r~first(.p.get[`x]`;.p.set[`x]x)
p)class foo:
 def __init__(self,x): self.x = x
 def bar(self,y):return self.x+y
foo:.p.import[`$"__main__";`foo;*]42
142~foo[`bar;<;]100
ver:.p.import[`sys;`version]`
p)import sys
ver~.p.eval["sys.version"]`
q)p)pyd={'one':1,'two':2,'three':3}
q)qd:.p.get`pyd
("one";"two";"three")~.p.key[qd]`
1 2 3~.p.value[qd]`
.p.py2q .p.pyeval"{}"
-1"## Basic tests end";
