FROM ubuntu:18.04
LABEL maintainer="sguizard@ed.ac.uk"
LABEL OS=Ubuntu
LABEL PROG=TAMA
LABEL REPO=https://github.com/GenomeRIK/tama
LABEL COMMIT d39bc7fedffda5b54aeae7337fe92f17ae5c1b03



ENV export LC_ALL=C
ENV export APPS_HOME=/apps
ENV export APP_NAME=${APPS_HOME}/tama
ENV export APP_GIT=https://github.com/GenomeRIK/tama
ENV export APP_COMMIT=d39bc7fedffda5b54aeae7337fe92f17ae5c1b03



ARG BUILD_DATE=`date`
ARG APPS_HOME=/apps
ARG APP_NAME=${APPS_HOME}/tama
ARG APP_GIT=https://github.com/GenomeRIK/tama
ARG APP_COMMIT=d39bc7fedffda5b54aeae7337fe92f17ae5c1b03

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
#RUN echo "export BUILD_DATE=\"${BUILD_DATE}\"" >> $SINGULARITY_ENVIRONMENT




RUN apt update
RUN apt install -y perl-modules

RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt
RUN echo "tzdata tzdata/Zones/Europe select Paris" >> /tmp/preseed.txt
RUN debconf-set-selections /tmp/preseed.txt
#RUN rm /etc/timezone
#RUN rm /etc/localtime
RUN apt-get install -y tzdata


RUN apt-get install -y software-properties-common
RUN apt-add-repository universe
RUN apt install -y dialog
RUN apt install -y python2.7-minimal python-pip git dos2unix ncbi-blast+ bedtools
RUN pip install biopython==1.76
RUN pip install pysam

RUN mkdir $APPS_HOME
WORKDIR $APPS_HOME
RUN git clone $APP_GIT
WORKDIR $APP_NAME
RUN git checkout $APP_COMMIT
RUN DOS_FILES=`find $APP_NAME -type f|grep -v '\.git'|grep -v 'images'`
RUN for i in $DOS_FILES; do dos2unix $i; done

WORKDIR /usr/local/bin
RUN ln -s $APP_NAME/tama_collapse.py
RUN ln -s $APP_NAME/tama_merge.py
RUN for i in $(find /apps/tama/tama_go/ -type f -executable); do sed -i '1s|^|#!/usr/bin/env python\n\n|' $i && ln -s $i; done

RUN apt purge -y git dos2unix
RUN apt autoremove -y
RUN apt clean

