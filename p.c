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

#if PY_MAJOR_VERSION<3
#define PY(x,y) x
#else
#define PY(x,y) y
#endif
#define OUT printf

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
#define PE   (PyErr_Print(),E(pyerr))
#define A(x) {typeof(x)x_=(x);x_?x_:*(V*)0;}
Z O kget(K);
#define X0(a) {typeof(a)r_=(a);r0(x);R r_;}
#define O0(a) {typeof(a)r_=(a);Py_DECREF(o);R r_?:PE;}
#define CPO(o,r,clean) if(!o){clean;if(PyErr_Occurred())PyErr_Print();R(r);} // cleanup and return if invalid PyObject
Z O ok(K x){P(-128==xt,PyErr_Format(PyExc_RuntimeError,"%s",xs))X0(kget(x=K(".p.q2py",r1(x))))}
Z K pget(O x){K r=PyCapsule_GetPointer(x,0);R r;}Z V destr(O o){r0(pget(o));}Z O pwrap(K x){R PyCapsule_New(r1(x),0,destr);}
Z V p0(K x){Py_DECREF(kK(x)[1]);}Z K ko(O o){P(!o,0);K r=knk(2,p0,o);R r->t=112,r;}ZI pq(K x){R xt==112&&xn==2&&*kK(x)==(K)p0;}Z O oref(K x){P(!pq(x),0)O o=(O)kK(x)[1];R o;}Z O kget(K x){O o=oref(x);P(!o,0);Py_INCREF(o);R o;}
Z O ck(O x,O y){K a=ko(y);Py_INCREF(y);K r=K(".",r1(pget(x)),K(".p.py2q",a));O o=ok(r);R r0(r),o;}
Z PyMethodDef D={"q)",ck,METH_VARARGS,""};Z O ocall(K x){O o=pwrap(x),f=PyCFunction_New(&D,o);f||(PyErr_Print(),0);Py_DECREF(o);R f;}

Z K at(K x,J i){R !xt?r1(kK(x)[i]):K("@",r1(x),kj(i));}Z J cn(K x){J n;K r=K("#:",r1(x));n=r->j;R r0(r),n;}
Z K2(q2py);Z K2(uq2py);
Z O oat(K x,J i,K cf){K t,z,y;y=!xt?r1(kK(x)[i]):dot(x,t=knk(1,kj(i)));if(xt)r0(t);z=XD==cf->t?q2py(y,cf):uq2py(y,r1(cf));r0(y);O o=z?oref(z):0;R o?Py_INCREF(o),r0(z),o:z?r0(z),o:o;}
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
Z O otup(K x){J n=cn(x);O o,r=PyTuple_New(n);K y;DO(n,o=ok(y=at(x,i));r0(y);CPO(o,o,Py_DECREF(r))PyTuple_SET_ITEM(r,i,o));R r;}
Z O atup(K x){P(anull(x),PyTuple_New(0));R otup(x);}
// conversion of dicts and lists using user provided conversion func dict
Z O otup_cf(K x,K cf){J n=cn(x);O r=PyTuple_New(n),o;DO(n,o=oat(x,i,cf);CPO(o,o,Py_DECREF(r));PyTuple_SET_ITEM(r,i,o))R r;}
Z O odict_cf(K x,K cf){O r,m,o;K y=kK(x)[1];x=*kK(x);P(xt<0,Py_None);r=PyDict_New();DO(xn,m=oat(x,i,cf);CPO(m,m,Py_DECREF(r))o=oat(y,i,cf);CPO(o,o,Py_DECREF(r);Py_DECREF(m))PyDict_SetItem(r,m,o);Py_DECREF(m);Py_DECREF(o))R r;}

// conversions to PyObject
#define OK1(f) Z O f(K x)
OK1(j2o){R PyLong_FromLong(-KG==xt?xg:-KH==xt?xh:-KI==xt?xi:xj);}OK1(f2o){R PyFloat_FromDouble(xt-KE?xf:xe);}OK1(b2o){R xg?Py_True:Py_False;}
OK1(c2o){R PyUnicode_FromStringAndSize((S)&xg,1);}OK1(s2o){R PyUnicode_FromString(xs);}OK1(C2o){R PyUnicode_FromStringAndSize((S)kC(x),xn);}
OK1(a2o){npy_intp n=xn;O r=PyArray_SimpleNewFromData(1,&n,pynt[xt],xG);PyArray_SetBaseObject((A)r,pwrap(x)),PyArray_CLEARFLAGS((A)r,NPY_ARRAY_WRITEABLE);R r;}OK1(G2o){R PyBytes_FromStringAndSize((S)kG(x),xn);}
OK1(lambda2o){R ocall(x);}OK1(rr2o){R PyErr_Format(PyExc_RuntimeError,"%s",xs);}
Z O fs2o(K x){O o=PyTuple_New(xn);DO(xn,PyTuple_SET_ITEM(o,i,kget(kK(x)[i])));R o;} // needed? list of foreigns create a new tuple
// type check and wrapped in K object
#define Xt(t) P(xt!=t,F("type "#t))
Z K1(b2py){Xt(-KB)R ko(b2o(x));}Z K1(j2py){Xt(-KJ)R ko(j2o(x));}Z K1(f2py){Xt(-KF)R ko(f2o(x));}Z K1(null2py){P(!gnull(x),E(type))R ko(Py_None);} //create bool, integer, floating point, None from k values
Z K1(a2py){P(xt<1,E(type))R ko(a2o(x));}Z K1(G2py){Xt(KG)R ko(G2o(x));}Z K1(C2py){Xt(KC)R ko(C2o(x));} // array, byte[],char[]
Z K1(lambda2py){Xt(100)R ko(lambda2o(x));}Z K1(rr2py){Xt(-128)R ko(rr2o(x));} // lambda, error
Z K1(fs2py){Xt(0);DO(xn,P(!pq(kK(x)[i]),E(type)));R ko(fs2o(x));} // TODO no longer needed, handled by otup
// no longer to be used, not safe TODO remove
O dsi(O d,K x,J j){O m[2];K y[2],z[2];DO(2,y[i]=kK(x)[i])PyDict_SetItem(d,*m=ok(*z=at(*y,j)),m[1]=ok(z[1]=at(y[1],j)));DO(2,r0(z[i]))DO(2,Py_DECREF(m[i]));R d;}
Z K1(dict2py){Xt(99)O r=PyDict_New();DO(xK[0]->n,dsi(r,x,i));R ko(r);}


#define Oo O o;P(!(o=kget(x)),E(type))
#define Ro(o) {PyErr_Clear();O0(ko(o));}
Z K2(runs){P(xt!=-KJ||y->t!=KC,E(type))J j=xj;C z=0;r1(y);x=ja(&y,&z);x==y?--xn:r0(y);PyErr_Clear();O o=PyRun_String((S)xG,j?Py_eval_input:Py_file_input,d,d);r0(x);R ko(o)?:PE;} //evaluate a string, x, returning a foreign.  $[y;evaluate;runasfile]   TODO check return
Z K2(set){P(xt!=-KS,E(type))O o=ok(y);P(!o,PE)J r=PyDict_SetItemString(d,xs,o);Py_DECREF(o);P(r,E("sis"))R 0;}//set a python variable x (symbol) with value y in the __main__ module
Z K1(import){P(xt!=-KS,E(type))O m=PyImport_ImportModule(xs);P(!m,F(xs))R ko(m);}//import x (symbol) returns a foreign with the contents of module named by x
Z K2(getattr){P(y->t!=-KS,E(type))Oo;O f=PyObject_GetAttrString(o,TX(S,y));P(!f,F(TX(S,y)))Py_DECREF(o);R ko(f);}//for a foreign, x, get the attribute named by y (symbol)
Z K3(call){P(y->t<0,E(type))O f=kget(x),o,s,t;P(!PyCallable_Check(f),E(type))t=pq(y)?kget(y):atup(y);CPO(t,E(pyerr),Py_DECREF(f))s=pq(z)?kget(z):ok(z);CPO(s,E(pyerr),Py_DECREF(f);Py_DECREF(t))o=PyObject_Call(f,t,s);Py_DECREF(t);Py_DECREF(s);Py_DECREF(f);P(!o,PE)R ko(o);}//call a foreign, x, with positional args y and keyword args z
Z K1(repr){O o;K r;P(!pq(x),E(type))P(!(o=PyObject_Repr(kget(x))),PE)O0(koC(o))}//return a string like repr(x)
Z K1(getseq){Oo;O0(kseq(o))}//return an array of foreigns from x. x should be a sequence
#define GX(x) Z K1(get##x){Oo;O0(ko##x(o));}
GX(b)GX(none)GX(j)GX(f)GX(G)GX(C)GX(buffer)//these functions return a foreign (x) as a bool, none, long, float, G, C or buffer(G)
#define TY(x) {H h=x;r=ja(&r,&h);}
#define CH(x,y) if(CK(x)(o))TY(y)
Z K1(type){Oo;K r=ktn(KH,0);CH(Bool,-1)CH(Long,-7)CH(Float,-9)CH(Module,102)if(PyArray_CheckScalar(o))TY(-30);if(PyArray_Check(o)){TY(30)TY(npyt(PyArray_TYPE((A)o)))}CH(Bytes,4)CH(Number,-22)
                              if(Py_None==o)TY(-3);if(PyC_Check(o))TY(10);if(PyObject_CheckBuffer(o))TY(24);
                              CH(Tuple,41)CH(List,42)CH(Callable,100)CH(Sequence,40)CH(Dict,99)CH(Mapping,101)CH(Type,21)CH(Iter,45)CH(Set,46)TY(50)O0(r)}//for a foreign, x, return a list of shorts indicating the foreign's type
Z K1(key){Oo;Co(Mapping)Ro(PyMapping_Keys(o))}//return the keys of a dictionary, x
Z K1(value){Oo;Co(Mapping)Ro(PyMapping_Values(o))}//return the values of a dictionary, x
 K dim(O o){A a=(A)o;I n=PyArray_NDIM(a);K x=ktn(KJ,n);DO(n,xJ[i]=PyArray_DIMS(a)[i]);R x;}
Z K1(getarraydims){Oo;Co(Array)O0(dim(o));}//for an array, return an array of "j" describing the dims (or shape) of x
 K arr(O o,J m,J n){A a=(A)o;I t=npyt(PyArray_TYPE(a));P(!t,E(type))I z=zh[t];P(m<0,E(index));P(n<0||PyArray_NBYTES(a)<z*(m+n),E(length))K x=ktn(t,n);memcpy(xG,PyArray_DATA(a)+m*z,n*z);R x;}
Z K3(getarray){Oo;Co(Array)P(y->t!=-KJ||z->t!=-KJ,E(type))O0(arr(o,y->j,z->j));}//for an array, x, return a q list
Z K1(get){P(xt!=-KS,E(type));O o=PyDict_GetItemString(d,xs);P(o,(Py_INCREF(o),ko(o)))R E(item);}//get a python variable named by x (symbol) in the __main__ module
Z K getcf(H x,K y){K t=kK(y)[0],f=kK(y)[1];P(KH!=t->t,E(type))P(0!=f->t,E(type))H* ts=kH(t);DO(t->n,if(x==ts[i])R r1(kK(f)[i]);)R kg(0);} // get conversion func from y given type x
Z K2(uq2py){K a,t;t=dot(y,a=knk(1,r1(x)));R r0(a),r0(y),t;} // convert using conv K y, allow anything as a conversion function
// if restricting to funcs projection etc
//SW(y->t){ 
//case 100:case 101:case 104:case 105:case 107:t=dot(y,a=knk(1,r1(x)));R r0(a),r0(y),t; // lambda,primitive,proj,composition,f/
//case 112:if(1!=y->u)R r0(y),E(rank);t=dot(y,a=knk(1,r1(x)));R r0(a),r0(y),t;CD:R r0(y),E(type);}}
Z O q2pyo(K x,K y){ // single level of conversion through c, recursion can use conversions in y
 P(pq(x),kget(x))P(gnull(x),Py_None)
 P(xt<0,-128==xt?rr2o(x):-KB==xt?b2o(x):-KG>=xt&&-KJ<=xt?j2o(x):-KE==xt||-KF==xt?f2o(x):-KC==xt?c2o(x):-KS==xt?s2o(x):Py_None);
 P(!xt||xt==XT,otup_cf(x,y)) 
 SW(xt){CS(KG,R G2o(x))CS(KC,R C2o(x))CS(KS,R otup_cf(x,y))CS(XD,R odict_cf(x,y))CS(100,R ocall(x))CD:R a2o(x);}R Py_None;} 
Z K2(q2pyc){R ko(q2pyo(x,y))?:PE;} // convert using c, pass through user conversions for dicts/tuples, 
Z K2(q2py){P(99!=y->t,E(type))P(pq(x),r1(x));K cf=getcf(xt,y);R -128==cf->t?cf:-KG==cf->t?(r0(cf),q2pyc(x,y)):uq2py(x,cf);} // override defaults with user provide conversions
/* if using dot and dict lookup use this TODO how big for dot(y,xtype) (maybe with attrs on y) faster than getcf?
Z K2(q2py){P(99!=y->t,E(type))P(112==xt,x);K a,cf;cf=dot(y,a=knk(1,kh(xt)));r0(a);R -128==cf->t?cf:gnull(cf)?(r0(cf),q2pyc(x,y)):uq2py(x,cf);} */
Z K1(init){P(Py_IsInitialized(),0);if(RP)Py_SetPythonHome(PH);Py_Initialize();PySys_SetArgvEx(0,0,0);d=PyModule_GetDict(M=PyImport_AddModule("__main__"));m=ko(M);dyl(DY);import_array1(E(numpy));R 0;}
#define sdl(f,n) (js(&x,ss(#f)),jk(&y,dl(f,n)));
K1(lib){K y=ktn(0,0);init(x);x=ktn(KS,0);sdl(runs,2)sdl(set,2)sdl(import,1)sdl(getattr,2)sdl(call,3)sdl(repr,1)sdl(getseq,1)sdl(getb,1)sdl(getnone,1)sdl(getj,1)sdl(getf,1)sdl(getG,1)sdl(getC,1)sdl(j2py,1)sdl(f2py,1)sdl(null2py,1)sdl(G2py,1)sdl(a2py,1)sdl(fs2py,1)sdl(lambda2py,1)sdl(dict2py,1)sdl(rr2py,1)sdl(q2py,2)sdl(key,1)sdl(value,1)sdl(type,1)sdl(getarraydims,1)sdl(getarray,3)sdl(getbuffer,1)sdl(get,1)R xD(x,y);}
