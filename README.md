# embedPy

Allows the kdb+ interpreter to call Python functions.


## Status

This library is still in development.  
If you would like to participate in the beta tests, please write to ai@kx.com. 


## Build and installation

Build the interface and run sanity checks with 

```bash
./configure && make test
```
If you are running in an environment without Internet access, you will need to download the kdb+ [C API header file](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h) manually and place it in the directory that you are building from.

Install by placing `p.q` in `$QHOME` and `p.so` in `$QHOME/{l64|m64}`.  

**NB** If you are currently using PyQ, it also has a file called p.so, which it places in `$QHOME/{l64|m64}`. In this case, you may want to initially run from the local build directory without installing.

`p.q` defines the `.p` directory, which includes a `.p.e` function. This allows Python statements to be run from a `p)` prompt.


## Example usage

### Running the examples

In each of the code snippets below, we assume that `p.q` has been loaded into a running q console with 
```q
q)\l p.q
```


### Executing Python code ###

The interface allows execution of Python code directly in a q console or from a script. In both the console and scripts, Python code should be prefixed with `p)`  
```q
q)p)print(1+2)
3
```
Multiline Python code can be loaded and executed using q scripts (but not from the console). Prefix the first line of the code with `p)` and indent subsequent lines of Python code according to the usual Python indentation rules. e.g.
```bash
$ cat test.q
a:1                   / q code
p)def add1(arg1):     / Python code
    return arg1+1     / still Python code
```
Then in a q session
```q
q)\l test.q
q)p)print(add1(12))
13
```


### The foreign datatype

Python objects that have not been explicitly converted to q data, are stored as `foreign` datatype objects. These contain pointers to objects in the Python memory space, and will display `foreign` when inspected in the q console or using the `string` (or `.Q.s`) representation.

Foreign objects can be stored in variables just like any other q datatype, or as part of lists, dictionaries or tables.

**NB** Foreign object types cannot be serialized by kdb+ and sent over IPC: they live in the embedded Python memory space. If you need to pass these objects to other processes over IPC, then you must first convert them to q.


### Evaluating code
To execute Python code (as a string) and return results to q, use either `.p.eval` or `.p.pyeval`. 
```q
q).p.eval"1+2"
3
q).p.pyeval"1+2"
foreign
```
Note the difference in the two results here: 
-   `.p.eval` will attempt to convert the Python result of the statement to a q result; 
-   `.p.pyeval` will return the result as a Python (`foreign`) object, without any attempt at conversion. The result can be stored in a variable for use later, passed back to Python, examined using another `.p` function, or converted to q data.


### Getting and setting Python variables

Variables in Python `__main__` can be set using `.p.set` and retrieved using `.p.get`
```q
q).p.set[`var1;til 100]
q).p.eval"len(var1)"
100
q)qvar:.p.get[`var1]
q)qvar
foreign
```
**NB** Like `.p.eval`, `.p.get` will not automatically convert Python objects to q data.


### Converting data 

Function `.p.py2q` will attempt to convert Python (`foreign`) data to q
```q
q)qvar:.p.get[`var1]
q).p.py2q qvar
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 ..
```
Corresponding function `.p.q2py` converts q objects to Python objects  
```q
q).p.q2py 1 2 3
foreign
```
This will rarely be used in practice, as conversion of q data to Python objects is performed automatically whenever q data is passed to Python.

It is safe to call `.p.py2q` on q data and `.p.q2py` on Python data: they will return the argument unchanged in these cases.


#### `None` and identity `::` 

Python `None` maps to the q identity function `::` when converting from Python to q and vice versa.

There is one exception to this. When calling Python functions, methods or classes with a single q data argument, passing `::` will result in the Python object being called with _no_ arguments, rather than a single argument of `None`. See the section below on callables for how to explicitly call a Python callable with a single `None` argument. 


### Imports 

Python modules (or objects from modules) can be imported using `.p.import` or `.p.imp`

- `.p.import` imports a Python module
- `.p.imp`    imports an object from a Python module or package 

Each of these functions returns the imported object as `foreign`.
```q
q)np:.p.import`numpy
q).p.attr[np;`BUFSIZE]
8192
q)npversion:.p.imp[`numpy;`version]
q).p.attr[npversion;`full_version]
"1.13.3"
```


### Attributes 

Attributes of Python objects can be retrieved using `.p.attr` or `.p.pyattr`. 
-   `.p.attr` will attempt to convert to a q result
-   `.p.pyattr` will return the result as a Python (`foreign`) object, without any attempt at conversion

```q
p)class AnObject(object):pass     # These lines define a simple object with two attributes
p)anobject=AnObject()
p)anobject.attr1=10
p)anobject.attr2=20
q)qobject:.p.get`anobject         / retrieve the object created 
q).p.attr[qobject;`attr1]         / retrieve the value of attribute attr1 of the object
10
q).p.pyattr[qobject;`attr2]
foreign
```


### Dictionary keys and values

Python dictionaries can be retrieved and converted to q dictionaries.  
Additionally, functions are provided to directly retrieve the keys and values of a `foreign` Python dictionary, without performing the conversion to a q dictionary. 

- `.p.key` will return the keys of a Python dictionary
- `.p.value` will return the values of a Python dictionary

In each case, the result will be a Python (`foreign`) object.

```q
p)dict={'key1':12,'key2':42}
q)qdict:.p.get`dict
q).p.py2q .p.key qdict 
"key1"
"key2"
q).p.py2q .p.value qdict
12 42
```


### Python functions 

Python allows for calling functions with a mixture of positional and keyword arguments. It also supports default arguments, so functions may be called with fewer arguments than are specified in the signature.  
The same behaviour is available for class instantiation through the `__init__` method of classes. 

Both variadic and keyword arguments are available through the function interface.

There are three ways of creating variadic q functions from Python callables, and for each of these a function returning either q data or Python data can be specified 

||returning q|returning Python|
|:---|:---|:---|
|from Python callable|`.p.callable`|`.p.pycallable`|
|from attribute `y` of Python object `x`|`.p.callable_attr`|`.p.pycallable_attr`|
|from content item `y` of Python module name `x`|`.p.callable_imp`|`.p.pycallable_imp`|

In each of the examples below, we create two q functions to call the Python `numpy.eye` function.  
One returns the result as q data and the other returns a Python (`foreign`) object.


#### Getting `numpy.eye` as a `foreign` and creating q functions from it 

```q
q)p)import numpy as np
q)eye:.p.pyeval"np.eye"
q)qeye:.p.callable eye
q)peye:.p.pycallable eye
q)qeye 3
1 0 0
0 1 0
0 0 1
q)peye 3
foreign
```


#### Getting the `numpy` module as a `foreign` and creating q functions from the `eye` function 

```q
q)np:.p.import`numpy
q)qeye:.p.callable_attr[np;`eye]
q)peye:.p.pycallable_attr[np;`eye]
q)qeye 3
1 0 0
0 1 0
0 0 1
q)peye 3
foreign
```


#### Importing the `numpy.eye` function directly and creating q functions 

```q
q)qeye:.p.callable_imp[`numpy;`eye]
q)peye:.p.pycallable_imp[`numpy;`eye]
q)qeye 3
1 0 0
0 1 0
0 0 1
q)peye 3
foreign
```


#### Variable number of arguments 

Python callables with default arguments or a variable number of arguments can be called from q.
```q
q)p)def func(a=1,b=2,c=3,d=4):return a*b*c*d
q)qfunc:.p.callable .p.get`func
q)qfunc[2;2;2;2]             / qfunc called with all arguments specified
16
q)qfunc[2;2]                 / qfunc called with just the first 2 positional arguments specified
48
q)qfunc[2;2;2;2;2]           / error because too many arguments were specified
TypeError: func() takes from 0 to 4 positional arguments but 5 were given
'p.c:72 call pyerr
  [0]  qfunc[2;2;2;2;2]
```
Keyword arguments can be specified using the `pykw` operator.  
Keyword arguments must follow positional arguments, but the order of keyword arguments does not matter.
```q
q)qfunc[1;2;`d pykw 3;`c pykw 4]
24
```
You can also specify
- a list of positional arguments using `pyarglist`
- a dictionary of keyword arguments using `pykwargs`
If a dictionary of keyword arguments is given, it must be the _last_ argument specified.
```q
q)qfunc[pyarglist 1 1 1]
4
q)qfunc[pyarglist 2 2;pykwargs `d`c!3 3]
36
```
You can combine positional arguments, lists of positional arguments, keyword arguments and a dictionary of keyword arguments, but note that _all_ keyword arguments must always follow any positional arguments and that the dictionary of keyword arguments must always be specified last if it is given at all.
```q
q)qfunc[4;pyarglist enlist 3;`d pykw 2;pykwargs (1#`c)!(),2]
48
```


#### Calling functions with zero arguments or `None` 

In q, every function takes at least one argument. Whenever a function is called with `func[]`, the argument passed is the identity function `::`. In embedPy, if a function is called with `::` as the only argument, the underlying Python function will be called with _no_ arguments. As we noted above `::` in q maps to `None` in Python, however in Python these two calls are not equivalent:
```
func()
func(None)
```
If you need to call a Python function with `None` as the sole argument, you can retrieve `None` as a foreign object and pass that as the argument to a q function. e.g.
```q
q)printfunc:.p.callable .p.pyeval"print"
q)pynone:.p.pyeval"None"
q)printfunc[]
q)printfunc pynone
None
```


#### Raw function calls ####

All of the above functions use the `.p.call` function internally. This function can be used directly if you do not need the variadic or keyword argument behavior.  
`.p.call`, when run on a Python callable object, will return a q function taking exactly 2 arguments.
- a list of positional arguments
- a dictionary of keyword argument names to values

Either of these arguments can be empty.

The result of calling this function, will be a `foreign`.
```q
q)p)def f4(a,b,c,d):return (a*b,c*d)
q).p.py2q .p.call[.p.get`f4;1 2;`d`c!4 3]
2 12
```

### Wrapping Python objects as q dictionaries 

It can be useful to extract the contents of a Python object into a q dictionary.  
This allows members of the object to be accessed using dot notation, rather than using `.p.attr/.p.pyattr` each time.

The `.p.obj2dict` function will achieve this. 

**NB** Currently this is not supported for module objects, only for instances of classes in Python.
```q
/ create a numpy mulidimensional array
q)p)import numpy as np
q)array:.p.pyeval"np.reshape(np.arange(24),[2,3,4])"
q)arraywrap:.p.obj2dict array
q)arraywrap
            | ::
_pyobj      | foreign
all         | .[code[foreign]]`.p.q2pargsenlist
any         | .[code[foreign]]`.p.q2pargsenlist
argmax      | .[code[foreign]]`.p.q2pargsenlist
argmin      | .[code[foreign]]`.p.q2pargsenlist
argpartition| .[code[foreign]]`.p.q2pargsenlist
argsort     | .[code[foreign]]`.p.q2pargsenlist
astype      | .[code[foreign]]`.p.q2pargsenlist
byteswap    | .[code[foreign]]`.p.q2pargsenlist
choose      | .[code[foreign]]`.p.q2pargsenlist
clip        | .[code[foreign]]`.p.q2pargsenlist
compress    | .[code[foreign]]`.p.q2pargsenlist
conj        | .[code[foreign]]`.p.q2pargsenlist
conjugate   | .[code[foreign]]`.p.q2pargsenlist
copy        | .[code[foreign]]`.p.q2pargsenlist
cumprod     | .[code[foreign]]`.p.q2pargsenlist
cumsum      | .[code[foreign]]`.p.q2pargsenlist
diagonal    | .[code[foreign]]`.p.q2pargsenlist
dot         | .[code[foreign]]`.p.q2pargsenlist
dump        | .[code[foreign]]`.p.q2pargsenlist
dumps       | .[code[foreign]]`.p.q2pargsenlist
..
```
In this dictionary, the original Python object is stored under the key `_pyobj`, and each method or function and data attribute or property has an entry in the dictionary.

**NB** Attributes preceded by `_` or `__` are not wrapped into the dictionary.


#### Calling functions

Any method or function of a wrapped object has an entry which is a callable q function, with variadic and keyword argument support. Each function will return a `foreign`
```q
q)arraywrap.diagonal[]
foreign
q).p.py2q arraywrap.diagonal[]
0 1
2 3
4 5
6 7
```


#### Getting and setting attributes

For data attributes and properties of wrapped objects, we don’t take a snapshot of the value of the attribute at a point in time, but provide a function to access or set the value of a property from the underlying Python object.
```q
q)qarray:.p.py2q arraywrap._pyobj
q).p.py2q arraywrap.real[]        / get the value of the real attribute
0 1 2  3    4 5 6  7    8 9 10 11  
12 13 14 15 16 17 18 19 20 21 22 23
q)arraywrap.real[:;2*qarray]      / set the value from some q data
q).p.py2q arraywrap.real[]        / get the new value
0  2  4  6  8  10 12 14 16 18 20 22
24 26 28 30 32 34 36 38 40 42 44 46
```


### Printing and help 

The string representation of Python objects (as would be returned from Python’s `repr`) can be accessed using `.p.repr`, and printed to stdout using `.p.printpy`. 

Interactive help on Python objects in the q console is available through `.p.help` and the docstring for a Python object can be retrieved as a string using `.p.helpstr`. (This uses Python's `inspect.getdoc`.)

Both `.p.help` and `.p.helpstr` will also work on q functions created from Python callables using `.p.callable` and objects wrapped using `.p.obj2dict`, in these two cases the help displayed or retrieved will be the Python docstring help on the underlying Python object.

```q
q)pyarray:.p.pyeval"np.array(np.arange(10))"
q)pyarray
foreign
q)print pyarray
[0 1 2 3 4 5 6 7 8 9]
q)help pyarray / interactive help on object
```

For convenience `p.q` defines `print` and `help` in the top-level namespace of a q workspace it is loaded into. These are aliases for `.p.printpy` and `.p.help` respectively. If you do not want this behavior, comment out these lines in `p.q` before loading it.

```q
/comment out if you do not want print or help defined in your top level directory
@[`.;`help;:;help];
@[`.;`print;:;printpy];
```


### Further examples 

You’ll find further examples in the [examples](examples) directory. This includes an example of creating simple charts in Matplotlib either by running Python code in a kdb+ process, or importing the `matplotlib.pyplot` module into kdb+ and using functions from it in q code.
 

### `.p` directory reference 

name                 | description                                                                                                                             
---------------------|-----------------------------------------------------------------------------------------------------------------------------------------
`.p.eval`            | evaluate string as Python code and convert returned result to q via `py2q`
`.p.pyeval`          | evaluate string as Python code and return result as foreign
`.p.e`               | evaluate string as Python code, used for the p language, returns `::`
`.p.set`             | set a variable in Python `__main__` , `x - symbol`, `y - any q object`
`.p.import`          | import a module `x - symbol`
`.p.imp`             | import `y - symbol` from module `x - symbol` and return a foreign object, like `from x import y` 
`.p.py2q`            | convert Python object `foreign` to q, conversion is based on the function in `conv` for the first `.p.type` of a Python object
`.p.q2py`            | convert a q object to a Python object `foreign`
`.p.get`             | get value of `x - symbol` from Python `__main__`
`.p.attr`            | get attribute `y - symbol` from Python object `x - foreign`, i.e. `x.y`, and convert result to q
`.p.pyattr`          | get attribute `y - symbol` from Python object `x - foreign`, i.e. `x.y`, returns as a `foreign`
`.p.key`             | keys of a Python dictionary
`.p.value`           | values of a Python dictionary
`.p.type`            | type of a Python object
`.p.obj2dict`        | extract the methods, properties and data attributes of a Python object `x - foreign` into a dictionary, keys are `symbols`, values are `pycallables`
`.p.printpy`         | print a Python object's string representation
`.p.help`            | display help on Python objects as `foreign` and the underlying Python object for `callables`, `pycallables` and dictionaries created using `.p.obj2dict`
`.p.helpstr`         | give the docstring for Python objects and the underlying Python object for `callables`, `pycallables` and dictionaries created using `.p.obj2dict`
`.p.arraydims`       | give the shape of `x - foreign` a numpy multi-dimensional array.
`.p.callable`        | create a callable q function from a Python callable object `x - foreign` the function will convert results to q when subsequently called
`.p.pycallable`      | create a callable q function from a Python callable object `x - foreign` the function will return `foreign` when subsequently called
`.p.callable_imp`    | import `y - symbol` from module `x - symbol` and create a callable function from this, the function will convert results to q when subsequently called
`.p.pycallable_imp`  | import `y - symbol` from module `x - symbol`  and create a callable function from this, the function will return results as `foreign` when subsequently called
`.p.callable_attr`   | create a callable function from the `y - symbol` attribute of `x - foreign`, the function will convert results to q when subsequently called
`.p.pycallable_attr` | create a callable function from the `y - symbol` attribute of `x - foreign`, the function will return results as a `foreign` when subsequently called
`.p.qgenfunc`        | produce a Python generator from `x - q projection` which will yield `y - integer` times
`.p.qgenfuncinf`     | produce a Python generator from `x - q projection` which will yield indefinitely 
`.p.q2pargs`         | internal, used to interpret parameters passed to callables
`.p.repr`            | string representation of `foreign`
`.p.pykw`            | identify a parameter as a keyword parameter for callables, see examples, also present in `.q` namespace to allow infix notation and prevent assignment in top level namespace
`.p.pyarglist`       | identify a parameter as a list of positional parameters for callables, see examples, also present in `.q` namespace to prevent assignment in top level namespace
`.p.pykwargs`        | identify a parameter as a dictionary of keyword argument names to values, see examples, also present in `.q` namespace to prevent assignment in top level namespace
`.p.help4py`         | internal, used by help to display help on a Python object
`.p.helpstr4py`      | internal, used by `helpstr` to retrieve the (cleaned) docstring of a Python object
`.p.call`            | used internally by `.p.callable` and `.p.pycallable`
`.p.conv`            | dictionary of Python type identifier `short` to the conversion function used by `py2q`
`.p.c`               | compose a list of functions
`.p.ce`              | compose a list of functions with `enlist` appended to the end of the list
`.p.i`               | internal functions and objects 
