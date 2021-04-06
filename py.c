#include"py.h"
ZS zs(K x){S s=memcpy(malloc(xn+1),xG,xn);R s[xn]=0,s;}Z K1(cs){K r,y;P(xt||!xn,r1(x))DO(xn,P(10!=kK(x)[i]->t,r1(x)))r=ktn(KS,xn);DO(xn,y=kK(x)[i];kS(r)[i]=sn(y->G0,y->n))R r;}
ZK at(K x,J i){R!xt?r1(kK(x)[i]):k(0,"@",r1(x),kj(i),0);}ZJ cn(K x){J n;x=k(0,"#:",r1(x),0);n=xt==-KJ?xj:nj;R r0(x),n;}ZK val(K x){R k(0,".:",r1(x),0);}
ZI g1(){R PyGILState_Ensure();}ZV g0(I g){PyGILState_Release(g);}ZK ktrr(){R krr("type");}ZP ptrr(){R PyErr_BadArgument();}
ZV*t1(){R PyEval_SaveThread();}ZV t0(V*t){PyEval_RestoreThread(t);}ZP M;ZV**N;ZP pe(K x){R PyErr_SetString(PyExc_RuntimeError,xs);}
ZP p1(P p){Py_IncRef(p);R p;}ZV p0(P p){Py_DecRef(p);}ZI pt(P p,P t){P u=PyObject_Type(p);I f;f=(u==t||PyType_IsSubtype(u,t));p0(u);R f;}
ZP pg(K x){R(P)(kK(x)[1]);}ZV pd(K x){I g=g1();p0(pg(x));g0(g);}ZK kfp(P p){K x=knk(2,pd,p);R xt=112,x;}ZI pq(K x){R xt==112&&xn==2&&*kK(x)==(K)pd;}
ZK kfg(P p){R PyCapsule_GetPointer(p,"k");}ZV kfd(P p){r0(kfg(p));}ZP pfk(K x){R PyCapsule_New(r1(x),"k",kfd);}
ZK prr(S s){Z __thread C b[4096];J n=sizeof(b)-1;P t,v,d,a;*b=0;strncat(b,s,n);PyErr_Fetch(&t,&v,&d);if(t){PyErr_NormalizeException(&t,&v,&d);
 strncat(strncat(b,": ",n),PyUnicode_AsUTF8AndSize(a=PyObject_Str(v),0),n);p0(a);p0(t);p0(v);p0(d);}R krr(b);}ZK prg(S s,I g){K r=prr(s);g0(g);R r;}

ZK ko(P);ZK cf;//k from python
ZK kstr(I t,P p){K r;L n;S s=t==KG?PyBytes_AsStringAndSize(p,&s,&n)<0?0:s:PyUnicode_AsUTF8AndSize(p,&n);P(!s,prr("kstr"))r=kpn(s,n);R r->t=t,r;}
ZK ksc(P p){I i;J j;P(_Py_TrueStruct==p,kb(1))P(_Py_FalseStruct==p,kb(0))P(_Py_NoneStruct==p,k(0,"::",0))
 P(pt(p,PyLong_Type),kj((j=PyLong_AsLongLongAndOverflow(p,&i),i?i*wj:j)))P(pt(p,PyFloat_Type),kf(PyFloat_AsDouble(p)))R ktrr();}
ZK kseq(I f,P p){K r;P*v=f?p->v:p->p;r=ktn(0,p->n);DO(r->n,P(!(kK(r)[i]=ko(v[i])),(r0(r),(K)0)))R k(0,"::'",r,0);}
ZK kdict(P p){P a;K x,y,r;a=PyDict_Keys(p);P(!a,prr("dict k"))x=ko(a);p0(a);U(x)a=PyDict_Values(p);P(!a,(r0(x),prr("dict v")))y=ko(a);p0(a);P(!y,(r0(x),(K)0))r=xD(cs(x),y);r0(x);R r;}
ZK knp(A a){P p;K r;I t,f;if(f=a->n,f>1||!(t=ta(a))){p=PySequence_List((P)a);P(!p,prr("numpylist"))r=ko(p);p0(p);R r;}
 if(!(a->f&1)){a=PyArray_NewCopy(a,0);P(!a,prr("numpycopy"));r=knp(a);p0((P)a);R r;}P(t<0,ktrr())r=f?ktn(t,*a->c):ka(-t);memcpy(f?r->G0:&r->g,a->g,a->d->e*(f?r->n:1));R r;}
ZK kns(P p){K r;A a=PyArray_FromScalar(p,0);P(!p,prr("scalar"))r=knp(a);p0((P)a);R r;}
ZK ko(P p){S s;K x=N&&pt(p,PyArray_Type)?knp((A)p):N&&pt(p,PyGenericArrType_Type)?kns(p):pt(p,PyUnicode_Type)?kstr(KC,p):pt(p,PyBytes_Type)?kstr(KG,p):pt(p,PyDict_Type)?kdict(p):
 pt(p,PyList_Type)?kseq(0,p):pt(p,PyTuple_Type)?kseq(1,p):ksc(p);R x?x:(x=ee(x),s=xs,r0(x),!strcmp(s,"type")?k(0,"@",r1(cf),kfp(p1(p)),0):krr(s));}

ZP po(K);//python from k
ZP pstr(I t,K x){R(t==4?PyBytes_FromStringAndSize:PyUnicode_FromStringAndSize)(xG,xn);}ZP po0(K x){P p=po(x);r0(x);R p;}ZP pi(K x,J i){R po0(ee(at(x,i)));}
ZP psc(K x){I t=-xt;P(t==KB,PyBool_FromLong(xg))P(t>=KH&&t<=KJ||t>=KP&&t<=KT&&t!=KZ,PyLong_FromLongLong(t==KH?xh:t==KJ||t==KP||t==KN?xj:xi))
 P(t==KE||t==KF||t==KZ,PyFloat_FromDouble(t==KE?xe:xf))P(t==KS,PyUnicode_FromString(xs))P(t==KG||t==KC,po0((x=kpn(&xg,1),xt=t,x)))R ptrr();}ZP pen(K x){R po0(ee(val(x)));}
ZP pseq(I f,K x){P p,*v;J n;P(xt>XT,ptrr())n=cn(x);P(n<0,ptrr())p=(f?PyTuple_New:PyList_New)(n);v=f?p->v:p->p;DO(n,v[i]=pi(x,i);P(!v[i],(p0(p),(P)0)))R p;}
ZP pdict(K x){K y=kK(x)[1];P p=PyDict_New(),k,v;x=*kK(x);DO(cn(x),k=pi(x,i);P(!k,(p0(p),(P)0))v=pi(y,i);P(!v,(p0(p),p0(k),(P)0))PyDict_SetItem(p,k,v);p0(k);p0(v))R p;}
ZP pc(P f,P a){K x,y=kfg(f),z=ee(ko(a));V*t;P(z->t==-128,(f=pe(z),r0(z),f))t=t1();x=k(0,".",r1(y),z,0);t0(t);R po0(x);}ZP pkt(K x){R po0(k(0,"{flip 0!select from x}",r1(x),0));}
ZP pcall(K x){P p,a;Z D d={"q)",pc,1,""};P(xt==101&&!xg,p1(_Py_NoneStruct))p=PyCFunction_New(&d,a=pfk(x));p0(a);R p;}ZI ktq(K x){R xt==XT||xt==XD&&kK(x)[0]->t==XT&&kK(x)[1]->t==XT;}
ZP pvec(K x){L n=xn;P p;A a;I t=tk(x);P(t<0,ptrr());a=PyArray_New(PyArray_Type,1,&n,t,0,x->G0,-1,0,0);U(a)p=pfk(x);P(PyArray_SetBaseObject(a,p),(p0(p),(P)0))R(P)a;}
ZP po(K x){I t=xt;R pq(x)?p1(pg(x)):t<0?psc(x):t==4||t==10?pstr(t,x):N&&t&&t<20&&t!=11?pvec(x):t>19&&t<77?pen(x):ktq(x)?pkt(x):t==XD?pdict(x):t>99&&t<112?pcall(x):t==-128?pe(x):pseq(0,x);}
ZP ev(I f,K x){S s;P a,b;P(xt!=KC,ptrr())s=zs(x);a=Py_CompileString(s,"",256+f);free(s);U(a)b=PyEval_EvalCode(a,M,M);p0(a);R b;}

//k api -- these need to balance g1/g0
Z K1(e){P p;I g=g1();p=ev(1,x);P(!p,prg("e",g))g0(g);p0(p);R 0;}Z K1(eval){P p;I g=g1();p=ev(2,x);P(!p,prg("eval",g))g0(g);R kfp(p);}
Z K1(py2q){K r;I g;P(!pq(x),ktrr())g=g1();r=ko(pg(x));g0(g);R r;}Z K1(q2py){I g=g1();P p=po(x);P(!p,prg("q2py",g))g0(g);R kfp(p);}
Z K1(get){P p;I g;P(xt!=-KS,ktrr())g=g1();p=PyDict_GetItemString(M,xs);if(p)p1(p);g0(g);P(!p,krr(xs))R kfp(p);}
Z K2(set){P p;I g;P(xt!=-KS,ktrr())g=g1();p=po(y);P(!p,prg("set",g))PyDict_SetItemString(M,xs,p);p0(p);g0(g);R 0;}
Z K1(import){P p;I g;P(xt!=-KS,ktrr())g=g1();p=PyImport_ImportModule(xs);P(!p,prg("import",g))g0(g);R kfp(p);}
Z K2(getattr){P p;I g;P(y->t!=-KS||!pq(x),ktrr())g=g1();p=PyObject_GetAttrString(pg(x),TX(S,y));P(!p,prg("getattr",g))g0(g);R kfp(p);}
Z K3(call){P a,k,p;I g;P(!pq(x)||!pq(z)&&z->t!=XD,ktrr())g=g1();a=pq(y)?p1(pg(y)):pseq(1,y);P(!a,prg("call a",g))k=pq(z)?p1(pg(z)):pdict(z);P(!k,(p0(a),prg("call k",g)))
 p=PyObject_Call(pg(x),a,k);P(!p,(p0(a),p0(k),prg("call",g)))p0(a);p0(k);g0(g);R kfp(p);}
Z K1(setconv){P(xt<100||xt>111,ktrr())r0(cf);cf=r1(x);R 0;}Z K1(getconv){R r1(cf);}Z K1(isp){R kb(pq(x));}

 
 ZV*t;EXP K3(init){ZI i=0;I f,g;S l,h,hh;K n,v;P a,b,pyhome;P(i,0)l=zs(x),h=zs(y),hh=zs(z);f=pyl(l);free(l);
 P(!f,krr("libpython"))
 Py_SetPythonHome(Py_DecodeLocale(h,0));Py_SetProgramName(Py_DecodeLocale(hh,0));free(h);free(hh);Py_InitializeEx(0);if(PyEval_ThreadsInitialized()&&!PyGILState_Check())t0(PyGILState_GetThisThreadState());PyEval_InitThreads();
 M=PyModule_GetDict(PyImport_AddModule("__main__"));cf=k(0,"::",0);n=ktn(KS,0);v=ktn(0,0);
 if(a=PyImport_ImportModule("numpy.core.multiarray")){N=PyCapsule_GetPointer(b=PyObject_GetAttrString(a,"_ARRAY_API"),0);if(!N||!pyn(N))N=0;p0(b);p0(a);}PyErr_Clear();
#define F(f,i) js(&n,ss(#f));jk(&v,dl(f,i));
 F(eval,1)F(e,1)F(py2q,1)F(q2py,1)F(get,1)F(set,2)F(import,1)F(getattr,2)F(call,3)F(isp,1)F(setconv,1)F(getconv,1)js(&n,ss("numpy"));jk(&v,kb(!!N));
 t=t1();i=1;R xD(n,v);}
// a kludge for python modules which try to resolve main e.g. scipy.optimize
int main(){}
