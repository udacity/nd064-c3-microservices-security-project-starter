# syntax=docker/dockerfile:1.0-experimental

#define base image; replace with your image location once hardened
FROM opensuse/leap:latest

#define maintainer 
LABEL maintainer="jdubya747@gmail.com"

#define version
LABEL version="V1"

# create a directory to work in
RUN mkdir -p udacity \
    && cd udacity

#install zypper 
#RUN zypper refs && zypper refresh
RUN zypper ref && zypper up -y
#add local user
USER $SEC_USER
