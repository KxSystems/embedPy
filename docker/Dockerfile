FROM debian:9 AS base

# do not clean here, its cleaned later!
RUN apt-get update \
	&& apt-get -yy upgrade

####

FROM base AS embedpy

ARG embedpy_url=https://github.com/KxSystems/embedPy.git
ARG embedpy_tag=1.1

RUN apt-get -yy --no-install-recommends install ca-certificates wget build-essential \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

COPY . /opt/kx/embedPy

RUN make -C /opt/kx/embedPy p.so

####

FROM base

ARG VCS_REF=dev
ARG BUILD_DATE=dev

LABEL	org.label-schema.schema-version="1.0" \
	org.label-schema.name=embedPy \
	org.label-schema.description="Allows the kdb+ interpreter to call Python functions" \
	org.label-schema.vendor="Kx" \
	org.label-schema.license="Apache-2.0" \
	org.label-schema.url="https://code.kx.com/q/ml/embedpy/" \
	org.label-schema.version="${VERSION:-dev}" \
	org.label-schema.vcs-url="https://github.com/KxSystems/embedPy.git" \
	org.label-schema.vcs-ref="$VCS_REF" \
	org.label-schema.build-date="$BUILD_DATE" \
	org.label-schema.docker.cmd="docker run -v `pwd`/q:/tmp/q -p $PORT:$PORT kxsys/embedpy"

RUN apt-get -yy --no-install-recommends install unzip rlwrap python3 libpython3.5 runit \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN passwd -d root
RUN useradd -s /bin/bash -U -m kx
COPY docker/profile-env /etc/profile.d/kxsys-embedpy.sh
COPY docker/env /opt/kx/.env

ENV QHOME=/opt/kx/q

RUN mkdir -p $QHOME/l64

COPY --from=embedpy /opt/kx/embedPy /opt/kx/embedPy
RUN ln -s -t $QHOME/l64 /opt/kx/embedPy/p.so \
	&& ln -s -t $QHOME /opt/kx/embedPy/p.q /opt/kx/embedPy/p.k

COPY docker/init /init

ENTRYPOINT ["/init"]
CMD ["/bin/bash"]
