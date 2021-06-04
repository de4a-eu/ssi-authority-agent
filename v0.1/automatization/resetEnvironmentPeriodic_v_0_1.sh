#!/bin/bash
hourOfReset=01 #set the hour  the reset taking place

hourFromDate=00
valid=true
while [ $valid ]
do	
  hourFromDate=$(date +"%H")
  if [ $hourFromDate -eq $hourOfReset ]
  then
    ./stop-test-environment.sh
    sleep 5m
    ./run-test-environment.sh
    sleep 11h
    sleep 53m 
  fi
  sleep 1s #a second interval so that the terminal is not burdened by while true loop 
done
