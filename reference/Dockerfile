# Filename: Dockerfile
# Author: Kevin Kredit
# License: Creative Commons Zero v1.0 Universal
# Description:
#   Dockerfile to encapsulate build environments

# Image settings
FROM ubuntu:18.04

ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_NAME=builder
ARG MNT_PNT=/host

ENV DEBIAN_FRONTEND=noninteractive

# Basic setup
RUN \
    # Updates
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        apt-utils \
        sudo && \
    # User setup
    groupadd -g $USER_GID $USER_NAME && \
    useradd --create-home -s /bin/bash -u $USER_UID -g $USER_GID $USER_NAME && \
    usermod -aG sudo $USER_NAME && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo

# Image setup
#############

#############
# Final steps
RUN mkdir /host
WORKDIR /host
USER $USER_NAME
