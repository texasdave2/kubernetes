#!/bin/bash

## this script installs helm components with a bit of error checking and user interaction

## EXCLUDE CERTAIN COMPONENT DIRECTORIES HERE IN THIS FORMAT

## exclude components here:
EXCLUDE_DIR="COMPONENT1\|COMPONENT2\|COMPONENT3"


## INSTALL IN A CERTAIN ORDER
INSTALL_ORDER=("COMPONENT1" "COMPONENT2" "COMPONENT3")


## gather list of included components, display for approval

while read -r line ; do
  echo "Including in this install: $line"
done < <(ls -d */ | grep -v $EXCLUDE_DIR | sed 's:/*$::')

echo "++++++++++++++++++++++++++++++++++++++"

read -p "Continue with install? (y) or (n):  " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then

## iterate through the other components that are helm installed in the array in the correct order
## according to the order above in the array list

  for line in "${INSTALL_ORDER[@]}"
  do
    printf "\n"
    echo "+++++++++++++++++++ Installing $line ++++++++++++++++++++"
    printf "\n"
    echo "my fake command: sudo /usr/local/sbin/helm install -n $line $line &"
    wait
    printf "\n"
    echo "searching for pods installed: sudo kubectl get pods | grep -w $line | awk '{print $1}'"

## check for running or completed status of installed components pod set
## some pods have multiple replicas, all of them must be checked for status

      for i in $(sudo kubectl get pods | grep $line | awk '{print $1}'); do
        phase_status=$(sudo kubectl get pod $i -o jsonpath='{.status.phase}')

        if [ "$phase_status" = "Running" ] || [ "$phase_status" = "Succeeded" ]; then
          echo "component $line installed as pod $i has phase status of: $phase_status"
          echo "moving on to next component"
          continue

        elif [ "$phase_status" = "Pending" ]; then
          echo "component $line as pod $i phase status is: $phase_status"
          echo "waiting 10 seconds and will check status again"
          sleep 10s

        else
          echo "Unknown status or other failure, exiting."
          break
        fi

      done

  done

fi

