# embedPy


Allows the kdb+ interpreter to manipulate Python objects and call Python functions.

**Back-incompatible changes in V0.2-beta**

V0.2-beta features a number of changes back-incompatible with the previous release, V0.1-beta. 

==Most notably==, the default _type_ used in many operations is now the embedPy type, rather than the foreign type. Differences between these types (and the associated APIs) are set out below. 

<!-- FIXME List all back-incompatible changes. -->


## Status

The embedPy library is still in development. If you would like to participate in the beta tests, please write to ai@kx.com.


## Requirements

- kdb+ >=3.5 64-bit
- Anaconda Python 3.x
- macOS or Linux 


## Build and install

Build the interface and run sanity checks with 

```bash
./configure && make test
```
If running in an environment without Internet access, you will need to download the kdb+ [C API header file](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h) manually and place in the build directory.

Install by placing `p.q` and `p.k` in `$QHOME` and `p.so` in `$QHOME/{l64|m64}`.  

**Watch out** If you are currently using PyQ, it also has a file `p.so` in `$QHOME/{l64|m64}`. In this case, you may want to run initially from the local build directory without installing. <!-- FIXME: what would that look like? -->


## Example usage

### Run the examples

To run the following examples, load `p.q`.
```q
q)\l p.q
```


### Execute Python code

The interface allows execution of Python code directly in a q console or from a script. In both console and scripts, prefix Python code with `p)`.
```q
q)p)print(1+2)
3
```
Q scripts (but not the console) can load and execute multiline Python code. Prefix the first line of the code with `p)` and indent subsequent lines of Python code according to the usual Python indentation rules.
```bash
$ cat embedPytest.q
a:1                   / q code
p)def add1(arg1):     # Python code
    return arg1+1     # still Python code
```
In a q session
```q
q)\l embedPytest.q
q)p)print(add1(12))
13
```
Full Python scripts can be executed in q, using the `.p` file extension (not `.py`). The script is loaded as usual.
```bash
$ cat helloq.p 
print("Hello q!")
```
```q
q)\l helloq.p
Hello q!
```


### Evaluate Python code

To evaluate Python code (as a string) and return results to q, use `.p.qeval`.  
```q
q).p.qeval"1+2"
3
```
**Side effects** Python evaluation (unlike Python _execution_) does not allow side effects. Any attempt at variable assignment or class definition will signal an error. To execute a string performing side effects, use `.p.e`. A more detailed explanation of the difference between `eval` and `exec` in Python can be found [here](https://stackoverflow.com/questions/2220699/whats-the-difference-between-eval-exec-and-compile-in-python).


### Foreign objects

At the lowest level, Python objects are represented in q as `foreign` objects, which contain pointers to objects in the Python memory space.

Foreign objects can be stored in variables just like any other q datatype, or as part of lists, dictionaries or tables. They will display as `foreign` when inspected in the q console or using the `string` (or `.Q.s`) representation. 

**Serialization** Kdb+ cannot serialize foreign objects, nor send them over IPC: they live in the embedded Python memory space. To pass these objects over IPC, first convert them to q.


### EmbedPy objects

Foreign objects cannot be operated on directly in q. 
<!-- FIXME So what use are they? -->
Instead, Python objects are typically represented as _embedPy_ objects, which wrap the underlying foreign objects.
<!-- FIXME Clarify what wrapping a foreign object makes possible, and why some foreign objects are left unwrapped. -->

Use `.p.wrap` to create an embedPy object from a foreign object.
```q
q)x
foreign
q)p:.p.wrap x
q)p           /how an embedPy object looks
{[c;r;x;a]embedPy[c;r;x;a]}[0;0;foreign]enlist
```
More commonly, embedPy objects are retrieved directly from Python using one of the following unary functions:

function    | argument                                        | example
------------|-------------------------------------------------|-----------------------
`.p.import` | symbol: name of a Python module or package      | ``np:.p.import`numpy``
`.p.get`    | symbol: name of a Python variable in `__main__` | ``v:.p.get`varName``
`.p.eval`   | string: Python code to evaluate                 | `x:.p.eval"1+1"`

**Side effects** As with other Python evaluation functions, `.p.eval` does not permit side effects.


#### Converting data

Given `obj`, an embedPy object representing Python data, we can get the underlying data (as foreign or q) using
```q
obj`. / get data as foreign
obj`  / get data as q
```
e.g.
```q
q)x:.p.eval"(1,2,3)"
q)x
{[c;r;x;a]embedPy[c;r;x;a]}[0;0;foreign]enlist
q)x`.
foreign
q)x`
1 2 3
```


#### Getting attributes and properties

Given `obj`, an embedPy object representing a Python object, we can get an attribute or property directly using 
```q
obj`attr         / equivalent to obj.attr in Python
obj`attr1.attr2  / equivalent to obj.attr1.attr2 in Python
```
These expressions return embedPy objects, allowing users to chain operations together.  
```q
obj[`attr1]`attr2  / equivalent to obj.attr1.attr2 in Python
```
e.g.
```bash
$ cat class.p 
class obj:
    def __init__(self,x=0,y=0):
        self.x = x
        self.y = y
```
```q
q)\l class.p
q)obj:.p.eval"obj(2,3)"
q)obj[`x]`
2
q)obj[`y]`
3
```


#### Setting attributes and properties

Given `obj`, an embedPy object representing a Python object, we can set an attribute or property directly using 
```q
obj[:;`attr;val]  / equivalent to obj.attr=val in Python
```
e.g.
```q
q)obj[`x]`
2
q)obj[`y]`
3
q)obj[:;`x;10]
q)obj[:;`y;20]
q)obj[`x]`
10
q)obj[`y]`
20
```


#### Getting methods

Given `obj`, an embedPy object representing a Python object, we can access a method directly using 
```q
obj`method  / equivalent to obj.method in Python
```
This will return an embedPy object, which is not, by default, callable in q. 
Instead, embedPy objects representing callable Python functions or methods must be explicitly declared callable. This process is described below.


#### Function calls

EmbedPy objects representing callable Python functions or methods can be declared as callable in q using

-   `.p.callable`   (declare callable with embedPy return)
-   `.p.qcallable`  (declare callable with q return)
-   `.p.pycallable` (declare callable with foreign return)

The result of each of these functions is a new embedPy object, representing the same underlying Python function or method, but now callable in q.

e.g.
```q
q)np:.p.import`numpy
q)np`arange
{[c;r;x;a]embedPy[c;r;x;a]}[0;0;foreign]enlist
q)arange:.p.callable np`arange / callable returning embedPy
q)arange 12
{[c;r;x;a]embedPy[c;r;x;a]}[0;0;foreign]enlist
q)arange[12]`
0 1 2 3 4 5 6 7 8 9 10 11
q)arange_py:.p.pycallable np`arange  / callable returning foreign
q)arange_py 12
foreign
q)arange_q:.p.qcallable np`arange  / callable returning q
q)arange_q 12
0 1 2 3 4 5 6 7 8 9 10 11
```


#### embedPy function API

Using the function API, embedPy objects can be directly declared callable, enabling direct calling of the underlying functions or methods.

Users explicitly specify the return type as embedPy, q or foreign.  
Given `func`, an `embedPy` object representing a callable Python function or method, we can carry out the following operations:
```q
func[*]                / declare func callable (returning embedPy)
func[*]arg             / call func(arg) (returning embedPy)
func[*;arg]            / equivalent

func[<]                / declare func callable (returning q)
func[<]arg             / call func(arg) (returning q)
func[<;arg]            / equivalent

func[>]                / declare func callable (returning foreign)
func[>]arg             / call func(arg) (returning foreign)
func[>;arg]            / equivalent
```
**Chaining operations** Returning another embedPy object from a function or method call, allows users to chain together sequences of operations.  
We can also chain these operations together with calls to `.p.import`, `.p.get` and `.p.eval`.


### embedPy examples

Some examples
```bash
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
```q
q)\l test.p
q)obj:.p.get`obj
q)o:.p.callable[obj][]
q)o[`x]`
0
q)o[;`]each 5#`x
0 0 0 0 0
q)o[:;`x;10]
q)o[`x]`
10
q)o[`y]`
0
q)o[;`]each 5#`y
1 2 3 4 5
q)o[:;`y;10]
q)o[;`]each 5#`y
10 11 12 13 14
q)tot:.p.qcallable o`total
q)tot[]
25
q)tot[]
26
```
```q
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
```q
q)stdout:.p.callable(.p.import[`sys]`stdout.write)
q)stdout"hello\n";
hello
q)stderr:.p.import[`sys;`stderr.write;*]
q)stderr"goodbye\n";
goodbye
```
```q
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


### `None` and identity

Python `None` maps to the q identity function `::` when converting from Python to q (and vice versa).

There is one important exception to this. 
When calling Python functions, methods or classes with a single q data argument, passing `::` will result in the Python object being called with _no_ arguments, rather than a single argument of `None`. See the section below on _Zero-argument calls_ for how to explicitly call a Python callable with a single `None` argument. 


### Function calls

Python allows for calling functions with 

- A variable number of arguments
- A mixture of positional and keyword arguments
- Implicit (default) arguments

All of these features are available through the embedPy function-call interface.  
Specifically:

- Callable embedPy objects are variadic
- Default arguments are applied where no explicit arguments are given
- Individual keyword arguments are specified using the (infix) `pykw` operator
- A list of positional arguments can be passed using `pyarglist` (like Python *args)
- A dictionary of keyword arguments can be passed using `pykwargs` (like Python **kwargs)

**Keyword arguments last** We can combine positional arguments, lists of positional arguments, keyword arguments and a dictionary of keyword arguments. However, _all_ keyword arguments must always follow _any_ positional arguments. The dictionary of keyword arguments (if given) must be specified last.


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
Individual keyword arguments can be specified using the `pykw` operator (applied infix).  
Any keyword arguments must follow positional arguments, but the order of keyword arguments does not matter.
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


### Zero-argument calls

==In q, every function takes at least one argument. Even a niladic function, called with `func[]`, is passed the identity function `::` as an argument.==

<!-- 
FIXME How could you show the above to be true? Any reference in a lambda to its argument makes it _ipso facto_ a unary function. 
What is true: a _unary_ function applied to an empty argument list gets `::` as its argument value.
```q
q){x~(::)}[]
1b
```
But I doubt this helps what follows. Perhaps better simply to omit.
 -->

In Python these two calls are _not_ equivalent:
```python
func()       #call with no arguments
func(None)   #call with argument None
```
**Watch ouot** Although we noted above that `::` in q corresponds to `None` in Python, if an embedPy function is called with `::` as its only argument, the corresponding Python function will be called with _no_ arguments.

To call a Python function with `None` as its sole argument, retrieve `None` as a foreign object in q and pass that as the argument.
```q
q)pynone:.p.eval"None"
q).p.eval["print";*;pynone];
None
```


### Dictionary keys and values

Python dictionaries convert to q dictionaries, and vice versa.
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
Functions are also provided to retrieve the keys and values directly from an embedPy dictionary, without performing the conversion to a q dictionary. 

- `.p.key` returns the keys
- `.p.value` returns the values

In each case, the result is an embedPy object.
```q
q).p.key[qd]`
"one"
"two"
"three"
q).p.value[qd]`
1 2 3
```


### Printing and help

`.p.repr` returns the string representation of a Python object, embedPy or foreign.
This representation can be printed to stdout using `.p.print`.
```q
q)x:.p.eval"{'a':1,'b':2}"
q).p.repr x
"{'a': 1, 'b': 2}"
q).p.print x
{'a': 1, 'b': 2}
```
`.p.helpstr` returns the string representation of Python’s _help_ for a Python object, embedPy or foreign. 
This help can be ==accessed interactively== using `.p.help`. <!-- FIXME Clarify what acessed interactively means. -->
```q
q)n:.p.eval"42"
q).p.helpstr n
"int(x=0) -> integer\nint(x, base=10) -> integer\n\nConvert a number or strin..
q).p.help n / interactive help
```
**Aliases in the root** For convenience, `p.q` defines `print` and `help` in the root namespace of q, as aliases for `.p.print` and `.p.help`. To prevent this, comment out the relevant code in p.q before loading.
```q
{@[`.;x;:;get x]}each`help`print; / comment to remove from global namespace
```


### Closures

Closures allow us to define functions that retain state between successive calls, avoiding the need for global variables.  

To create a closure in embedPy, we must:

1. Define a function in q with
    -   2+ arguments: the current state and at least one other (possibly dummy) argument
    -   2 return values: the new state and the return value  
1. Wrap the function using `.p.closure`, which takes 2 arguments:
    -   the q function
    -   the initial state

**Functions without arguments** The dummy argument is needed if we want the resulting function to take no arguments.


#### Example 1: til

We can define a closure to return incrementing natural numbers, similar to the q `til` function.  

The state `x` is the last value returned
```q
q)xtil:{[x;dummy]x,x+:1}
```
Create the closure with initial state -1, so the first value returned will be 0
```q
q)ftil:.p.closure[xtil;1][<]
q)ftil[]
0
q)ftil[]
1
q)ftil[]
2
q)ftil[]
3
```


#### Example 2: Fibonacci

The Fibonacci sequence is a sequence in which each number is the sum of the two numbers preceding it.  
Starting with 0 and 1, the sequence goes `x(n) = x(n-1) + x(n-2)`

i.e. 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, …

The state `x` will be the last two values produced.
```q
q)xfib:{[x;dummy](x[1],r;r:sum x)}
```
Create the closure with initial state `0 1`, so the first value produced will be 1.
```q
q)fib:.p.closure[xfib;0 1][<]
q)fib[]
1
q)fib[]
2
q)fib[]
3
q)fib[]
5
q)fib[]
8
q)fib[]
13
```


#### Example 3: Running sum

In this example, we will allow a numeric argument to be passed to the closure, removing the need for a dummy argument. The closure will keep track of all arguments passed so far, and return a running sum.

The state `x` will be the total so far.
```q
q)xrunsum:{x,x+:y}
```
Create the closure with initial state 0, so the first value produced will be the first argument passed.
```q
q)runsum:.p.closure[xrunsum;0][<]
q)runsum 2
2
q)runsum 3
5
q)runsum -2.5
2.5
q)runsum 0
2.5
q)runsum 10
12.5
```


### Generators

Generators allow us to produce objects that we can iterate over (e.g. in a for-loop) to produce sequences of values.  

To create a generator in embedPy, we must

1. Define a function in q (as per closures) with:
    -   2 arguments - the current state and a dummy argument
    -   2 return values - the new state and the return value  
1. Wrap the function using `.p.generator`, which takes 3 arguments:
    -   the q function
    -   the initial state
    -   the max number of iterations, or `::` to run indefinitely


#### Example 1: Factorials

The _factorial_ (n!) of a non-negative integer n, is the product of all positive integers less than or equal to n.  

We can create a sequence of factorials (starting with 1), with the sequence  `x(n) = x(n-1) * n`

The state `x` will be a 2-item list comprising

-   the last value used in the product
-   the last value returned

```q
q)xfact:{[x;dummy](x;last x:prds x+1 0)}
```
Create two generators, each with initial state `0 1`.
```q
q)fact4:.p.generator[xfact;0 1;4]     / generates first 4 factorial values
q)factinf:.p.generator[xfact;0 1;::]  / generates factorial values indefinitely
```
The resulting generators can be used as iterators in Python.
```q
q).p.set[`fact4]fact4
q)p)for x in fact4:print(x)
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


#### Example 2: Look-and-say

The look-and-say sequence is the sequence of integers beginning as follows:
1, 11, 21, 1211, 111221, 312211, 13112221, 1113213211

* `1` is read off as “one 1” or 11.
* `11` is read off as “two 1s” or 21.
* `21` is read off as “one 2, then one 1” or 1211.
* `1211` is read off as “one 1, one 2, then two 1s” or 111221

The state `x` will be the last value produced.
```q
q)xlook:{[x;dummy]r,r:"J"$raze string[count each s],'first each s:(where differ s)_s:string x}
```
Create a generator (to run for 7 iterations) with initial state 1, so the first value produced will be 11.
```q
q)look:.p.generator[xlook;1;7]
```
This can be used as an iterator in Python.
```q
q).p.set[`look]look
q)p)for x in look:print(x)
11
21
1211
111221
312211
13112221
1113213211
```


#### Example 3: Successive sublists

We can define a closure to extract successive sublists, of a given size, from a larger list.  

The state `x` will be a 3-item list comprising

-   the list
-   the start index
-   the sublist size

```q
q)xsub:{[x;d](@[x;1;+;x 2];sublist[x 1 2]x 0)}
```
To create a generator (to run for 6 iterations), extracting sublists of size 6 from `.Q.A` (list of 26 alphabetical chars)
 ```q
 q)sub:.p.generator[xsub;(.Q.A;0;6);6]
 ```
This can be used as an iterator in Python.
```q
q).p.set[`sub]sub
q)p)for x in sub:print(x)
ABCDEF
GHIJKL
MNOPQR
STUVWX
YZ

q)
```


### Raw (foreign) data

Foreign objects are retrieved from Python using one of the following calls.

function      | argument                                        | example
--------------|-------------------------------------------------|--------------
`.p.pyimport` | symbol: name of a Python module or package      | ``.p.pyimport`numpy``
`.p.pyget`    | symbol: name of a Python variable in `__main__` | ``.p.pyget`varName``
`.p.pyeval`   | string: Python code to evaluate                 | `.p.pyeval"1+1"`


### Raw (foreign) API

Some low-level functions act directly on foreign objects.


#### Convert data 

Function `.p.py2q` attempts to convert Python (`foreign`) data to q
```q
q)qvar:.p.pyget`var1
q).p.py2q qvar
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 ..
```
<!-- FIXME “attempts” – what happens when it fails? -->
Complementary function `.p.q2py` converts q objects to Python objects  
```q
q).p.q2py 1 2 3
foreign
```
This is rarely needed, q data is converted whenever embedPy functions pass it to Python.


#### Function calls

A foreign object, representing a callable Python object, can be made callable in q with `.p.call`.  

`.p.call` will return a q function, taking 2 arguments:

-   a list of positional arguments
-   a dictionary of keyword arguments

Either of these arguments can be ==empty==. 
<!-- FIXME Clarify “empty”. Empty list? Identity function? Omitted without forming a projection? -->

The result of calling this function, will be another foreign object.  
```q
q)p)def f4(a,b,c,d):return (a*b,c*d)
q).p.py2q .p.call[.p.pyget`f4;1 2;`d`c!4 3]
2 12
```


#### Getting attributes/properties

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


#### Setting attributes and properties

Function `.p.setattr ` will set an attribute or property of a foreign object.

```q
q).p.setattr[obj;`x;10]
q).p.setattr[obj;`y;20]
q).p.py2q .p.getattr[obj]`x
10
q).p.py2q .p.getattr[obj]`y
20
```


#### Dictionary keys and values

Two functions retrieve keys and values directly from a foreign dictionary, without performing the conversion to a q dictionary. 

-   `.p.pykey` returns the keys
-   `.p.pyvalue` returns the values

In each case, the result is a `foreign` object.
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

Further examples are in the [examples](examples) folder of this repository. 

This includes an example of creating simple charts in Matplotlib either by running Python code in a kdb+ process, or importing the `matplotlib.pyplot` module into kdb+ and using functions from it in q code.
 

### `.p` directory reference 

name                 | description                                                                                                                             
---------------------|-----------------------------------------------------------------------------------------------------------------------------------------
`.p.e`               | evaluate `x- string` as Python code (used for the `p)` language)
`.p.qeval`           | evaluate `x- string` as Python code and return result as q
`.p.import`          | import module `x - symbol` and return result as embedPy
`.p.eval`            | evaluate `x- string` as Python code and return result as embedPy
`.p.get`             | get `x - symbol` from Python `__main__`  and return result as embedPy
`.p.set`             | set `x - symbol` variable in Python `__main__` , with value `y`
`.p.callable`        | make `x` a callable embedPy object, which will return embedPy results
`.p.pycallable`      | make `x` a callable embedPy object, which will return foreign results
`.p.qcallable`       | make `x` a callable embedPy object, which will return q results
`.p.key`             | get keys of dictionary `x` as embedPy
`.p.value`           | get values of dictionary `x` as embedPy
`.p.wrap`            | wrap `x -foreign` and return result as embedPy
`.p.unwrap`          | unwrap `x` and return result as foreign
`.p.helpstr`         | get docstring for `x` as q-string
`.p.help`            | interactive help on `x`
`.p.repr`            | get string representation of `x` as q-string
`.p.printpy`         | print string representation of `x`
`.p.closure`         | create closure with q function `x` and initial state `y`
`.p.generator`       | create generator with q function `x`, initial state `y` and the max number of iterations `z` (`::` to run indefinitely)
`.p.pyimport`        | import module `x - symbol` and return result as foreign
`.p.pyeval`          | evaluate `x - string` as Python code and return result as foreign
`.p.pyget`           | get `x - symbol` from Python `__main__`  and return result as foreign
`.p.py2q`            | convert `x - foreign` to q
`.p.q2py`            | convert `x - q` to foreign
`.p.getattr`         | get attribute `y - symbol` from `x - foreign`
`.p.setattr`         | set attribute `y - symbol` from `x - foreign` with value `z`
`.p.call`            | calls function `x` with positional args `y - list` and keyword args `z - dict`
`.p.pyfunc`          | make `x - foreign` a callable function, which will return foreign results
`.p.pykey`           | get keys of dictionary `x - foreign` as foreign
`.p.pyvalue`         | get values of dictionary `x - foreign` as foreign
`.p.arraydims`       | get the shape of `x - foreign` (a numpy multi-dimensional array)
`.p.i`               | internal functions and objects 
`.p.type`            | [internal] type of `x - foreign` (used internally for `py2q` conversion)
`.p.conv`            | [internal] dictionary from Python type to conversion function (used internally for `py2q` conversion)
`.p.c`               | [internal] compose a list of functions
`.p.ce`              | [internal] compose a list of functions with `enlist` appended to the end
`.p.q2pargs`         | [internal] interpret parameters (positional and pykw/pyarglist/pykwargs) for passing to callables
`.p.pykw`            | [internal] identify keyword parameter (also present in `.q` namespace to allow infix notation and prevent assignment in top level namespace)
`.p.pyarglist`       | [internal] identify list of positional parameters (also present in `.q` namespace to prevent assignment in top level namespace)
`.p.pykwargs`        | [internal] identify dictionary of keyword argument names to values (also present in `.q` namespace to prevent assignment in top level namespace)
`.p.embedPy`         | [internal] defines embedPy API
