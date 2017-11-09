`a`b set'(`$first@)each 0 1_string .z.o;
e:{-2 string x;exit 1}
w:where{"B"$first@[system;string[x]," -c 'print(1)'";"0"]}@'pp:`python3`python                                                                      /python3 first
py:{system string[$[count w;pp first w;e`python]]," -c \"",x,"\""}
s :"import sysconfig as c,os,sys;v=c.get_config_var;first=lambda x:len(x) and x[0];d=v('LDLIBRARY');P,p=sys.exec_prefix,sys.prefix;"           /find dylib
s,:"w=lambda x:first([a[0] for a in os.walk(x) if d in a[2]]);L=w(P+'/lib')or w(v('LIBDIR'));I=c.get_path('include');print('\\n'.join([L,d,P,p,I]))"
`L`d`P`p`I set'0N!py s;l:$[a=`l;-3_3_d;a=`w;-4_d;-6_3_d]
I:"-I",I," -I",first py"import numpy as n;print(n.get_include())"                                                                                   /numpy dir
`r`D set\:"";if[rpath:1;r:raze " -Xlinker ",/:("-rpath";L," ");d:L,"/",d;D:"-DPH='L\"",P,":",p,"\"' ";]
C:$[a in`l`m;"gcc -g3 -Os -DKXVER=3 ";""] 
L:" -L",L," -l",l,r,$[a=`l;"-fPIC -shared";"-bundle -undefined dynamic_lookup"]
D,:"-DRP=","01"[rpath]," -DDY='\"",d,"\"'"
@[hdel;`:makefile;::];f:hopen`:makefile
{neg[f]string[x],"=",value x}@'`d`C`D`I`L;
neg[f]read0`:makefile.in;
hclose f
\\
ifeq ($(shell uname),Linux)
LDFLAGS=-fPIC -shared
else ifeq ($(shell uname),Darwin)
LDFLAGS=-bundle -undefined dynamic_lookup
endif
