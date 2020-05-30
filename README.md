# embedPy

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/embedPy)](https://github.com/kxsystems/embedpy/releases) [![Travis (.org) branch](https://img.shields.io/travis/kxsystems/embedpy/master?label=travis%20build)](https://travis-ci.org/kxsystems/embedpy/branches) [![AppVeyor branch](https://img.shields.io/appveyor/ci/jhanna-kx/embedpy-ax90d/master?label=appveyor%20build)](https://ci.appveyor.com/project/jhanna-kx/embedpy-ax90d/branch/master)

Allows the kdb+ interpreter to manipulate Python objects and call Python functions.
Part of the [_Fusion for kdb+_](https://code.kx.com/v2/interfaces/fusion/) interface collection.

Please direct any questions to ai@kx.com.

Please [report issues](https://github.com/KxSystems/embedpy/issues) in this repository.


## Requirements

- kdb+ ≥ 3.5 64-bit/32-bit(Linux/Arm)
- Python ≥ 3.5.0 (macOS/Linux/Arm) ≥ 3.6.0 windows


## Overview

You can either

*   install embedPy to run on your local machine; or 
*   download or build a Docker image in which to run embedPy

There are three ways to install embedPy on your local machine:

1.  Download and install a release

1.  Clone and build from source, on your local machine or in a Docker image

1.  Install with Conda - recommended for use with

    -   Anaconda Python
    -   [mlnotebooks](https://github.com/KxSystems/mlnotebooks) 
    -   [JupyterQ](https://github.com/KxSystems/jupyterq)

32-bit Linux/Arm builds require users to build from source, there is not currenly a conda build or provided pre-compiled binary.

### Anaconda Python

If you are using Anaconda Python, we recommend installing with Conda. If, instead, you take option (1) or (2) above, and are using Linux or macOS, set your `LD_LIBRARY_PATH` (Linux) or `DYLD_LIBRARY_PATH` (macOS) to your Python distributions library directory to avoid conflicts between libraries which both q and Python use (e.g. `libz`, `libssl`). You can find this directory's location in Python.

```python
>>> import sysconfig
>>> sysconfig.get_config_var('LIBDIR')
```


### PyQ 

If you are currently using [PyQ](https://code.kx.com/v2/interfaces/pyq/), both interfaces use a file `p.k` in `$QHOME/{l64,m64}` which results in a conflict when both are installed. 

You may want to run initially from another directory, without installing. Skip the install step above, and run q in the directory where you unzipped the release.

### Test script

The test script `test.q` requires the packages listed in `tests/requirements.txt`, although embedPy does not itself require them. They can be installed using `pip` or `conda`.

```bash
pip install -r tests/requirements.txt
```
or
```bash
conda install --file tests/requirements.txt
```

If the tests all pass, no message is displayed. 


## Install on local machine

### Download and install a release

1.  Download a release archive from the [releases](../../releases/latest) page, and unzip it.

1.  In the unzipped directory, run the [tests](#test-script).

    ```bash
    $ q test.q
    ```

1.  Install: put `p.q` and `p.k` in QHOME and the library file (`p.so` for macOS/Linux or `p.dll` for Windows) in `$QHOME/{l64,m64,w64}`. 


### Clone and build from source

1.  Clone this repository from GitHub.

2.  To run embedPy without Internet access, download the kdb+ [C API header file](https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h) and place it in the build directory.

3.  Build the interface and run the [tests](#test-script).

    ```bash
    $ make p.so && q test.q
    ```

4.  Install: put `p.q` and `p.k` in `$QHOME` and `p.so` in `$QHOME/{l64,l32,m64}`.


**Notes**

* For ease of install on 32-bit Arm and linux it is suggested that a new user should use a miniconda version of python specific to the architecture being used, `for example rpi for raspberry pi`. This is not an explicit requirement but makes install of embedPy and python packages more seamless.

* Installation of embedPy on a 32-bit arm system may also necessitate the addition of the `libpython` shared object to an access point available to embedPy. For example if Python is located within `/usr/lib/arm-linux-gnueabihf/` which may not be accessible then creating a symlink to `/usr/lib` will allow the shared object to be located.
	```bash
	ln -s /usr/lib /usr/lib/arm-linux-gnueabihf
	``` 

### Install with Conda

This requires either macOS or Linux.

1.  [Download and install](https://conda.io/docs/user-guide/install/download.html) either the full Anaconda distribution or Miniconda for Python3

2.  Use the `conda` command to install packages as follows:

    ```bash
    $ conda install -c kx embedPy
    ```


## Run on local machine

Start q with embedPy
```bash
$ q p.q
```
Or from q, load `p.q`.
```q
q)\l p.q
```

Documentation is on the [embedPy](https://code.kx.com/v2/ml/embedpy/) homepage.


## Run a Docker image

If you have [Docker](https://www.docker.com/community-edition) installed, instead of installing embedPy on your machine, you can run:

```bash
$ docker run -it --name myembedpy kxsys/embedpy
kdb+ on demand - Personal Edition

[snipped]

I agree to the terms of the license agreement for kdb+ on demand Personal Edition (N/y): y

If applicable please provide your company name (press enter for none): ACME Limited
Please provide your name: Bob Smith
Please provide your email (requires validation): bob@example.com
KDB+ 3.5 2018.04.25 Copyright (C) 1993-2018 Kx Systems
l64/ 4()core 7905MB kx 0123456789ab 172.17.0.2 EXPIRE 2018.12.04 bob@example.com KOD #0000000

q)
```

See [docker/README.md](docker/README.md) for more details.


## Back-incompatible changes

### V1.0 -> V 1.1

`.p.key` and `.p.value` removed


### V0.2-beta -> V1.0

-   Attribute access from `embedPy` object

    ```q
    q)obj`ATTRNAME   / old
    q)obj`:ATTRNAME  / new
    ```

-   `embedPy` objects can be called directly without explicitly specifying the call return type; the default return type is an `embedPy` object


### V0.1-beta -> V0.2beta in V0.2-beta

V0.2-beta features a number of changes back-incompatible with the previous release, V0.1-beta.

Most notably, the default _type_ used in many operations is now the `embedPy` type, rather than the `foreign` type.
