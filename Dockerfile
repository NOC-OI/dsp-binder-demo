ARG SINGLEUSER_BASE=quay.io/jupyterhub/singleuser:5.2.1

FROM ${SINGLEUSER_BASE} AS base
USER root

ADD conda-envs /tmp/conda-envs
ADD apt /tmp/apt

#install dependencies and other stuff that might be useful to users and turn on man pages
RUN \
    apt-get -y update && \
    xargs apt-get -y install < /tmp/apt/base.txt && \
    yes | unminimize ; exit 0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
