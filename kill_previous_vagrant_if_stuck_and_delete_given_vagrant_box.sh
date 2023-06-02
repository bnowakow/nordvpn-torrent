#!/bin/bash

kill -9 $(ps aux | grep vagrant-basebox | grep VBoxHeadless | awk '{print $2}');
# TODO
echo TODO change 20230524.0.0 to latest ubuntu/jammy64 version
vagrant box remove ubuntu/jammy64 --box-version 20230524.0.0;

