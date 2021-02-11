# syntax=docker/dockerfile:1.0-experimental

#define base image; replace with your image location once hardened
FROM opensuse/Leap-15.2.x86_64

#define maintiner 
LABEL maintainer="nick.reva@snap.com"

#define version
LABEL version="V1"

# create a directory to work in
RUN mkdir udacity \
    && cd udacity

#install dependencies and packages for the project 
RUN set -x \
    && zypper refresh \
    && zypper install \
    && git-core \
    && GO \
    && flex \
    && python \
    && python-pip

#set ports
EXPOSE 8080

#add local user
USER $SEC_USER