#!/bin/bash

chmod 777 /dev/ttyUSB0
heyu info #to startup heyu daemon
 
exec $@
