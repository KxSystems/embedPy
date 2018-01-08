''' writes a makefile after finding LDIC '''
import platform as p;import sys as s;import sysconfig as c;import subprocess as sb;import os;op=os.path;S=op.sep;js=lambda x:" ".join(x);sp=lambda x:x.split()
def ON(x):print(x);return x
def E(x):s.stderr.write("error: "+x+"\n");exit(1)
V,v=Vv=s.version_info[:2];a=p.machine();o=s.platform;sv=s.version;pv=p.version()
if V<3:E('version')
if "win32" in o:E('nyi')
try:import numpy as n
except:import traceback as tb;tb.print_exc();E('numpy')

gcc=lambda x:"-fPIC -shared" if x[0]=="l" else "-bundle -undefined dynamic_lookup"
pvm='python%d.%dm'%Vv;dy=lambda x:'lib'+x+'.so'
# rpath  PYTHONHOME
RP=1;    PH=s.exec_prefix;   L,l=(PH+S+'lib',pvm);   I=[PH+S+'include'];   C='gcc '+gcc(o);   D=["KXVER=3"]

if not "Anaconda" in sv:
 pc=PH+"/bin/"+pvm+"-config"
 ld=sb.run([pc,'--ldflags'],stdout=sb.PIPE,check=True).stdout.decode('utf-8').split()
 l=[x for x in ld if x.startswith('-lpython')][0][2:]
 L=[x for x in ld if x.startswith('-L') and op.exists(x[2:]+'/'+dy(l))][0][2:]
 
PH="'L\""+PH+"\"'"
DY="'\""+dy(l)+"\"'"
I.extend([n.get_include(),c.get_paths()['include']])
I=js("-I"+x for x in I)
D=js(["-D"+y for y in D+[x+"="+str(eval(x)) for x in sp("PH RP DY")]])
L="" if not RP else "-L"+L+" -l"+l+js(" -Xlinker "+x for x in ["-rpath",L])
m=open("makefile","w");[m.write(x+'='+str(eval(x))+"\n") for x in 'LDIC'];[m.write(x) for x in open("makefile.in").readlines()];m.close();s.exit(0)
