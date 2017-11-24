# embedPy

Allows the kdb+ interpreter to manipulate Python objects and call Python functions.


## Status

The embedPy library is still in development. If you would like to participate in the beta tests, please write to ai@kx.com. 


## Requirements

- KDB+ >=3.5 64-bit
- Python 3.x
- Mac/Linux 


## Build and installation

Build the interface and run sanity checks with 

```bash
./configure && make test
```
If running in an environment without Internet access, you will need to download the kdb+ [C API header file](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h) manually and place in the build directory.

Install by placing `p.q` in `$QHOME` and `p.so` in `$QHOME/{l64|m64}`.  

**NB** If you are currently using PyQ, it also has a file called p.so, which it places in `$QHOME/{l64|m64}`. In this case, you may want to initially run from the local build directory without installing.

## Example usage

### Running the examples

In each of the code snippets below, we assume that `p.q` has been loaded into a running q console with 
```q
q)\l p.q
```


### Executing Python code

The interface allows execution of Python code directly in a q console or from a script. In both the console and scripts, Python code should be prefixed with a `p)` prompt
```q
q)p)print(1+2)
3
```
Multiline Python code can be loaded and executed using q scripts (but not from the console). Prefix the first line of the code with `p)` and indent subsequent lines of Python code according to the usual Python indentation rules. e.g.
```bash
$ cat test.q
a:1                   / q code
p)def add1(arg1):     # Python code
    return arg1+1     # still Python code
```
Then in a q session
```q
q)\l test.q
q)p)print(add1(12))
13
```
Full scripts of Python code can be executed in q, using the `.p` file extension (not `.py`). The script is loaded as usual.
```
$ cat hq.p 
print("Hello q!")
```
```q
q)\l hq.p
Hello q!
```


### Evaluating Python code
To evaluate Python code (as a string) and return results to q, use `.p.qeval`.  
```q
q).p.qeval"1+2"
3
```
**NB** Python evaluation (unlike Python _execution_) does not allow side effects. Thus, any attempt at variable assignment or class definition, will result in an error. To execute a string performing side effects,  you should use `.p.e`. A more detailed explanation of the difference between `eval` and `exec` in Python can be found [here](https://stackoverflow.com/questions/2220699/whats-the-difference-between-eval-exec-and-compile-in-python)


### foreign objects

At the lowest level, Python objects are represented in q as `foreign` objects, which contain pointers to objects in the Python memory space.

Foreign objects can be stored in variables just like any other q datatype, or as part of lists, dictionaries or tables. They will display `foreign` when inspected in the q console or using the `string` (or `.Q.s`) representation. 

**NB** Foreign object types cannot be serialized by kdb+ or sent over IPC: they live in the embedded Python memory space. To pass these objects over IPC, we must first convert them to q.


### embedPy objects

Foreign objects cannot be directly operated on in q. Instead, Python objects should be represented as `embedPy` objects, which wrap the underlying `foreign` objects, and provide users with the ability to
- Get attributes/properties
- Set attributes/properties
- Call functions/methods
- Convert data to q/foreign

By default, calling an `embedPy` function/method, will return another `embedPy` object. This allows users to chain together sequences of operations.  
Alternatively, users can explicitly specify the return type as q or foreign.

`embedPy` objects are retrieved from Python using one of the following calls

#### .p.import
Symbol arg- the name of a Python module or package to import  
e.g. ``.p.import`numpy``
#### .p.get
Symbol arg- the name of a Python variable in `__main__`
- ``.p.get`varName``
#### .p.eval
String arg- the Python code to evaluate
- ``.p.eval"1+1"``  

**NB** As with other Python evaluation functions, .p.eval does not permit side effects


### embedPy API

Given `obj`, an embedPy object, we can carry out the following operations
```q
obj`                  / get data (as q)
obj`.                 / get data (as foreign)
obj`attr              / get attribute/property (as embedPy)
obj`attr1.attr2       / get attribute/property at depth (as embedPy)
obj[:;`attr;val]      / set attribute/property

obj[`method][*]       / define obj.method callable (returning embedPy)
obj[`method;*]        / equivalent
obj[`method][*]arg    / call obj.method (returning embedPy)
obj[`method;*]arg     / equivalent
obj[`method;*;arg]    / equivalent

obj[`method][<]       / define obj.method callable (returning q)
obj[`method;<]        / equivalent
obj[`method][<]arg    / call obj.method (returning q)
obj[`method;<]arg     / equivalent
obj[`method;<;arg]    / equivalent

obj[`method][>]       / define obj.method callable (returning foreign)
obj[`method;>]        / equivalent
obj[`method][>]arg    / call obj.method (returning foreign)
obj[`method;>]arg     / equivalent
obj[`method;>;arg]    / equivalent
```
We can chain operations together and combine them with `.p.import`, `.p.get` and `.p.eval`.

### embedPy examples

Some examples
```q
$ cat test.p # used for tests
class obj:
    def __init__(self,x=0,y=0):
        self.x = x # attribute
        self.y = y # property (incrementing on get)
    @property
    def y(self):
        a=self.__y
        self.__y+=1
        return a
    @y.setter
    def y(self, y):
        self.__y = y
    def total(self):
        return self.x + self.y
```
```
q)\l test.p
q)obj:.p.get[`obj;*][]
q)obj[`x]`
0
q)obj[;`]each 5#`x
0 0 0 0 0
q)obj[:;`x;10]
q)obj[`x]`
10
q)obj[`y]`
0
q)obj[;`]each 5#`y
1 2 3 4 5
q)obj[:;`y;10]
q)obj[;`]each 5#`y
10 11 12 13 14
q)tot:obj[`total;<]
q)tot[]
25
q)tot[]
26
```
```
q)np:.p.import`numpy
q)v:np[`arange;*;12]
q)v`
0 1 2 3 4 5 6 7 8 9 10 11
q)v[`mean;<][]
5.5
q)rs:v[`reshape;<]
q)rs[3;4]
0 1 2  3 
4 5 6  7 
8 9 10 11
q)rs[2;6]
0 1 2 3 4  5 
6 7 8 9 10 11
q)np[`arange;*;12][`reshape;*;3;4]`
0 1 2  3 
4 5 6  7 
8 9 10 11
q)np[`arange;*;12][`reshape;*;3;4][`T]`
0 1  2 
3 4  5 
6 7  8 
9 10 11
```
```
q)stdout:.p.import[`sys;`stdout.write;*]
q)stdout"hello\n";
hello
q)stdout"goodbye\n";
goodbye
```
```
q)oarg:.p.eval"10"
q)oarg`
10
q)ofunc:.p.eval["lambda x:2+x";<]
q)ofunc 1
3
q)ofunc oarg
12
q)p)def add2(x,y):return x+y
q)add2:.p.get[`add2;<]
q)add2[1;oarg]
11
```


### Setting Python variables

Variables can be set in Python `__main__` using `.p.set`
```q
q).p.set[`var1;42]
q).p.qeval"var1"
42
```


### None and identity

Python `None` maps to the q identity function `::` when converting from Python to q (and vice versa).

There is one important exception to this. When calling Python functions, methods or classes with a single q data argument, passing `::` will result in the Python object being called with _no_ arguments, rather than a single argument of `None`. See the section below on callables for how to explicitly call a Python callable with a single `None` argument. 


### Function calls

Python allows for calling functions with 
- A variable number of arguments
- A mixture of positional and keyword arguments
- Implicit (default) arguments

All of these features are available through the embedPy function-call interface.  
Specifically
- Callable `embedPy` objects are variadic
- Default arguments are applied where no explicit arguments are given
- Individual keyword arguments are specified using the (infix) `pykw` operator
- A list of positional arguments can be passed using `pyarglist` (like Python *args)
- A dictionary of keyword arguments can be passed using `pykwargs` (like Python *kwargs)

n.b. We can combine positional arguments, lists of positional arguments, keyword arguments and a dictionary of keyword arguments. However, _all_ keyword arguments must always follow _any_ positional arguments and the dictionary of keyword arguments (if given) must be specified last.


### Example function calls
```q
q)p)def func(a=1,b=2,c=3,d=4):return (a,b,c,d,a*b*c*d)
q)qfunc:.p.get[`func;<] / callable, returning q
```
Positional arguments are entered directly.  
Function calling is variadic, so later arguments can be excluded.
```q
q)qfunc[2;2;2;2]   / all positional args specified
2 2 2 2 16
q)qfunc[2;2]       / first 2 positional args specified
2 2 3 4 48
q)qfunc[]          / no args specified
1 2 3 4 24
q)qfunc[2;2;2;2;2] / error if too many args specified
TypeError: func() takes from 0 to 4 positional arguments but 5 were given
'p.c:73 call pyerr
```
Individual keyword arguments can be specified using the `pykw` operator (with infix notation).  
Keyword arguments must follow positional arguments but, otherwise, the order of keyword arguments does not matter.
```q
q)qfunc[`d pykw 1;`c pykw 2;`b pykw 3;`a pykw 4] / all keyword args specified
4 3 2 1 24
q)qfunc[1;2;`d pykw 3;`c pykw 4]   / mix of positional and keyword args
1 2 4 3 24
q)qfunc[`a pykw 2;`b pykw 2;2;2]   / error if positional args after keyword args
'keywords last
q)qfunc[`a pykw 2;`a pykw 2]       / error if duplicate keyword args
'dupnames
```
A list of positional arguments can be specified using `pyarglist` (similar to Python's *args).  
Again, keyword arguments must follow positional arguments.
```q
q)qfunc[pyarglist 1 1 1 1]          / full positional list specified
1 1 1 1 1
q)qfunc[pyarglist 1 1]              / partial positional list specified
1 1 3 4 12
q)qfunc[1;1;pyarglist 2 2]          / mix of positional args and positional list
1 1 2 2 4
q)qfunc[pyarglist 1 1;`d pykw 5]    / mix of positional list and keyword args
1 1 3 5 15
q)qfunc[pyarglist til 10]           / error if too many args specified
TypeError: func() takes from 0 to 4 positional arguments but 10 were given
'p.c:73 call pyerr
q)qfunc[`a pykw 1;pyarglist 2 2 2]  / error if positional list after keyword args
'keywords last
```
A dictionary of keyword arguments can be specified using `pykwargs` (similar to Python's **kwargs).  
If present, this argument must be the _last_ argument specified.
```q
q)qfunc[pykwargs`d`c`b`a!1 2 3 4]             / full keyword dict specified
4 3 2 1 24
q)qfunc[2;2;pykwargs`d`c!3 3]                 / mix of positional args and keyword dict
2 2 3 3 36
q)qfunc[`d pykw 1;`c pykw 2;pykwargs`a`b!3 4] / mix of keyword args and keyword dict
3 4 2 1 24
q)qfunc[pykwargs`d`c!3 3;2;2]                 / error if keyword dict not last   
'pykwargs last
q)qfunc[pykwargs`a`a!1 2]                     / error if duplicate keyword names
'dupnames
```
All 4 methods can be combined in a single function call, as long as the order follows the above rules.  
In practice, this makes for messy code.
```q
q)qfunc[4;pyarglist enlist 3;`c pykw 2;pykwargs enlist[`d]!enlist 1]    
4 3 2 1 24
```

### Zero argument calls

In q, every function takes at least one argument. Even a niladic function, called with `func[]`, is passed the identity function `::` as an argument. In embedPy, if a function is called with `::` as the only argument, the underlying Python function will be called with _no_ arguments.  
As we noted above `::` in q maps to `None` in Python, however in Python these two calls are not equivalent:
```
func()
func(None)
```
If you need to call a Python function with `None` as the sole argument, you can retrieve `None` as a foreign object and pass that as the argument to a q function. e.g.
```q
q)pynone:.p.eval"None"
q).p.eval["print";*;pynone];
None
```


### Dictionary keys and values

Python dictionaries, when converted to q, will yield q dictionaries (and vice versa).
```q
q)p)pyd={'one':1,'two':2,'three':3}
q)qd:.p.get`pyd
q)qd`
one  | 1
two  | 2
three| 3
q).p.eval["print";<]qd
{'one': 1, 'two': 2, 'three': 3}
```
Functions are also provided to retrieve the keys and values directly from an `embedPy` dictionary, without performing the conversion to a q dictionary. 

- `.p.key` will return the keys
- `.p.value` will return the values

In each case, the result will be an `embedPy` object.
```q
q).p.key[qd]`
"one"
"two"
"three"
q).p.value[qd]`
1 2 3
```

### Printing and help

The string representation of a Python (`embedPy` or `foreign`) object, can be accessed using `.p.repr`.  
This representation can be printed to stdout using `.p.print`.
```q
q)x:.p.eval"{'a':1,'b':2}"
q).p.repr x
"{'a': 1, 'b': 2}"
q).p.print x
{'a': 1, 'b': 2}
```
The string representation of Python's _help_ for a Python (`embedPy` or `foreign`) object can be accessed using `.p.helpstr`.
This help can be accessed interactively using `.p.help`.
```q
q)n:.p.eval"42"
q).p.helpstr n
"int(x=0) -> integer\nint(x, base=10) -> integer\n\nConvert a number or strin..
q).p.help n / interactive help
```
**NB** For convenience, p.q defines `print` and `help` in the top-level namespace of q (as aliases for `.p.print` and `.p.help` respectively). To prevent this, comment out the relevant code in p.q before loading
```q
{@[`.;x;:;get x]}each`help`print; / comment to remove from global namespace
```


### Closures

Closures allow us to define functions that retain state between calls.  
We first define a function in q with
- 2+ arguments - the current state and at least one other (possibly dummy) argument
- 2 return values - the new state and the return value

e.g.
```q
q)xtil:{[x;dummy]x,x+:1} / initial state 0; returns 1, 2, 3, 4, ...
q)xrunsum:{x,x+:y} / initial state 0; returns running sum so far
```
We then wrap the function using `.p.closure`, which takes 2 arguments
- The q function
- The initial state value
e.g.
```q
q)ftil:.p.closure[xtil;0][<]
q).p.set[`ftil]ftil
q)ftil[]
1
q)p)print(ftil())
2
q)ftil[]
3
q)p)print(ftil())
4
```
```q
q)runsum:.p.closure[xrunsum;0][<]
q).p.set[`runsum]runsum
q)runsum 2
2
q)p)print(runsum(4))
6
q)runsum -3
3
q)p)print(runsum(7))
10
```


### Generators

Generators allow us to iterate to produce sequences of values. 
We first define a function in q, as per closures (with a single _dummy_ argument following the state argument).

e.g.
```q
q)xfact:{[x;dummy](x;last x:prds x+1 0)} / initial state 0 1; returns 1!, 2!, 3!, 4!, ...
```
We then wrap the function using `.p.generator`, which takes 3 arguments
- The q function
- The initial state value
- The max number of iterations (or `::` to run indefinitely)

e.g.
```q
q)fact4:.p.generator[xfact;0 1;4]     / generates first 4 factorial values
q)factinf:.p.generator[xfact;0 1;::]  / generates factorial values indefinitely
```
The resulting generators can be used as iterators in Python.

e.g.
```q
q).p.set[`fact4]fact4
q).p.e"for x in fact4:print(x)"
1
2
6
24
q).p.set[`factinf]factinf
q).p.e"for x in factinf:\n print(x)\n if x>1000:break"  / force break to stop iteration
1
2
6
24
120
720
5040
```


### Raw (foreign) data

`foreign` objects are retrieved from Python using one of the following calls

#### .p.pyimport
Symbol arg- the name of a Python module or package to import  
e.g. ``.p.pyimport`numpy``
#### .p.pyget
Symbol arg- the name of a Python variable in `__main__`
- ``.p.pyget`varName``
#### .p.pyeval
String arg- the Python code to evaluate
- ``.p.pyeval"1+1"`` 


### Raw (foreign) API

A number of low level functions are provided to act directly on `foreign` objects.

#### Converting data 

Function `.p.py2q` will attempt to convert Python (`foreign`) data to q
```q
q)qvar:.p.pyget`var1
q).p.py2q qvar
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 ..
```
Corresponding function `.p.q2py` converts q objects to Python objects  
```q
q).p.q2py 1 2 3
foreign
```
This will rarely be used in practice, as conversion of q data to Python objects is performed automatically whenever q data is passed to Python.


#### Function calls

A `foreign` object (representing a callable Python object) can be made callable in q with `.p.call`.  
`.p.call` will return a q function, taking 2 arguments.
- a list of positional arguments
- a dictionary of keyword arguments

Either of these arguments can be empty.

The result of calling this function, will be another `foreign`.  
e.g.
```q
q)p)def f4(a,b,c,d):return (a*b,c*d)
q).p.py2q .p.call[.p.pyget`f4;1 2;`d`c!4 3]
2 12
```


#### Getting attributes/properties

Function `.p.getattr ` will get an attribute/property from a `foreign` object.  The result will be another `foreign`.
```
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


#### Setting attributes/properties

Function `.p.setattr ` will set an attribute/property on a `foreign` object.

```q
q).p.setattr[obj;`x;10]
q).p.setattr[obj;`y;20]
q).p.py2q .p.getattr[obj]`x
10
q).p.py2q .p.getattr[obj]`y
20
```


#### Dictionary keys and values

Functions are provided to retrieve the keys and values directly from a `foreign` dictionary, without performing the conversion to a q dictionary. 

- `.p.pykey` will return the keys
- `.p.pyvalue` will return the values

In each case, the result will be a `foreign` object.
```q
q)d:.p.pyeval"{'key1':1,'key2':2}"
q).p.py2q d
key1| 1
key2| 2
q).p.py2q .p.pykey d
"key1"
"key2"
q).p.py2q .p.pyvalue d
1 2
```


### Further examples 

You’ll find further examples in the [examples](examples) directory. This includes an example of creating simple charts in Matplotlib either by running Python code in a kdb+ process, or importing the `matplotlib.pyplot` module into kdb+ and using functions from it in q code.
 

### `.p` directory reference 

name                 | description                                                                                                                             
---------------------|-----------------------------------------------------------------------------------------------------------------------------------------
`.p.e`               | evaluate string as Python code, used for the p language, returns `::`
`.p.eval`            | evaluate string as Python code and return result as embedPy
`.p.qeval`           | evaluate string as Python code and return result as q
`.p.pyeval`          | evaluate string as Python code and return result as foreign
`.p.set`             | set a variable in Python `__main__` , `x - symbol`, `y - any q object`
`.p.import`          | import a module `x - symbol`
`.p.get`             | get value of `x - symbol` from Python `__main__`
`.p.py2q`            | convert Python object `foreign` to q, conversion is based on the function in `conv` for the first `.p.type` of a Python object
`.p.q2py`            | convert a q object to a Python object `foreign`
`.p.pyattr`          | get attribute `y - symbol` from Python object `x - foreign`, i.e. `x.y`, returns as a `foreign`
`.p.key`             | keys of a Python dictionary
`.p.value`           | values of a Python dictionary
`.p.type`            | type of a Python object
`.p.printpy`         | print a Python object's string representation
`.p.help`            | display help on Python objects as `foreign` and the underlying Python object for `callables`, `pycallables` and dictionaries created using `.p.obj2dict`
`.p.helpstr`         | give the docstring for Python objects and the underlying Python object for `callables`, `pycallables` and dictionaries created using `.p.obj2dict`
`.p.arraydims`       | give the shape of `x - foreign` a numpy multi-dimensional array.
`.p.callable`        | create a callable q function from a Python callable object `x - foreign` the function will convert results to q when subsequently called
`.p.pycallable`      | create a callable q function from a Python callable object `x - foreign` the function will return `foreign` when subsequently called
`.p.qgenfunc`        | produce a Python generator from `x - q projection` which will yield `y - integer` times
`.p.qgenfuncinf`     | produce a Python generator from `x - q projection` which will yield indefinitely 
`.p.q2pargs`         | internal, used to interpret parameters passed to callables
`.p.repr`            | string representation of `foreign`
`.p.pykw`            | identify a parameter as a keyword parameter for callables, see examples, also present in `.q` namespace to allow infix notation and prevent assignment in top level namespace
`.p.pyarglist`       | identify a parameter as a list of positional parameters for callables, see examples, also present in `.q` namespace to prevent assignment in top level namespace
`.p.pykwargs`        | identify a parameter as a dictionary of keyword argument names to values, see examples, also present in `.q` namespace to prevent assignment in top level namespace
`.p.call`            | used internally by `.p.callable` and `.p.pycallable`
`.p.conv`            | dictionary of Python type identifier `short` to the conversion function used by `py2q`
`.p.c`               | compose a list of functions
`.p.ce`              | compose a list of functions with `enlist` appended to the end of the list
`.p.i`               | internal functions and objects 
