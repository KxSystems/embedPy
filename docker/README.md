The instructions below are for building your own Docker image. A prebuilt Docker image is available on Docker Cloud, if you only want to run the embedPy image then install Docker and [read the main instructions](https://github.com/KxSystems/embedPy#docker) on how to do this.

# Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with:

    git clone https://github.com/KxSystems/embedPy.git

# Build

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
