#!/bin/bash



filepath=$(cd "$(dirname "$0")"; cd ..; pwd;)

$filepath/lib/dm303Scaner.py  #> runtime_log_hourly 2>&1

