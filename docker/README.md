# Run

If you have [Docker installed](https://www.docker.com/community-edition) there is a prebuilt docker image you can run with:

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

For subsequent runs, you will not be prompted to redo the license setup when calling:

    $ docker start -ai myembedpy
    KDB+ 3.5 2018.04.25 Copyright (C) 1993-2018 Kx Systems
    l64/ 4()core 7905MB kx 0123456789ab 172.17.0.2 EXPIRE 2018.12.04 bob@example.com KOD #0000000
    
    q)

If you prefer to drop straight into `bash` you can with:

    $ docker run -it kxsys/embedpy bash
    [snipped license setup]
    kx@8ac226623908:~$ conda info
    
         active environment : kx
        active env location : /home/kx/.conda/envs/kx
    [snipped]
    kx@8ac226623908:~$ q
    KDB+ 3.5 2018.04.25 Copyright (C) 1993-2018 Kx Systems
    l64/ 4()core 7905MB kx 0123456789ab 172.17.0.2 EXPIRE 2018.12.04 bob@example.com KOD #0000000
    
    q)

**N.B.** [build instructions for the image are available](README.md#build)

## Headless/Presets

If you are running this in a headless configuration, or wish to provide out-of-bound the answers to the license process, then you can call upon the following environment variables.  This is handled either by [`--env` (or `--env-file`) as detailed on the docker website](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file).

 * **`KDB_LICENSE_AGREE`:** pass in `yes` (case-insensitive) to agree to the license agreement
 * **`COMPANY` (optional):** provide company name
 * **`NAME`:** provide your name
 * **`EMAIL`:** provide your email address

If any of these are missing, then you will be prompted for the value as before.

**N.B.** alternatively if you already have a licence you can use `QLIC_KC` (also supported is `QLIC_K4`) which is the base64 encoded contents of your `kc.lic` file

This allows for the following usage:


    $ echo \\\\ | docker run -i -e QLIC_KC=$(cat $QHOME/kc.lic | base64 -w0) --name myembedpywithlic kxsys/embedpy q -q
    $ echo 'p)print(1+2)' | docker start -i myembedpywithlic
    3


# Build

The instructions below are for building your own Docker image. A prebuilt Docker image is available on Docker Cloud, if you only want to run the embedPy image then install Docker and [read the instructions above](README.md#run) on how to do this.

## Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with:

    git clone https://github.com/KxSystems/embedPy.git

## Building

To build locally the project you run:

    docker build -t embedpy -f docker/Dockerfile .

Once built, you should have a local `embedpy` image, you can run the following to use it:

    docker run -it embedpy

# Deploy

[travisCI](https://travis-ci.org/) is configured to monitor when tags of the format `/^[0-9]+\./` are added to the [GitHub hosted project](https://github.com/KxSystems/embedPy), a corresponding Docker image is generated and made available on [Docker Cloud](https://cloud.docker.com/)

This is all done server side as the resulting image is north of 350MB.

To do a deploy, you simply tag and push your releases as usual:

    git push
    git tag 0.7
    git push --tag


## Related Links

 * [Docker](https://docker.com)
     * [`Dockerfile`](https://docs.docker.com/engine/reference/builder/)
