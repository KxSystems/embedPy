#include"k.h"
#define K3(f) K f(K x,K y,K z)
#define K(x...) k(0,"k)"x,0)
#include<stdio.h>
Z K ker(S e,S f,I l,S g){Z C b[99];snprintf(b,98,"%s:%d %s %s",f,l,g,e);K r=krr(b);R r;}
#define F(x)   ker((S)x,(S)__FILE__,__LINE__,(S)__func__)
#define E(x)    F(#x)

#include<Python.h>
#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION // http://docs.scipy.org/doc/numpy/reference/c-api.deprecations.html
#include<numpy/arrayobject.h>
#include <pthread.h>
Z pthread_key_t tk;PyInterpreterState*tp;

#if PY_MAJOR_VERSION<3
#define PY(x,y) x
#else
#define PY(x,y) y
#endif

#if linux
#include<dlfcn.h>
Z V dyl(S x){V*r=dlopen(x,RTLD_LAZY|RTLD_GLOBAL|RTLD_NODELETE);r?dlclose(r):fprintf(stderr,"'%s: %s\n",dlerror(),x);}
#elif _WIN32
Z V dyl(S x){}
#define typeof decltype
#elif __APPLE__
Z V dyl(S x){}
#else
#error
#endif

#undef O
typedef PyObject*O;typedef PyArrayObject*A;O d,M;K m;
#define PE   (PyErr_Occurred()?PyErr_Print(),E(pyerr):E(pyerr))
#define A(x) {typeof(x)x_=(x);x_?x_:*(V*)0;}

ZI gil6(){I g=PyGILState_Check();if(!g){V*s=pthread_getspecific(tk);if(!s)s=PyThreadState_New(tp);PyEval_RestoreThread(s);}}
ZI gil9(I g){if(!g)pthread_setspecific(tk,PyEval_SaveThread());}
Z O ok(K);Z K kpy2q;K1(py2q){R K("@",r1(kpy2q),r1(x));}
Z K pget(O x){K r=PyCapsule_GetPointer(x,0);R r;}Z V destr(O o){r0(pget(o));}Z O pwrap(K x){R PyCapsule_New(r1(x),0,destr);}
Z V p0(K x){
 I g=gil6();
 Py_DECREF(kK(x)[1]);
 gil9(g);}
Z K ko(O o){P(!o,0);K r=knk(2,p0,o);R r->t=112,r;}ZI pq(K x){R xt==112&&xn==2&&*kK(x)==(K)p0;}Z O kget(K x){P(!pq(x),0)O o=(O)kK(x)[1];Py_INCREF(o);R o;}
Z O ck(O x,O y){I g=gil6();K a=ko(y);Py_INCREF(y);K r=K(".",r1(pget(x)),py2q(a));O o=ok(r);R r0(a),r0(r);gil9(g);R o;} // ok here is fine without checking, python will print pyerr
Z PyMethodDef pmd={"q)",ck,METH_VARARGS,""};Z O ocall(K x){O o=pwrap(x),f=PyCFunction_New(&pmd,o);Py_DECREF(o);R f;}

Z K at(K x,J i){R !xt?r1(kK(x)[i]):K("@",r1(x),kj(i));}Z J cn(K x){J n;K r=K("#:",r1(x));n=r->j;R r0(r),n;}
#define W sizeof(V*)
ZS ct    =" bg xhijefcspmdznuvt";
ZI dh[20]={0,4,2,3,4,5,6,7,8,9,4,2,7,6,6,9,7,6,6,6};
ZI zh[20]={W,1,W,0,1,2,4,8,4,8,0,0,0,0,0,0,0,0,0,0};

C pynt[13]={NPY_OBJECT,NPY_BOOL,0,0,NPY_UINT8,NPY_INT16,NPY_INT32,NPY_INT64,NPY_FLOAT32,NPY_FLOAT64,NPY_INT8,NPY_STRING,-1};I npyt(I c){I i=0;C*t=pynt;while(t[i]+1&&t[i]!=c)i++;R t[i]+1?i:-1;}
#define CK(x) Py##x##_Check
#define Co(x) P(!CK(x)(o),E(pytype))
#define PyC_Check PY(PyString_Check,PyUnicode_Check)
Z K kseq(O o){O f=PySequence_Fast(o,0);K x=ktn(0,PySequence_Fast_GET_SIZE(f));DO(xn,(kK(x)[i]=ko(o=PySequence_Fast_GET_ITEM(f,i)),Py_INCREF(o)))Py_DECREF(f);R x;}
typedef V*(*T)(S);Z V*PyC_utf8(T f,O o){PY(0,P(!(o=PyUnicode_AsUTF8String(o)),PE));S s=PY(PyString_AsString,PyBytes_AS_STRING)(o);V*r=f(s);PY(0,Py_DECREF(o));R r;}
#define KO(x) Z K ko##x(O o)
KO(b){Co(Bool)R kb(Py_True==o);}   KO(j){Co(Long)R kj(PyLong_AsUnsignedLongLongMask(o));}        KO(f){Co(Float)R kf(PyFloat_AsDouble(o));}
KO(C){Co(C)R PyC_utf8((T)kp,o);}   KO(G){Co(Bytes)R kpn(PyBytes_AS_STRING(o),PyBytes_Size(o));}  KO(none){P(o-Py_None,E(none))R K("::");}         KO(buffer){P(!PyObject_CheckBuffer(o),E(buffer))R ks("<buffer>");}

Z C gnull(K x){R xt==101&&!xg;}Z C anull(K x){R !xt&&xn==1&&gnull(xK[0]);}
#define CPO(o,r,clean) if(!o){clean;if(PyErr_Occurred())PyErr_Print();R(r);}
Z O otup(K x){J n=cn(x);O r=PyTuple_New(n);K y;DO(n,O o=ok(y=at(x,i));r0(y);CPO(o,o,Py_DECREF(r))PyTuple_SET_ITEM(r,i,o))R r;}
Z O atup(K x){P(anull(x),PyTuple_New(0));R otup(x);}
Z O odict(K x){O r=PyDict_New(),m,o;K y=kK(x)[1],v,z;x=*kK(x);P(xt<0,Py_None)DO(xn,m=ok(v=at(x,i));r0(v);CPO(m,m,Py_DECREF(r))o=ok(z=at(y,i));r0(z);CPO(o,o,Py_DECREF(r);Py_DECREF(m))PyDict_SetItem(r,m,o);Py_DECREF(m);Py_DECREF(o))R r;}
Z O nk(K x){O r;npy_intp n=xn/*q<3?*/;R r=PyArray_SimpleNewFromData(1,&n,pynt[xt],xG),PyArray_SetBaseObject((A)r,pwrap(x)),PyArray_CLEARFLAGS((A)r,NPY_ARRAY_WRITEABLE),r;}
Z O ok(K x){P(pq(x),kget(x))P(gnull(x),Py_None)P(xt<0,-128==xt?PyErr_Format(PyExc_RuntimeError,"%s",xs):-KB==xt?xg?Py_True:Py_False:-KG>=xt&&-KJ<=xt?PyLong_FromLong(-KG==xt?xg:-KH==xt?xh:-KI==xt?xi:xj):-KE==xt||-KF==xt?PyFloat_FromDouble(xt-KE?xf:xe):-KC==xt?PyUnicode_FromStringAndSize((S)&xg,1):-KS==xt?PyUnicode_FromString(xs):Py_None)P(!xt||xt==XT,otup(x))SW(xt){CS(KG,R PyBytes_FromStringAndSize((S)kG(x),xn))CS(KC,R PyUnicode_FromStringAndSize((S)kC(x),xn))CS(KS,R otup(x))CS(XD,R odict(x))CS(100,R ocall(x))CD:R 0<xt&&20>xt?nk(x):pwrap(x);}R Py_None;}


#define Oo O o;P(!(o=kget(x)),E(type))
#define Ro(o) {PyErr_Clear();R ko(o)?:PE;}
#define X0(a) {typeof(a)r=a;r0(x);R r;}
#define O0(a) {typeof(a)r=a;Py_DECREF(o);R r?:PE;}
Z K2(runs){P(xt!=-KJ||y->t!=KC,E(type))J j=xj;C z=0;r1(y);x=ja(&y,&z);x==y?--xn:r0(y);PyErr_Clear();O o=PyRun_String((S)xG,j?Py_eval_input:Py_file_input,d,d);r0(x);R ko(o)?:PE;} //evaluate a string, x, returning a foreign.  $[y;evaluate;runasfile]   TODO check return
Z K2(set){P(xt!=-KS,E(type))O o=ok(y);P(!o,PE)PyDict_SetItemString(d,xs,o);Py_DECREF(o);R 0;}//set a python variable x (symbol) with value y in the __main__ module TODO - check SIS return
Z K1(import){P(xt!=-KS,E(type))O m=PyImport_ImportModule(xs);P(!m,F(xs))R ko(m);}//import x (symbol) returns a foreign with the contents of module named by x
Z K2(getattr){P(y->t!=-KS,E(type))Oo;O f=PyObject_GetAttrString(o,TX(S,y));P(!f,(PyErr_Print(),F(TX(S,y))))Py_DECREF(o);R ko(f);}//for a foreign, x, get the attribute named by y (symbol)
Z K3(call){P(y->t<0,E(type))O f=kget(x),o,s,t;P(!PyCallable_Check(f),E(type))t=pq(z)?kget(y):atup(y);CPO(t,E(pyerr),Py_DECREF(f))s=pq(z)?kget(z):odict(z);CPO(s,E(pyerr),Py_DECREF(f);Py_DECREF(t))o=PyObject_Call(f,t,s);Py_DECREF(t);Py_DECREF(s);Py_DECREF(f);P(!o,PE)R ko(o);}//call a foreign, x, with positional args y and keyword args z
Z K1(repr){O o;K r;P(!pq(x),E(type))P(!(o=PyObject_Repr(kget(x))),PE)r=koC(o);Py_DECREF(o);R r;}//return a string like repr(x)
Z K1(getseq){Oo;O0(kseq(o))}//return an array of foreigns from x. x should be a sequence
#define GX(x) Z K1(get##x){Oo;R ko##x(o);}
GX(b)GX(none)GX(j)GX(f)GX(G)GX(C)GX(buffer)//these functions return a foreign (x) as a bool, none, long, float, G, C or buffer(G)
#define TY(x) {H h=x;r=ja(&r,&h);}
#define CH(x,y) if(CK(x)(o))TY(y)
Z K1(type){Oo;K r=ktn(KH,0);CH(Bool,-1)CH(Long,-7)CH(Float,-9)CH(Module,102)if(PyArray_CheckScalar(o))TY(-30);if(PyArray_Check(o)){TY(30)TY(npyt(PyArray_TYPE((A)o)))}CH(Bytes,4)CH(Number,-22)
                              if(Py_None==o)TY(-3);if(PyC_Check(o))TY(10);if(PyObject_CheckBuffer(o))TY(24);
                              CH(Tuple,41)CH(List,42)CH(Callable,100)CH(Sequence,40)CH(Dict,99)CH(Mapping,101)CH(Type,21)CH(Iter,45)CH(Set,46)TY(50)Py_DECREF(o);R r?:PE;}//for a foreign, x, return a list of shorts indicating the foreign's type
Z K1(q2py){O o=ok(x);P(!o,PE)R ko(o);}//take a q value and return an equivalent value as a foreign
Z K1(key){Oo;Co(Mapping)Ro(PyMapping_Keys(o))}//return the keys of a dictionary, x
Z K1(value){Oo;Co(Mapping)Ro(PyMapping_Values(o))}//return the values of a dictionary, x
 K dim(O o){A a=(A)o;I n=PyArray_NDIM(a);K x=ktn(KJ,n);DO(n,xJ[i]=PyArray_DIMS(a)[i]);R x;}
Z K1(getarraydims){Oo;Co(Array)R dim(o);}//for an array, return an array of "j" describing the dims (or shape) of x
 K arr(O o,J m,J n){A a=(A)o;I t=npyt(PyArray_TYPE(a));P(!t,E(type))I z=zh[t];P(m<0,E(index));P(n<0||PyArray_NBYTES(a)<z*(m+n),E(length))K x=ktn(t,n);memcpy(xG,PyArray_DATA(a)+m*z,n*z);R x;}
Z K3(getarray){Oo;Co(Array)P(y->t!=-KJ||z->t!=-KJ,E(type))R arr(o,y->j,z->j);}//for an array, x, return a q list
Z K1(get){P(xt!=-KS,E(type));O o=PyDict_GetItemString(d,xs);;P(o,(Py_INCREF(o),ko(o)))R E(item);}//get a python variable named by x (symbol) in the __main__ module
Z K1(isp){R kb(pq(x));}
Z K1(init){P(Py_IsInitialized(),0);if(RP)Py_SetPythonHome(PH);
 Py_InitializeEx(1);PyEval_InitThreads();pthread_key_create(&tk,0);
 PySys_SetArgvEx(0,0,0);d=PyModule_GetDict(M=PyImport_AddModule("__main__"));m=ko(M);dyl(DY);import_array1(E(numpy));
 PyThreadState*g=PyEval_SaveThread();tp=g->interp;pthread_setspecific(tk,g);
 R 0;}
Z K2(safe){P(xt!=112||y->t<0,E(type))P(pq(x),E(foreign))K r;I g=gil6();r=K(".",r1(x),r1(y));gil9(g); R r;}
#define sdl(f,n) (js(&x,ss(#f)),jk(&y,dl(f,n)),j=n,ja(&z,&j));
K1(dld){
 J j;K y=ktn(0,0),z=ktn(7,0);x=ktn(KS,0);sdl(runs,2)sdl(set,2)sdl(import,1)sdl(isp,1)sdl(getattr,2)sdl(call,3)sdl(repr,1)sdl(py2q,1)sdl(q2py,1)sdl(key,1)sdl(value,1)sdl(type,1)sdl(get,1)sdl(getseq,1)sdl(getb,1)sdl(getnone,1)sdl(getj,1)sdl(getf,1)sdl(getG,1)sdl(getC,1)sdl(getarraydims,1)sdl(getarray,3)sdl(getbuffer,1)sdl(safe,2)
 R knk(3,x,y,z);}
#define Ke(x) ({K r=k(0,x,(S)0);if(r->t==-128)R fprintf(stderr,"  %s\n",x),r;r;})
K1(lib){init(x);r0(K("{.[`.P;();:;x!y];.P.a:x!z}.",dld(x)));K r,d0=K("\\d");S s[]={"\\d .P","e:{runs[0;x];}","k)eval:runs[1]","k)scalar:py2q call[eval\"lambda x:x.tolist()\";;()!()]@,:","k)py2q:{$[isp x;conv type[x]0;]x}",
 "k)dict:{({$[1b~&/10=@:'x;`$;]x}py2q key x)!py2q value x}","k)conv:((- 1 3 7 9 21 30h)!getb,getnone,getj,getf,repr,scalar),4 10 30 41 42 99h!getG,getC,{d#x[z;0]1*/d:y z}[getarray;getarraydims],(2#(py2q'getseq@)),dict",0};
 Ke("{.P[x]:('[.P.safe[.P x;];({enlist x};enlist[;];enlist[;;])@-1+.P.a x])}@'(key .P)except `safe");
 S*p=s-1;while(*++p)r0(Ke(*p));kpy2q=Ke("py2q");r=Ke("k)(k,`c)!(.P k:`eval`e`import`get`set`call`key`value`getattr`isp`type`py2q`q2py`repr`conv`runs),,.P");
 x=K(".\"\\\\d \",$:",d0);
 R xt==-128?x:r;
}
