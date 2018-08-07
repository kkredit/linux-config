#!/bin/bash

install -m 644 bashrc /home/$(whoami)/.bashrc
install -m 644 vimrc /home/$(whoami)/.vimrc
install -m 644 gerritrc /home/$(whoami)/.gerritrc

