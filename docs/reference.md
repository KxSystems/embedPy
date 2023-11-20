# Reference for embedPy



## Raw (foreign) data

Foreign objects are retrieved from Python using one of the unary functions.

function    | argument                                        | example
------------|-------------------------------------------------|--------------
.p.pyimport | symbol: name of a Python module or package      | ``.p.pyimport`numpy``
.p.pyget    | symbol: name of a Python variable in `__main__` | ``.p.pyget`varName``
.p.pyeval   | string: Python code to evaluate                 | `.p.pyeval"1+1"`


## Raw (foreign) API

Some low-level functions act directly on foreign objects.


### Convert data 

Function `.p.py2q` attempts to convert Python (`foreign`) data to q

```q
q)qvar:.p.pyget`var1
q).p.py2q qvar
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 ..
```

If an object cannot be converted to q, a `foreign` is returned

```q
q)p)from numpy import eye
q)eye:.p.pyeval"eye"
q).p.py2q eye
foreign
```

:warning: The conversion to q is recursive.

```q
q)p)from numpy import arange, eye
q)p)r1=arange(10)
q)p)r2=arange(12)
q)obj:.p.pyeval"(r1,r2)"
q).p.py2q obj
0 1 2 3 4 5 6 7 8 9
0 1 2 3 4 5 6 7 8 9 10 11
q)eyetuple:.p.pyeval"(eye,eye)"
q).p.py2q eyetuple
foreign
foreign
```

Complementary function `.p.q2py` converts q objects to Python objects  

```q
q).p.q2py 1 2 3
foreign
```

This is rarely needed, q data is converted automatically when it is passed to Python.


### Function calls

A foreign object, representing a callable Python object, can be made callable in q with `.p.call`.  

`.p.call` will return a q function, taking 2 arguments:

-   a list of positional arguments
-   a dictionary of keyword arguments

Either of these arguments can be empty, a generic empty list for the first and an empty dictionary for the second

The result of calling this function, will be another foreign object.  

```q
q)p)def f4(a,b,c,d):return (a*b,c*d)
q).p.py2q .p.call[.p.pyget`f4;1 2;`d`c!4 3]
2 12
```


### Getting attributes/properties

Function `.p.getattr ` gets an attribute or property from a foreign object.  The result is another foreign.

```bash
$ cat class.p 
class obj:
    def __init__(self,x=0,y=0):
        self.x = x
        self.y = y
```

```q
q)\l class.p
q)obj:.p.call[.p.pyget`obj;2 3;()!()]
q)obj
foreign
q).p.py2q .p.getattr[obj]`x
2
q).p.py2q .p.getattr[obj]`y
3
```


### Setting attributes and properties

Function `.p.setattr ` will set an attribute or property of a foreign object.

```q
q).p.setattr[obj;`x;10]
q).p.setattr[obj;`y;20]
q).p.py2q .p.getattr[obj]`x
10
q).p.py2q .p.getattr[obj]`y
20
```


## `.p` namespace 

object             | description                                                                                                                             
-------------------|-----------------------------------------------------------------------------------------------------------------------------------------
.p.call            | calls function `x` with positional args `y - list` and keyword args `z - dict`
.p.closure         | create closure with q function `x` and initial state `y`
.p.e               | evaluate `x- string` as Python code (used for the `p)` language)
.p.eval            | evaluate `x- string` as Python code and return result as embedPy
.p.generator       | create generator with q function `x`, initial state `y` and the max number of iterations `z` (`::` to run indefinitely)
.p.get             | get `x - symbol` from Python `__main__`  and return result as embedPy
.p.getattr         | get attribute `y - symbol` from `x - foreign`
.p.help            | interactive help on `x`
.p.helpstr         | get docstring for `x` as q-string
.p.i               | internal functions and objects 
.p.import          | import module `x - symbol` and return result as embedPy
.p.py2q            | convert `x - foreign` to q
.p.pycallable      | make `x` a callable embedPy object, which will return foreign results
.p.pyeval          | evaluate `x - string` as Python code and return result as foreign
.p.pyfunc          | make `x - foreign` a callable function, which will return foreign results
.p.pyget           | get `x - symbol` from Python `__main__`  and return result as foreign
.p.pyimport        | import module `x - symbol` and return result as foreign
.p.q2py            | convert `x - q` to foreign
.p.qcallable       | make `x` a callable embedPy object, which will return q results
.p.qeval           | evaluate `x- string` as Python code and return result as q
.p.repr            | get string representation of `x` as q-string
.p.set             | set `x - symbol` variable in Python `__main__` , with value `y`
.p.setattr         | set attribute `y - symbol` from `x - foreign` with value `z`
.p.unwrap          | unwrap `x` and return result as foreign
.p.wrap            | wrap `x -foreign` and return result as embedPy
.p.c               | [internal] compose a list of functions
.p.ce              | [internal] compose a list of functions with `enlist` appended to the end
.p.embedPy         | [internal] defines embedPy API
.p.q2pargs         | [internal] interpret parameters (positional and pykw/pyarglist/pykwargs) for passing to callables



