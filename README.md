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

**Watch out** If you are currently using [PyQ](https://code.kx.com/q/interfaces/pyq/), it also has a file `p.so` in `$QHOME/{l64|m64}`. In this case, you may want to run initially from the local directory without installing. Skip the install step and run q in the directory where you unzipped the release to do this.

### Building from source

Build the interface and run sanity checks with 

```bash
make p.so && q test.q
```
If running in an environment without Internet access, you will need to download the kdb+ [C API header file](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h) manually and place in the build directory.

To install, place `p.q` and `p.k` in `$QHOME` and `p.so` in `$QHOME/{l64|m64}`.  


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
