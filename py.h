#include<stdio.h>
#include<wchar.h>
#include<string.h>
#include<stdlib.h>
#if _WIN32
#include<windows.h>
typedef LONG_PTR L;
#define __thread __declspec(thread)
#define EXP __declspec(dllexport)
#else
#include<dlfcn.h>
typedef ssize_t L;
#define EXP
#endif
#define KXVER 3
#include"k.h"
#define K3(f) K f(K x,K y,K z)

typedef struct _p _p,*P;struct _p{L r;P t;L n;union{P*p;P v[1];};};typedef struct{L r;P t;G*g;I n;L*c,*s;P*b;struct{L r;P t;P*o;C k,c,b,f;I n,e;}*d;I f;}*A;typedef struct{S n;V*m;I f;S d;}D;
#define ZP Z P

//https://docs.python.org/3/c-api/ https://github.com/python/cpython/blob/3.6/PC/python3.def
#define PF \
 X(V,Py_InitializeEx,(I))\
 X(V,Py_Finalize,())\
 X(V,Py_DecRef,(P))\
 X(V,Py_IncRef,(P))\
 X(V,PyErr_Clear,())\
 X(V,PyErr_Fetch,(P*,P*,P*))\
 X(V,PyErr_NormalizeException,(P*,P*,P*))\
 X(P,PyErr_BadArgument,())\
 X(P,PyErr_SetString,(P,S))\
 X(I,PyGILState_Ensure,())\
 X(V,PyGILState_Release,(I))\
 X(I,PyGILState_Check,())\
 X(V,PyEval_InitThreads,())\
 X(I,PyEval_ThreadsInitialized,())\
 X(V*,PyGILState_GetThisThreadState,())\
 X(V*,PyEval_SaveThread,())\
 X(V,PyEval_RestoreThread,(V*))\
 X(_p,PyExc_RuntimeError,)\
 X(P,PyObject_Str,(P))\
 X(wchar_t*,Py_DecodeLocale,(S,V*))\
 X(V,Py_SetPythonHome,(wchar_t*))\
 X(V,Py_SetProgramName,(wchar_t*))\
 X(P,PyImport_AddModule,(S))\
 X(P,PyImport_ImportModule,(S))\
 X(P,PyObject_GetAttrString,(P,S))\
 X(P,PyObject_Call,(P,P,P))\
 X(P,PyObject_Type,(P))\
 X(P,PyModule_GetDict,(P))\
 X(P,PyDict_GetItemString,(P,S))\
 X(P,PyDict_SetItemString,(P,S,P))\
 X(P,PyEval_EvalCode,(P,P,P))\
 X(P,Py_CompileString,(S,S,I))\
 X(P,PyCapsule_New,(V*,S,V*))\
 X(V*,PyCapsule_GetPointer,(P,S))\
 X(P,PyCFunction_NewEx,(D*,P,P))\
 X(_p,_Py_TrueStruct,)\
 X(_p,_Py_FalseStruct,)\
 X(_p,_Py_NoneStruct,)\
 X(_p,PyLong_Type,)\
 X(_p,PyFloat_Type,)\
 X(_p,PyTuple_Type,)\
 X(_p,PyList_Type,)\
 X(_p,PyDict_Type,)\
 X(_p,PyUnicode_Type,)\
 X(_p,PyBytes_Type,)\
 X(I,PyType_IsSubtype,(P,P))\
 X(J,PyLong_AsLongLongAndOverflow,(P,I*))\
 X(F,PyFloat_AsDouble,(P))\
 X(S,PyUnicode_AsUTF8AndSize,(P,L*))\
 X(I,PyBytes_AsStringAndSize,(P,S*,L*))\
 X(P,PyBool_FromLong,(long))\
 X(P,PyLong_FromLongLong,(J))\
 X(P,PyFloat_FromDouble,(F))\
 X(P,PyUnicode_FromStringAndSize,(S,L))\
 X(P,PyUnicode_FromString,(S))\
 X(P,PyBytes_FromStringAndSize,(S,L))\
 X(P,PySequence_List,(P))\
 X(P,PyTuple_New,(L))\
 X(P,PyList_New,(L))\
 X(P,PyDict_New,())\
 X(P,PyDict_SetItem,(P,P,P))\
 X(P,PyDict_Keys,(P))\
 X(P,PyDict_Values,(P))\
 X(P,PyObject_CallFunctionObjArgs,(P,...))\
 X(P,PyImport_Import,(P))\
 X(I,Py_IsInitialized,())\

//https://docs.scipy.org/doc/numpy/reference/c-api.html https://github.com/numpy/numpy/blob/master/numpy/core/code_generators/numpy_api.py
#undef PyCFunction_New
#define PyCFunction_New(x,y) PyCFunction_NewEx(x,y,NULL)
#define NF \
 X(_p,PyArray_Type,,2)\
 X(_p,PyGenericArrType_Type,,10)\
 X(A,PyArray_NewCopy,(A,I),85)\
 X(A,PyArray_New,(P,I,L*,I,L*,V*,I,I,P),93)\
 X(I,PyArray_SetBaseObject,(A,P),282)\
 X(A,PyArray_FromScalar,(P,P),61)\

#define X(r,n,a,...) typedef r T##n;Z T##n(*n)a;
PF NF
#undef X

ZI ta(A a){I c[]={KB,-1,KG,KH,-1,KI,-1,4==sizeof(long)?KI:KJ,-1,KJ,-1,KE,KF,-1,-1,-1,-1,0,-1,-1,-1},t=a->d->n;R t>20?-1:c[t];}
ZI tk(K x){I c[]={-1,0,-1,-1,-1,3,5,9,11,12,-1,-1,9,5,5,12,9,5,5,5},t=xt>0?xt:-xt;R t>19?-1:c[t];}

ZI pyl(S l){
#if _WIN32
 HMODULE d=LoadLibrary(l);
#define X(r,n,a) U(n=(T##n(*)a)GetProcAddress(d,#n))
#else
 V*d=dlopen(getenv("UNDER_PYTHON")?NULL:l,RTLD_NOW|RTLD_GLOBAL);
#define X(r,n,a) U(n=dlsym(d,#n))
#endif
 P(!d,0)PF
#undef X
 R 1;}

#define BUFFSIZE 4096

ZI pyn(V**v){
#define X(r,n,a,i) U(n=(T##n(*)a)v[i])
 NF
 R 1;}
#ifdef __clang__
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
#pragma clang diagnostic ignored "-Wunused-parameter"
#elif __GNUC__
#ifndef __arm__
#if __GNUC__ >= 5
#pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
#endif
#endif
#endif
