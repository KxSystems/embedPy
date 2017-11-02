# embedPy

Allows the kdb+ interpreter to call Python functions.


## Status

This library is in development. 
If you would like to participate in the beta tests, please write to jhanna@kx.com. 


## Build and installation

Build the interface with and run sanity checks with 

```bash
./configure && make test
```
If you are running this in an environment without Internet access you will need to download the kdb+ C API header file manually and place it in the directory you are building from. The latest version of this can be found [here](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h)

Install by placing `p.q` in `QHOME` and `p.so` in `QHOME/{l64|m64}`. Note that if you are currently using PyQ it also has a file called p.so which it places in QHOME/{l64|m64}, so you may want to run from the local build directory without installing initially.

`p.q` defines the `.p` directory, this includes a `.p.e` function so `p)` can be used at the start of a line to run statements in Python


## Example usage

### Running the examples

In each of the code snippets below we assume that `p.q` has been loaded. It can be loaded into a running q console with 
```q
q)\l p.q
```


### Executing Python code ###

The interface allows execution of Python code directly in a q console or from a script. Both in the console and scripts, Python code should be prefixed with `p)`.  
```q
q)p)print(1+2)
3
```
Multiline Python code in q scripts can be loaded and executed. Prefix the first line of the code with `p)`. Subsequent lines of Python code should be indented according to the usual Python indentation rules. e.g.
```q
$ cat test.q
a:1                   / q code
p)def add1(arg1):     / Python code
    return arg1+1     / still Python code
q)\l test.q
q)p)print(add1(12))
13
```


### The foreign datatype

Python objects which have not been converted to q data are stored as a `foreign` datatype, these contain pointers to Python objects in the Python memory space, and will display `foreign` when you look at them in the q console or try to view the string representation of them with `.Q.s` or `string`.

These objects can be stored just like any other q datatype in variables or as part of tables, dictionary or lists.

**NB** Foreign object types cannot be serialized by kdb+ and sent over IPC: they live in the embedded Python memory space. If you need to pass these objects to other processes over IPC, then you must convert them to q, possibly after choosing some serialization of them in Python.


### `.p.eval` and `.p.pyeval`
To execute Python code (as a string) and return results to q you should use either `.p.eval` or `.p.pyeval`. 
```q
q).p.eval"1+2"
3
q).p.pyeval"1+2"
foreign
```
Note the difference in the two results here: 

-   `.p.eval` will attempt to convert the Python result of the statement to a q result; 
-   `.p.pyeval` will leave the result as a Python object and return it as  `foreign` to q without any attempt at conversion. This result can be stored in a variable for use later: e.g. it might be passed back to Python, examined using one of the other `.p` functions or converted to q data.


### Getting and setting values or variables from Python

Variables in Python `__main__` can be set using `.p.set` and retrieved using `.p.get`
```q
q).p.set[`var1;til 100]
q).p.eval"len(var1)"
100
q)qvar:.p.get[`var1]
q)qvar
foreign
```
**NB** `.p.get` may not convert Python objects to q data automaticatlly. The result can be converted using `.p.py2q`.


### Converting data 

The functionz `.p.py2q` and `.p.q2py` will convert Python data to q and vice versa.
```q
q)qvar:.p.get[`var1]
q).p.py2q qvar
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 ..
```
`.p.q2py` is the corresponding function to convert q objects to Python objects. This will rarely be used in practice, as conversion of q data to Python objects is performed automatically whenever q data is passed to Python.
```q
q).p.q2py 1 2 3
foreign
```
It is safe to call `.p.py2q` on q data and `.p.q2py` on Python data: they will return the argument unchanged in these cases.


#### `None` and identity `::` 

Python `None` maps to the q identity function `::`. When converting from Python to q and vice versa, there is one exception to this. When calling Python functions, methods or classes with a single q data argument, passing `::` will result in the Python object being called with _no_ arguments, not a single argument of `None`. See the section below on callables for how to call a Python callable with a single argument of `None` if you need to do this. 


### Imports 

Python modules (or objects from modules) can be imported using `.p.import` or `.p.imp`

- `.p.import` imports a Python module
- `.p.imp`    imports an object from a Python module or package 

Both of these functions return the imported object as `foreign`.
```q
q)np:.p.import`numpy
q).p.attr[np;`BUFSIZE]
8192
q)npversion:.p.imp[`numpy;`version]
q).p.attr[npversion;`full_version]
"1.13.3"
```


### Getting attributes from Python objects 

We can retrieve the value of a particular attribute of a Python object using `.p.attr` or `.p.pyattr`. 

As before with the eval functions, `.p.attr` will attempt to convert the Python object to q data and `.p.pyattr` will return the Python object unconverted to q.
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


### Extracting keys and values from Python dictionaries 

Whilst Python dictionaries can be retrieved and converted to q dictionaries as with other Python objects, two functions are provided to retrieve the keys and values of a Python dictionary as a `foreign` object without performing the conversion to a q dictionary. 

- `.p.key` will return the keys of a Python dictionary as a Python object. Use `.p.py2q` to convert this to q data.
- `.p.value` will return the values of a Python dictionary as a Python object, use `.p.py2q` to convert this to q data.

```q
p)dict={'key1':12,'key2':42}
q)qdict:.p.get`dict
q).p.py2q .p.key qdict 
"key1"
"key2"
q).p.py2q .p.value qdict
12 42
```


### Calling Python functions or instantiating classes from q 

Python allows for calling functions with a mixture of positional and keyword arguments. It also supports default arguments such that functions may be called with fewer arguments than are specified in the function signature, provided defaults are specified in the funtion signature. The same behaviour is available for class instantiation through the `__init__` method of classes. 

Both variadic and keyword arguments are available through the function interface. The functions in that table below will produce q functions which can be called with a variable number of positional and keyword arguments.

There are three ways of creating variadic q functions from Python callables, and for each of these a function returning either q data or Python data can be created. 

||returning Q|returning Python|
|:---|:---|:---|
|from Python callable|`.p.callable`|`.p.pycallable`|
|from attribute `y` of Python object `x`|`.p.callable_attr`|`.p.pycallable_attr`|
|from content item `y` of Python module name `x`|`.p.callable_imp`|`.p.pycallable_imp`|

In each of the examples below we create two q functions which will call the `numpy.eye` Python function. One returning the result as q data and the other returning a Python foreign object.


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
/ getting the numpy object as a foreign and creating a callable from one of its functions
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
/ importing the numpy.eye function directly and creating q functions from it
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
q)qfunc[2;2;2;2]                             / qfunc called with all arguments specified
16

q)qfunc[2;2]                                 / q func called with just the first 2 positional arguments specified
48

q)qfunc[2;2;2;2;2]                           / error because too many arguments were specified
TypeError: func() takes from 0 to 4 positional arguments but 5 were given
'p.c:72 call pyerr
  [0]  qfunc[2;2;2;2;2]
```
Keyword arguments can be specified using the `pykw` operator. Keyword arguments must follow positional arguments, but the order of keyword arguments if there are many does not matter.
```q
q)qfunc[1;2;`d pykw 3;`c pykw 4]
24
```
You can also specify lists of positional arguments using `pyarglist` or a dictionary of keyword arguments using `pykwargs`, if a dictionary of keyword arguments is given it must be the _last_ argument specified.
```q
q)qfunc[pyarglist 1 1 1]
4

q)qfunc[pyarglist 2 2;pykwargs `d`c!3 3]
36
```
You can combine positional arguments, lists of positional arguments, keyword arguments and a dictionary of keyword arguments, but note that all keyword arguments must always follow any positional arguments and that the dictionary of keyword arguments must always be specified last if it is given at all.
```q
q)qfunc[4;pyarglist enlist 3;`d pykw 2;pykwargs (1#`c)!(),2]
48
```


#### Calling functions with zero arguments or `None` 

In q every function takes at least one argument, whenever a function is called with `func[]` the argument is identity `(::)`. In embedPy, if a function is called with `::` as the only argument the underlying Python function will be called with _no_ arguments. As we noted above `::` in q maps to `None` in Python, however in Python these two calls are not equivalent:
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


#### `.p.call` ####

All of the functions above use `.p.call` internally. This can be used directly if you do not need the variadic or keyword argument behavior, this function when run on a Python callable object will give a q function taking exactly 2 arguments, the first a list of positional arguments and the second a dictionary of keyword argument names to values, either of these can be empty. The result of this function will not be converted to q data. (Use `.p.py2q` on the result if necessary.)


### Wrapping Python objects as q dictionaries 

It can be useful to extract the contents of a Python object into a q dictionary so that members of the object can be referred to using dot notation without having to use `.p.attr/.p.pyattr` each time we want to access a member. The `.p.obj2dict` function will do this. 

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

**NB** Currently no attributes of the object preceded by `_` or `__` are wrapped are wrapped into the dictionary.


#### Calling functions for wrapped objects 

Any method or function of the wrapped object has an entry which is a callable q function, with variadic and keyword argument support. This function will return Python data without attempting to convert to q. You can convert the results to q data with `.q.py2q` if necessary.
```q
q)arraywrap.diagonal[]
foreign
q).p.py2q arraywrap.diagonal[]
0 1
2 3
4 5
6 7
```


#### Getting or setting values of data attributes or properties of wrapped objects 

For both properties and data attributes of Python objects we don’t take a snapshot of the value of the attribute at a point in time, but provide a function to access or set the value of a property from the underlying Python object.
```q
q)qarray:.p.py2q arraywrap._pyobj
q).p.py2q arraywrap.real[]         / see the value of the real attribute
0 1 2  3    4 5 6  7    8 9 10 11  
12 13 14 15 16 17 18 19 20 21 22 23

q)arraywrap.real[:;2*qarray]      / set the value from some q data
q).p.py2q arraywrap.real[]        / see the new value
0  2  4  6  8  10 12 14 16 18 20 22
24 26 28 30 32 34 36 38 40 42 44 46
```


### Printing and help 

The string representation of Python objects (as would be returned from Python’s `repr`) can be accessed using `.p.repr`, and printed to stdout using `.p.printpy`. 

Interactive help on Python objects in the q console is available through `.p.help` and the docstring for a Python object can be retrieved as a string using `.p.helpstr`. (This uses Python's `inspect.getdoc`.)

Both `.p.help` and `.p.helpstr` will also work on q functions created from Python callables using `.p.callable` and objects wrapped using `.p.obj2dict`, in these two cases the help displayed or retrieved will be the Python docstring help on the underlying Python object.

For convenience `p.q` defines `print` and `help` in the top-level namespace of a q workspace it is loaded into, these are aliases for `.p.printpy` and `.p.help` respectively. If you do not want this behavior, comment out these lines in `p.q` before loading it.
```
/comment out if you do not want print or help defined in your top level directory
@[`.;`help;:;help];
@[`.;`print;:;printpy];

q)pyarray:.p.pyeval"np.array(np.arange(10))"
q)pyarray
foreign

q)print pyarray
[0 1 2 3 4 5 6 7 8 9]

q)help pyarray / interactive help on object
```


### Further examples 

You’ll find further examples in the [examples](examples) directory. This includes an example of creating simple charts in Matplotlib either by running Python code in a kdb+ process or importing the `matplotlib.pyplot` module into kdb+ and using functions from it in q code.
 

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
`.p.helpstr`         | give the docstring for Python objects as `foreign` and the underlying Python object for `callables`, `pycallables` and dictionaries created using `.p.obj2dict`
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

