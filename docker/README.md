The instructions below are for building your own docker image. A prebuilt docker image is available on docker cloud, if you only want to run the embedpy image then install docker and run

```bash
docker run -it -v `pwd`/q:/tmp/q kxsys/embedpy
```

# Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with:

    git clone https://github.com/KxSystems/embedPy.git

# Build

To build locally the project you run:

    docker build -t embedpy -f docker/Dockerfile .

Other build arguments are supported and you should browse the `Dockerfile` to see what they are, but note for Docker Cloud you will need to make sure they are also explicitly exported in [`docker/hooks/build`](hooks/build) too.

Once built, you should have a local `embedpy` image, you can run the following to use it:

    docker run -it -v `pwd`/q:/tmp/q embedpy


# Deploy

[Google Cloud Builder](https://cloud.google.com/container-builder/docs/) is configured to monitor when tags of the format `/^[0-9.]+/` are added to the [GitHub hosted project](https://github.com/KxSystems/embedPy), a corresponding Docker image is generated and made available on docker [Docker Cloud](https://cloud.docker.com/)

This is all done server side as the resulting image is north of 350MB.

To do a deploy, you simply tag and push your releases as usual:

    git push
    git tag 0.7
    git push --tag


## Related Links

 * [Docker](https://docker.com)
     * [`Dockerfile`](https://docs.docker.com/engine/reference/builder/)

