# embedPy


Allows the kdb+ interpreter to manipulate Python objects and call Python functions.
Part of the [_Fusion for kdb+_](http://code.kx.com/q/interfaces/fusion/) interface collection.

Please direct any questions to ai@kx.com.

Please [report issues](https://github.com/KxSystems/embedpy/issues) in this repository.


## Requirements

- kdb+ >=3.5 64-bit
- Anaconda Python 3.x

## Installation
### Download

Download the appropriate release archive from the [releases](../../releases/latest) page.

Run tests with 
```bash
q test.q
```

To install, place `p.q` and `p.k` in `$QHOME` and place the library file (`p.so` for OSX/Linux or `p.dll` for Windows)  in `$QHOME/{l64|m64|w64}`

**Watch out** On OSX and Linux if you are using Anaconda python rather than the system python, you should set your LD_LIBRARY_PATH (on Linux) or DYLD_LIBRARY_PATH (on OSX) to your python distributions library directory before starting q to avoid conflicts between libraries which both q and python use (e.g. `libz`, `libssl`) , you can find this directory's location in python.

```python
>>> import sysconfig
>>> sysconfig.get_config_var('LIBDIR')
```



**Watch out** If you are currently using [PyQ](https://code.kx.com/q/interfaces/pyq/), it also has a file `p.so` in `$QHOME/{l64|m64}`. In this case, you may want to run initially from the local directory without installing. Skip the install step and run q in the directory where you unzipped the release to do this.

### Building from source

Build the interface and run sanity checks with 

```bash
make p.so && q test.q
```
If running in an environment without Internet access, you will need to download the kdb+ [C API header file](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h) manually and place in the build directory.

To install, place `p.q` and `p.k` in `$QHOME` and `p.so` in `$QHOME/{l64|m64}`.  

### Docker

If you have [Docker installed](https://www.docker.com/community-edition) you can alternatively create a directory called `q` and place your `kc.lic` (or `k4.lic`) and `l64.zip` files into a `q` directory and run:

    $ docker run --rm -it -v `pwd`/q:/tmp/q kxsys/embedpy
    kx@1ba5d6c29709:~$ q
    KDB+ 3.5 2017.11.08 Copyright (C) 1993-2017 Kx Systems
    l64/ 4(16)core 7905MB kx 0123456789ab 172.17.0.2 EXPIRE 2018.12.04 bob@example.com KOD #0000000
    
    q)

You can drop straight into `q` with:

    $ docker run --rm -it -v `pwd`/q:/tmp/q kxsys/embedpy q
    KDB+ 3.5 2017.11.08 Copyright (C) 1993-2017 Kx Systems
    l64/ 4(16)core 7905MB kx 0123456789ab 172.17.0.2 EXPIRE 2018.12.04 bob@example.com KOD #0000000
    
    q)

Lastly you can also pipe your program in:

    $ echo 'p)print(1+2)' | docker run --rm -i -v `pwd`/q:/tmp/q kxsys/embedpy q -q
    3

**N.B.** [build instructions for the image are available](docker/README.md)

## Usage

From q, load `p.q`.
```q
q)\l p.q
```


## Documentation

Documentation is available on the [embedPy](https://code.kx.com/q/ml/embedpy/) homepage.


## Back-incompatible changes
### V1.0 -> V 1.1
`.p.key` and `.p.value` removed

### V0.2-beta -> V1.0

- Attribute access from embedPy object 

```q
q)obj`ATTRNAME   / old
q)obj`:ATTRNAME  / new
``` 

- `embedPy` objects can be called directly without explicitly specifying the call return type, the default return type is an `embedPy` object


### V0.1-beta -> V0.2beta in V0.2-beta

V0.2-beta features a number of changes back-incompatible with the previous release, V0.1-beta. 

Most notably, the default _type_ used in many operations is now the embedPy type, rather than the foreign type. <!-- Differences between these types (and the associated APIs) are set out below. --> 
