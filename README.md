# embedPy

Allows the kdb+ interpreter to manipulate Python objects and call Python functions.


## Status

The embedPy library is still in development.  
If you would like to participate in the beta tests, please write to ai@kx.com. 


## Requirements

- KDB+ >=3.5 64-bit
- Python 3.x
- Mac/Linux 

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


### Executing Python code

The interface allows execution of Python code directly in a q console or from a script. In both the console and scripts, Python code should be prefixed with `p)`  
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
**Put something about .p scripts here**

### Evaluating Python code
To evaluate Python code (as a string) and return results to q, use `.p.qeval`.  
```q
q).p.qeval"1+2"
3
```
**NB** Python evaluation (unlike Python execution) does not allow side-effects. Thus, any attempt at variable assignment or class definition, will result in an error. To execute a string that performs variable assignment or class definition,  you can use `.p.e`. A more detailed explanation of the difference between `eval` and `exec` in Python can be found [here](https://stackoverflow.com/questions/2220699/whats-the-difference-between-eval-exec-and-compile-in-python)


### foreign objects

At the lowest level, Python objects are represented in q as `foreign` objects, which contain pointers to objects in the Python memory space.

Foreign objects can be stored in variables just like any other q datatype, or as part of lists, dictionaries or tables. They will display `foreign` when inspected in the q console or using the `string` (or `.Q.s`) representation. 

**NB** Foreign object types cannot be serialized by kdb+ and sent over IPC: they live in the embedded Python memory space. If you need to pass these objects to other processes over IPC, then you must first convert them to q.


### embedPy objects

In practice, Python objects should be represented in q as `embedPy` objects, which wrap the underlying `foreign` objects, and provide users with the ability to
- Get attributes/properties
- Set attributes/properties
- Call functions/methods
- Convert data to q/foreign

By default, calling an embedPy function/method, will return another embedPy object. This allows users to chain together sequences of functions. Alternatively, users can specify the return type as q or foreign.

embedPy objects are retrieved from Python with one of the following calls

#### .p.import
Symbol arg- the name of a Python module or package to import  
e.g. ``.p.import`numpy``
#### .p.get
Symbol arg- the name of a Python variable in `__main__`
- ``.p.get`varName``
#### .p.eval
String arg- the Python code to evaluate
- ``.p.eval"1+1"``  

**NB** As with other Python evaluation functions, .p.eval does not allow side-effects


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
We can also chain calls together and combine them with `.p.import`, `.p.get` and `.p.eval`.

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


#### `None` and identity `::` 

Python `None` maps to the q identity function `::` when converting from Python to q and vice versa.

There is one exception to this. When calling Python functions, methods or classes with a single q data argument, passing `::` will result in the Python object being called with _no_ arguments, rather than a single argument of `None`. See the section below on callables for how to explicitly call a Python callable with a single `None` argument. 


### Function calls

Python allows for calling functions with 
- A variable number of argumemnts
- A mixture of positional and keyword arguments
- Implicit (default) arguments

All of these features are available through the embedPy function-call interface.  
Specifically
- Callable embedPy objects are variadic
- Default arguments are appplied where no explicit arguments are given
- Individual keyword arguments are specified using the (infix) `pykw` operator
- A list of positional arguments can be passed using `pyarglist` (like Python *args)
- A dictionary of keyword arguments can be passed using `pykwargs` (like Python *kwargs)

n.b. We can combine positional arguments, lists of positional arguments, keyword arguments and a dictionary of keyword arguments, but note that _all_ keyword arguments must always follow any positional arguments and that the dictionary of keyword arguments must always be specified last if it is given at all.


### Example function calls
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
```q
q)qfunc[4;pyarglist enlist 3;`d pykw 2;pykwargs (1#`c)!(),2]
48
```

### Zero argument calls

In q, every function takes at least one argument. Even a niladic function, called with `func[]`, is the identity function `::` as an argument. In embedPy, if a function is called with `::` as the only argument, the underlying Python function will be called with _no_ arguments. As we noted above `::` in q maps to `None` in Python, however in Python these two calls are not equivalent:
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


#### Raw function calls

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
