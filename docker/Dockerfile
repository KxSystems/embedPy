FROM debian:9 AS base

# do not clean here, its cleaned later!
RUN apt-get update \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io upgrade

####

FROM base AS embedpy

ARG embedpy_url=https://github.com/KxSystems/embedPy.git
ARG embedpy_tag=1.1

RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
		build-essential \
		ca-certificates \
		curl \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

COPY makefile p.* py.* /opt/kx/embedPy/

RUN make -C /opt/kx/embedPy p.so

####

FROM continuumio/miniconda3 AS anaconda

####

FROM base

ARG VCS_REF=dev
ARG BUILD_DATE=dev
ARG L64_URL=https://cl.ly/2r1v1v3h0l41/download/l64.zip
ARG L64_SHA256=28c26f796a7fa9267a3061598fe0e1e34208b4deb5932db42adc78f9d2a74481

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
	org.label-schema.docker.cmd="docker run kxsys/embedpy"

RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
		ca-certificates \
		curl \
		rlwrap \
		runit \
		unzip \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN passwd -d root
RUN useradd -s /bin/bash -U -m kx

ENV QHOME=/opt/kx/q
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/opt/conda/lib

RUN mkdir -p $QHOME
RUN curl -f -o /tmp/l64.zip -L $L64_URL \
	&& [ "$L64_SHA256" = "$(sha256sum /tmp/l64.zip | cut -b1-64)" ] \
	&& unzip -d $QHOME /tmp/l64.zip \
	&& rm /tmp/l64.zip \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io purge unzip
COPY docker/q.wrapper /usr/local/bin/q
COPY docker/kc.lic.py /opt/kx/

COPY --from=embedpy /opt/kx/embedPy /opt/kx/embedPy
RUN ln -s -t $QHOME/l64 /opt/kx/embedPy/l64/p.so \
	&& ln -s -t $QHOME /opt/kx/embedPy/p.q /opt/kx/embedPy/p.k

COPY --from=anaconda /opt/conda /opt/conda

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda update -n base conda \
	&& conda clean -y --all

COPY docker/profile.sh /etc/profile.d/kx.sh

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda create -y -n kx python=3 --no-default-packages

USER root

COPY docker/init /init

ENTRYPOINT ["/init"]
CMD ["q"]
