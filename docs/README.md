# ![Python](../python.png) embedPy user guide



## Running Python code


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

Q scripts (but not the console) can load and execute multiline Python code. 
Prefix the first line of the code with `p)` and indent subsequent lines of Python code according to the usual Python indentation rules.

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

Full scripts of Python code can be executed in q, using the `.p` file extension (not `.py`). The script is loaded as usual.

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

**Side effects** Python evaluation (unlike Python _execution_) does not allow side effects. Any attempt at variable assignment or class definition will signal an error. To execute a string performing side effects, use `.p.e`. 

:globe_with_meridians:
[Difference between `eval` and `exec` in Python](https://stackoverflow.com/questions/2220699/whats-the-difference-between-eval-exec-and-compile)


## EmbedPy objects


### Foreign objects

At the lowest level, Python objects are represented in q as `foreign` objects, which contain pointers to objects in the Python memory space.

Foreign objects can be stored in variables just like any other q datatype, or as part of lists, dictionaries or tables. They will display as `foreign` when inspected in the q console or using the `string` (or `.Q.s`) representation.

**Serialization** Kdb+ cannot serialize foreign objects, nor send them over IPC: they live in the embedded Python memory space. To pass these objects over IPC, first convert them to q.


### EmbedPy objects

Foreign objects cannot be directly operated on in q. Instead, Python objects are typically represented as `embedPy` objects, which wrap the underlying `foreign` objects. This provides the ability to get and set attributes, index, call or convert the underlying `foreign` object to a q object.

Use `.p.wrap` to create an embedPy object from a foreign object.

```q
q)x
foreign
q)p:.p.wrap x
q)p           /how an embedPy object looks
{[f;x]embedPy[f;x]}[foreign]enlist
```

More commonly, embedPy objects are retrieved directly from Python using one of the following functions:

function    | argument                                         | example
------------|--------------------------------------------------|-----------------------
<code style="white-space: nowrap">.p.import</code> | symbol: name of a Python module or package, optional second argument is the name of an object within the module or package | <code style="white-space: nowrap">np:.p.import&#96;numpy</code>
`.p.get`    | symbol: name of a Python variable in `__main__`  | ``v:.p.get`varName``
`.p.eval`   | string: Python code to evaluate                  | `x:.p.eval"1+1"`

**Side effects** As with other Python evaluation functions, `.p.eval` does not permit side effects.


### Converting data

Given `obj`, an embedPy object representing Python data, we can get the underlying data (as foreign or q) using

```q
obj`. / get data as foreign
obj`  / get data as q
```

e.g.

```q
q)x:.p.eval"(1,2,3)"
q)x
{[f;x]embedPy[f;x]}[foreign]enlist
q)x`.
foreign
q)x`
1 2 3
```


### `None` and identity

Python `None` maps to the q identity function `::` when converting from Python to q (and vice versa).

There is one important exception to this.
When calling Python functions, methods or classes with a single q data argument, passing `::` will result in the Python object being called with _no_ arguments, rather than a single argument of `None`. See the section below on _Zero-argument calls_ for how to explicitly call a Python callable with a single `None` argument.


### Getting attributes and properties

Given `obj`, an embedPy object representing a Python object, we can get an attribute or property directly using

```q
obj`:attr         / equivalent to obj.attr in Python
obj`:attr1.attr2  / equivalent to obj.attr1.attr2 in Python
```

These expressions return embedPy objects, allowing users to chain operations together.

```q
obj[`:attr1]`:attr2  / equivalent to obj.attr1.attr2 in Python
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
q)obj[`:x]`
2
q)obj[`:y]`
3
```


### Setting attributes and properties

Given `obj`, an embedPy object representing a Python object, we can set an attribute or property directly using

```q
obj[:;`:attr;val]  / equivalent to obj.attr=val in Python
```

e.g.

```q
q)obj[`:x]`
2
q)obj[`:y]`
3
q)obj[:;`:x;10]
q)obj[:;`:y;20]
q)obj[`:x]`
10
q)obj[`:y]`
20
```


### Indexing

Given `lst`, an embedPy object representing an indexable container object in Python, we can access the element at index `i` using

```q
lst[@;i]    / equivalent to lst[i] in Python
```

We can set the element at index `i` (to object `x`) using

```q
lst[=;i;x]  / equivalent to lst[i]=x in Python
```

These expressions return embedPy objects, e.g.

```q
q)lst:.p.eval"[True,2,3.0,'four']"
q)lst[@;0]`
1b
q)lst[@;-1]`
"four"
q)lst'[@;;`]2 1 0 3
3f
2
1b
"four"
q)lst[=;0;0b]
q)lst[=;-1;`last]
q)lst`
0b
2
3f
"last"
```


### Getting methods

Given `obj`, an embedPy object representing a Python object, we can access a method directly using

```q
obj`:method  / equivalent to obj.method in Python
```

This will return an embedPy object, _calling_ this object is described below.


### Function calls

EmbedPy objects representing callable Python functions or methods are callable by default with an `embedPy` return. They can be declared callable in q returning q or `foreign` using.

-   `.p.qcallable`  (declare callable with q return)
-   `.p.pycallable` (declare callable with foreign return)


The result of each of these functions represents the same underlying Python function or method, but now callable in q, e.g.

```q
q)np:.p.import`numpy
q)np`:arange
{[f;x]embedPy[f;x]}[foreign]enlist
q)arange:np`:arange                   / callable returning embedPy
q)arange 12
{[f;x]embedPy[f;x]}[foreign]enlist
q)arange[12]`
0 1 2 3 4 5 6 7 8 9 10 11
q)arange_py:.p.pycallable np`:arange / callable returning foreign
q)arange_py 12
foreign
q)arange_q:.p.qcallable np`:arange   / callable returning q
q)arange_q 12
0 1 2 3 4 5 6 7 8 9 10 11
```


### EmbedPy function API

Using the function API, embedPy objects can be called directly (returning embedPy) or declared callable returning q or `foreign` data.

Users explicitly specify the return type as q or foreign, the default is embedPy.
Given `func`, an `embedPy` object representing a callable Python function or method, we can carry out the following operations:

```q
func                   / func is callable by default (returning embedPy)
func arg               / call func(arg) (returning embedPy)

func[<]                / declare func callable (returning q)
func[<]arg             / call func(arg) (returning q)
func[<;arg]            / equivalent

func[>]                / declare func callable (returning foreign)
func[>]arg             / call func(arg) (returning foreign)
func[>;arg]            / equivalent
```

**Chaining operations** Returning another embedPy object from a function or method call, allows users to chain together sequences of operations.  We can also chain these operations together with calls to `.p.import`, `.p.get` and `.p.eval`.


### EmbedPy examples

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
q)obj:.p.get`obj / obj is the *class* not an instance of the class
q)o:obj[]        / call obj with no arguments to get an instance
q)o[`:x]`
0
q)o[;`]each 5#`:x
0 0 0 0 0
q)o[:;`:x;10]
q)o[`:x]`
10
q)o[`:y]`
0
q)o[;`]each 5#`:y
1 2 3 4 5
q)o[:;`:y;10]
q)o[;`]each 5#`:y
10 11 12 13 14
q)tot:.p.qcallable o`:total
q)tot[]
25
q)tot[]
26
```
```q
q)np:.p.import`numpy
q)v:np[`:arange;12]
q)v`
0 1 2 3 4 5 6 7 8 9 10 11
q)v[`:mean;<][]
5.5
q)rs:v[`:reshape;<]
q)rs[3;4]
0 1 2  3
4 5 6  7
8 9 10 11
q)rs[2;6]
0 1 2 3 4  5
6 7 8 9 10 11
q)np[`:arange;12][`:reshape;3;4]`
0 1 2  3
4 5 6  7
8 9 10 11
q)np[`:arange;12][`:reshape;3;4][`:T]`
0 4 8
1 5 9
2 6 10
3 7 11
```

```q
q)stdout:.p.import[`sys]`:stdout.write
q)stdout"hello\n";
hello
q)stderr:.p.import[`sys;`:stderr.write]
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

<!-- 
### Further examples 

Further examples can be found in the `examples` folder of the :fontawesome-brands-github: [KxSystems/embedPy](https://github.com/kxsystems/embedpy) repository. 

This includes an example of creating simple charts in Matplotlib either by running Python code in a kdb+ process, or importing the `matplotlib.pyplot` module into kdb+ and using functions from it in q code.
 -->

### Setting Python variables

Variables can be set in Python `__main__` using `.p.set`

```q
q).p.set[`var1;42]
q).p.qeval"var1"
42
```



## Function calls


Python allows for calling functions with

-   A variable number of arguments
-   A mixture of positional and keyword arguments
-   Implicit (default) arguments

All of these features are available through the embedPy function-call interface.
Specifically:

-   Callable embedPy objects are variadic
-   Default arguments are applied where no explicit arguments are given
-   Individual keyword arguments are specified using the (infix) `pykw` operator
-   A list of positional arguments can be passed using `pyarglist` (like Python \*args)
-   A dictionary of keyword arguments can be passed using `pykwargs` (like Python \*\*kwargs)

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

A list of positional arguments can be specified using `pyarglist` (similar to Python’s \*args).
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


A dictionary of keyword arguments can be specified using `pykwargs` (similar to Python’s \*\*kwargs).
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

```q
q)qfunc[4;pyarglist enlist 3;`c pykw 2;pykwargs enlist[`d]!enlist 1]
4 3 2 1 24
```

> :warning: **`pykw`, `pykwargs`, and `pyarglist`**
> 
> Before defining functions containing `pykw`, `pykwargs`, or `pyarglist` within a script, the file `p.q` must be loaded explicitly. 
> Failure to do so will result in errors `'pykw`, `'pykwargs`, or `'pyarglist`.


### Zero-argument calls

In Python these two calls are _not_ equivalent:

```python
func()       #call with no arguments
func(None)   #call with argument None
```

> :warning: **EmbedPy function called with `::` calls Python with no arguments**
> 
> Although `::` in q corresponds to `None` in Python, if an embedPy function is called with `::` as its only argument, the corresponding Python function will be called with _no_ arguments.

To call a Python function with `None` as its sole argument, retrieve `None` as a foreign object in q and pass that as the argument.

```q
q)pynone:.p.eval"None"
q).p.eval["print";pynone];
None
```

Python         | form                      | q
---------------|---------------------------|-----------------------
`func()`       | call with no arguments    | `func[]` or `func[::]`
`func(None)`   | call with argument `None` | `func[.p.eval"None"]`

> **Q functions applied to empty argument lists**
> 
> The _rank_ (number of arguments) of a q function is determined by its _signature_,
> an optional list of arguments at the beginning of its definition.
> If the signature is omitted, the default arguments are as many of
> `x`, `y` and `z` as appear, and its rank is 1, 2, or 3.
> 
> If it has no signature, and does not refer to `x`, `y`, or `z`, it has rank 1.
> It is implicitly unary.
> If it is then applied to an empty argument list, the value of `x` defaults to `(::)`.
> 
> So `func[::]` is equivalent to `func[]` – and in Python to `func()`, not `func[None]`.


## Printing and help

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
Python interactive help for an object is accessed using `.p.help`.

```q
q)n:.p.eval"42"
q).p.helpstr n
"int(x=0) -> integer\nint(x, base=10) -> integer\n\nConvert a number or strin..
q).p.help n / interactive help
```


### Aliases in the root

For convenience, `p.q` defines `print` and `help` in the default namespace of q, as aliases for `.p.print` and `.p.help`. To prevent this, comment out the relevant code in `p.q` before loading.

```q
{@[`.;x;:;get x]}each`help`print; / comment to remove from global namespace
```


## Closures and generators


### Closures

Closures allow us to define functions that retain state between successive calls, avoiding the need for global variables.

To create a closure in embedPy, we must:

1.  Define a function in q with
    -   two or more arguments: the current state and at least one other (possibly dummy) argument
    -   two return values: the new state and the return value
1.  Wrap the function using `.p.closure`, which takes 2 arguments:
    -   the q function
    -   the initial state

**Functions without arguments** The dummy argument is needed if we want the resulting function to take no arguments.


#### Example 1: `til`

We can define a closure to return incrementing natural numbers, similar to the q `til` function.

The state `x` is the last value returned

```q
q)xtil:{[x;dummy]x,x+:1}
```

Create the closure with initial state `-1`, so the first value returned will be 0

```q
q)ftil:.p.closure[xtil;-1][<]
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

Generators are objects that we can iterate over (e.g. in a for-loop) to produce sequences of values.
EmbedPy allows us to produce generators for use in Python functions and statements where they are required.

To create a generator in embedPy, we must

1.  Define a function in q (as per closures) with:
    -   2 arguments - the current state and a dummy argument
    -   2 return values - the new state and the return value
1.  Wrap the function using `.p.generator`, which takes 3 arguments:
    -   the q function
    -   the initial state
    -   the max number of iterations, or `::` to run indefinitely


#### Example 1: Factorials

The _factorial_ ($n!$) of a non-negative integer $n$, is the product of all positive integers less than or equal to $n$.

We can create a sequence of factorials (starting with 1), with the sequence  

$$x(n) = x(n-1) \times n$$

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

-   `1` is read off as “one 1” or 11.
-   `11` is read off as “two 1s” or 21.
-   `21` is read off as “one 2, then one 1” or 1211.
-   `1211` is read off as “one 1, one 2, then two 1s” or 111221

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
