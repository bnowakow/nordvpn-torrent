#!/bin/bash

sudo rpcdebug -m rpc -s all
sudo rpcdebug -m nfsd -s all 

sudo journalctl -fl

sudo rpcdebug -m rpc -c all
sudo rpcdebug -m nfsd -c all

