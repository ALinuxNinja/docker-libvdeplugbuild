FROM ubuntu:17.04

## Set ENV
ENV Build=Ubuntu_17.04

## Create Directories
RUN mkdir source repo

WORKDIR /root/source
## Get Sources
ADD src/sources.list /etc/apt/sources.list
## Install OSC and required packages
ADD http://download.opensuse.org/repositories/openSUSE:Tools/xUbuntu_17.04/Release.key Release.key
RUN apt-key add - < Release.key \
&& rm Release.key \
&& echo "deb http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_17.04/ /" >> /etc/apt/sources.list.d/osc.list \
&& apt-get update \
&& apt-get -y --allow-unauthenticated install osc \
&& apt-get source vde2 \
&& mv *.dsc $(echo "$(ls *.dsc)" | awk -F".dsc" '{print $1}').${Build}.dsc \
&& rm -r vde2-*

## Copy over files
ADD src/oscrc /root/.oscrc
RUN printf "user = ${OBS_USER} \n" >> /root/.oscrc
RUN printf "pass = ${OBS_PASS} \n" >> /root/.oscrc

## Upload to OpenSuse Build Service
RUN osc checkout home:alinuxninja:tinc \
&& cd /root/repo/"home:alinuxninja:tinc"/libvdeplug2/ \
&& rm *Ubuntu_17.04.dsc \
&& mv /root/source/* . \
&& osc addremove \
&& osc ci . -m "Automatic Codeship build"
