# Frequently-asked questions 

## Installing embedPy on system with Python installed from source?

When installing embedPy on a system where Python was installed manually a common error which can occur is `'libpython`. This error commonly results from a Python install which has not been enabled to allow shared libraries.

If this error occurs run the following to display output to indicate if the issue is related to the python build

```q
q)key each hsym each`$`L`M#.p
L| `:/root/anaconda3/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7m.a
M| `:/root/anaconda3/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7m.a
```

In the above example case the `libpython` files are static `.a` files rather than `.so` files. To recitfy complete one of the following

1. Reinstall Python with the system enabled to allow the python shared objects to be shared with other programs. This can be achieved using instructions provided [here](https://www.iram.fr/IRAMFR/GILDAS/doc/html/gildas-python-html/node36.html). With particular care to be taken in the `./configure --enable-shared` step. If following the instructions in the link provided ensure you install a version of Python suitable for use with embedPy.
2. Create a symlink between a static `.a` file and a `.so` file associated with the Python build if one exists.

If neither of the above solutions work please contact ai@kx.com with detailed instructions indicating the steps taken to solve the problem.

## How can I convert between q tables and pandas DataFrames?

Using embedPy, we can directly convert between q tables to pandas Dataframes and vice-versa. This functionality is contained within the machine learning toolkit available [here](https://github.com/kxsystems/ml). The functions `.ml.tab2df` and `.ml.df2tab` control these conversions and are [fully documented](https://github.com/KxSystems/ml/tree/master/util).


## How can I convert q dates to Python dates?

In q, there are three date types (date, month and timestamp) that map to Python or NumPy `datetime64` types. 

> **Not datetime**
> 
> We ignore the kdb+ datetime type here, deprecated due to the underlying floating-point representation.

To convert these dates:

1.  Adjust to the Unix epoch (1970.01.01)
2.  Convert to a NumPy array with the appropriate `datetime64` type/precision


### Dates

Create a list of dates.

```q
q)show datelist:6?"d"$0
2000.12.11 2000.01.15 2000.02.02 2003.08.16 2002.04.24 2000.03.22
```

Adjust for the Unix epoch

```q
q)"j"$datelist-1970.01.01
11302 10971 10989 12280 11801 11038
```

and convert to a NumPy array (with `datetime64[D]` type).

```q
q)print .p.import[`numpy;`:array]["j"$datelist-1970.01.01;`dtype pykw"datetime64[D]"]
['2000-12-11' '2000-01-15' '2000-02-02' '2003-08-16' '2002-04-24' '2000-03-22']
```


### Months

Create a list of months.

```q
q)show monthlist:6?"m"$0
2000.12 2002.02 2003.12 2000.12 2003.11 2000.07m
```

Adjust for the Unix epoch

```q
q)"j"$monthlist-1970.01m
371 385 407 371 406 366
```

and convert to a NumPy array (with `datetime64[M]` type).

```q
q)print .p.import[`numpy;`:array]["j"$monthlist-1970.01m;`dtype pykw"datetime64[M]"]
['2000-12' '2002-02' '2003-12' '2000-12' '2003-11' '2000-07']
```


### Timestamps

Create a list of timestamps.

```q
q)show stamplist:6?"p"$0
2003.06.28D17:26:01.260806768 2002.08.17D16:36:35.216906816 2003.11.07D05:38:..
```

Adjust for the Unix epoch

```q
q)"j"$stamplist-1970.01.01D0
1056821161260806768 1029602195216906816 1068183533870536832 99357904889686256..
```

and convert to a NumPy array (with `datetime64[ns]` type).

```q
q)print .p.import[`numpy;`:array]["j"$stamplist-1970.01.01D0;`dtype pykw"datetime64[ns]"]
['2003-06-28T17:26:01.260806768' '2002-08-17T16:36:35.216906816'
 '2003-11-07T05:38:53.870536832' '2001-06-26T18:10:48.896862568'
 '2000-09-11T21:28:21.496423780' '2002-05-11T13:56:52.890104944']
```


### `q2pydts`

The `q2pydts` function converts all three date types to the equivalent `datetime64` type.

```q
q2pydts:{.p.import[`numpy;
                   `:array;
                   "j"$x-("pmd"t)$1970.01m;
                   `dtype pykw "datetime64[",@[("ns";"M";"D");t:type[x]-12],"]"]}
```

```q
q)print q2pydts datelist
['2000-12-11' '2000-01-15' '2000-02-02' '2003-08-16' '2002-04-24' '2000-03-22']

q)print q2pydts monthlist
['2000-12' '2002-02' '2003-12' '2000-12' '2003-11' '2000-07']

q)print q2pydts stamplist
['2003-06-28T17:26:01.260806768' '2002-08-17T16:36:35.216906816'
 '2003-11-07T05:38:53.870536832' '2001-06-26T18:10:48.896862568'
 '2000-09-11T21:28:21.496423780' '2002-05-11T13:56:52.890104944']
```


## How can I convert Python dates to q dates?

To convert these dates,

1.  Check the (`datetime64`) type
2.  Convert to q (as `int`)
3.  Adjust to the Unix epoch (1970.01.01) as appropriate for the precision

N.B. The Python date type can be extracted (and the precision determined) from the `dtype.name` attribute.


### Dates

```q
q)print pydates
['2000-12-11' '2000-01-15' '2000-02-02' '2003-08-16' '2002-04-24' '2000-03-22']
```

Check type/precision.

```q
q)pydates[`:dtype.name]`
"datetime64[D]"

q)pydates[`:dtype.name;`]11
"D"
```

Convert to q (as `int`).

```q
q)pydates[`:astype;"int64"]`
11302 10971 10989 12280 11801 11038
```

Adjust for the Unix epoch (as `date`).

```q
q)(pydates[`:astype;"int64"]`)+1970.01.01
2000.12.11 2000.01.15 2000.02.02 2003.08.16 2002.04.24 2000.03.22
```


### Months

```q
q)print pymonths
['2000-12' '2002-02' '2003-12' '2000-12' '2003-11' '2000-07']
```

Check type/precision.

```q
q)pymonths[`:dtype.name]`
"datetime64[M]"

q)pymonths[`:dtype.name;`]11
"M"
```

Convert to q (as `int`).

```q
q)pymonths[`:astype;"int64"]`
371 385 407 371 406 366
```

Adjust for the Unix epoch (as `month`).

```q
q)(pymonths[`:astype;"int64"]`)+1970.01m
2000.12 2002.02 2003.12 2000.12 2003.11 2000.07m
```


### Timestamps

```q
q)print pystamps
['2003-06-28T17:26:01.260806768' '2002-08-17T16:36:35.216906816'
 '2003-11-07T05:38:53.870536832' '2001-06-26T18:10:48.896862568'
 '2000-09-11T21:28:21.496423780' '2002-05-11T13:56:52.890104944']
```

Check type/precision.

```q
q)pystamps[`:dtype.name]`
"datetime64[ns]"

q)pystamps[`:dtype.name;`]11
"n"
```

Convert to q (as `int`).

```q
q)pystamps[`:astype;"int64"]`
1056821161260806768 1029602195216906816 1068183533870536832 99357904889686256..
```

Adjust for the Unix epoch (as `timestamp`).

```q
q)(pystamps[`:astype;"int64"]`)+1970.01.01D0
2003.06.28D17:26:01.260806768 2002.08.17D16:36:35.216906816 2003.11.07D05:38:..
```


### `py2qdts`

The `py2qdts` function converts all three `datetime64` types to the equivalent q date type.

```q
py2qdts:{t$(x[`:astype;"int64"]`)+"j"$(t:"pmd" "nMD"?x[`:dtype.name;`]11)$1970.01m}
```

```q
q)py2qdts pydates
2000.12.11 2000.01.15 2000.02.02 2003.08.16 2002.04.24 2000.03.22

q)py2qdts pymonths
2000.12 2002.02 2003.12 2000.12 2003.11 2000.07m

q)py2qdts pystamps
2003.06.28D17:26:01.260806768 2002.08.17D16:36:35.216906816 2003.11.07D05:38:..
```


## How do I convert between q and Python guids?

Due to type restrictions within the underlying Python API a direct conversion between q GUIDs and the Python equivalent UUIDs is not provided within the interface.

Conversions between the two are handled through conversion to an alternative representation on one side and a conversion to a GUID once passed to the other language as in the following examples


### Convert q to Python

In the following code the need to complete conversions on a GUID by GUID basis is due to restrictions in the `uuid` Python module which does not have any array conversion functionality. This conversion is completed via an intermediary string representation

```q
// Generate a random list of GUIDs
q)show guids:2?0Ng
e92aeefb-b363-a793-b925-9c0d327b47a8 fc35ccfc-96e8-98ce-b3c1-f2cad1b9ccd1

// Convert GUIDs to strings
q)show strguid:string guids
"e92aeefb-b363-a793-b925-9c0d327b47a8"
"fc35ccfc-96e8-98ce-b3c1-f2cad1b9ccd1"

// Load the relevant Python functionality to complete conversion
q)uuidconvert:.p.import[`uuid][`:UUID;<]
q)print uuidconvert each strguid
[UUID('e92aeefb-b363-a793-b925-9c0d327b47a8'), UUID('fc35ccfc-96e8-98ce-b3c1-f2cad1b9ccd1') ...
```


### Convert Python to q

As with the conversions from q to Python this requires an initial conversion of the data to an appropriate type: in this case, individual byte objects in Python followed by a conversion of each element to a kdb+ GUID type.

```q
// Create a list of GUIDs in Python
q)p)import uuid
q)p)uuid=(uuid.uuid4(),uuid.uuid4(),uuid.uuid4())
q)p)print(uid)
(UUID('a60e1654-88b0-473c-9700-4094a795b8e6'), UUID('a2ed21a5-eab6-4950-aa8c-41f444601f6f'), UUID('587e26d4-c2e2-4f2e-9ccd-ac281f3f49ce'))

// Retrieve Python GUID list
q)pyguid:.p.get[`uuid]

// Convert from Python to q GUID
q){0x0 sv(.p.wrap x)[`:bytes]`}each pyguid`
a60e1654-88b0-473c-9700-4094a795b8e6 a2ed21a5-eab6-4950-aa8c-41f444601f6f 587..
```


## Is embedPy thread-safe?

EmbedPy is **not** thread-safe. Functions executed on Python threads via embedPy should not call back to execute q functions. This behavior is not supported.


## Can embedPy functions make use of Python multithreading?

Yes, provided the defined Python function does not break the thread-safety consideration above. Assuming that Python is guaranteed not to call q from any job on the threads, these Python threads can safely do work and the result can be returned to q.

## Issues with loading `.p` files

To load `.p` files, embedPy uses the same parsing rules as those used when loading `.q` files into a q session using the syntax `\l test.q`. This imposes some limitations on the Python structures which can be present within a `.p` file.

For example, defining functions using `def` and classes using `class` are supported as the need for indentation in their definitions can be appropriately handled by treating them in the same manner as a q function or select statement which can be multi lined.

However the use of docstrings or unindented comments within a class or function definition are not supported, as in the following examples:

### Docstring 

`docstring.p`

```python
"""
This is a docstring
"""
def func():
        return 1+1
```

When this is loaded into q using embedPy the following occurs.

```q
q)\l p.q
q)\l docstring.p
'e: EOF while scanning triple-quoted string literal (, line 1)
```


### Unindented comments

`unindent.p`
```python
def func():
        value1 = 1
        value2 = 2
# This is a valid comment in python
        return(value1+value2)
```
When this is loaded into q using embedPy the following occurs.

```q
q)\l p.q
q)\l unindent.p
'e: unexpected indent (, line 2)
```

In this case the statement after the comment is being treated as an individual line for evaluation, not as part of the `func` definition.
