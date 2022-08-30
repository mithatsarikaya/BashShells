#!/bin/bash

# This script saves find command output and provides you to copy any line of it to your clipboard

usage() {
echo "Give argument to find"  
exit 1
}

# Check UID to verify user is root or using sudo
if [[ "${UID}" -ne 0 ]]
then
  echo "Use sudo or be root" 
  exit 1
fi

# Check if user gives one parameter
if [[ "${#}" -ne 1 ]]
then
  usage
fi

echo "looking for ${*} in the file system"

FILENAME=${1}$(date +%N).txt
find / -name "${1}" 2>/dev/null 1> "${FILENAME}"

echo "****************************************************"
echo "${FILENAME} created"
echo "****************************************************"
cat "${FILENAME}" -n

# Check whether xclip is available or not

if [[ $(which xclip | wc -l) -eq 0 ]] 
then
  echo "if you want to choose a path to copy your clipboard you need to install 'xclip'"
  exit 0
fi


read -p "if you want to copy the file path to clipboard enter the number or you can simply ctrl+c or [nN] for exit:      " ANSWER

NUMBER_OF_LINES=$(cat "${FILENAME}" | wc -l)

# if user wants to end the seesion need to give n or N
if [[ "${ANSWER}" = [nN] ]]
then
  exit 0
# Check if the input is number and it is less than or equal to 'find command' output file
elif [[ ${ANSWER} =~ ^[0-9]+$ && "${ANSWER}" -le "${NUMBER_OF_LINES}" ]]
then
  i=0
  while read line; do
    i=$(( i + 1 ))
    case $i in $ANSWER) 
      echo "${line}"
      echo ${line} | xclip -sel clip
      break;; 
    esac
  done <"${FILENAME}"
else
  echo "${ANSWER} is not a valid option"
  exit 1
fi

exit 0





