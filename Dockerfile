FROM ubuntu:17.04

## Set ENV
ENV Build=xUbuntu_17.04

## Encrypted Args
ARG OBS_USER
ARG OBS_PASS

## Create Directories
RUN mkdir source repo

## Get Sources
WORKDIR /root/source
ADD src/sources.list /etc/apt/sources.list

## Install OSC and required packages
ADD http://download.opensuse.org/repositories/openSUSE:Tools/xUbuntu_17.04/Release.key Release.key
RUN apt-key add - < Release.key \
&& rm Release.key \
&& echo "deb http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_17.04/ /" >> /etc/apt/sources.list.d/osc.list \
&& apt-get update \
&& apt-get -y --allow-unauthenticated install osc \
&& apt-get -y install dpkg-dev \
&& apt-get source vde2 \
&& mv *.dsc vde2-${Build}.dsc \
&& find . -d -type d -exec rm -rf '{}' \;

## Copy over files
ADD src/oscrc /root/.oscrc
RUN printf "user = ${OBS_USER} \n" >> /root/.oscrc
RUN printf "pass = ${OBS_PASS} \n" >> /root/.oscrc

## Upload to OpenSuse Build Service
WORKDIR /root/repo
RUN osc checkout home:alinuxninja:tinc \
&& cd /root/repo/"home:alinuxninja:tinc"/vde2-xUbuntu_17.04/ \
&& rm -f *Ubuntu_17.04.dsc \
&& mv /root/source/* . \
&& osc addremove \
&& osc ci . -m "Automatic Codeship build"
