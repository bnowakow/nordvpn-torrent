#!/bin/bash

while true; do
    date;
    if ! service transmission-daemon status; then 
        # service is not running
        # first line must be run as root
        service transmission-daemon start;  
        service transmission-daemon status;
    fi
    sleep 60;
done

