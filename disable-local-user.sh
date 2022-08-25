#!/bin/bash

# This script deletes or disables multiple user.

ARCHIVE_DIR='/archive'

# Display the usage and exit.
usage() {
echo "Usage: ./disable-local-user.sh [-dra] USER [USERN]"
echo "Disable a local Linux account."
echo "-d Deletes accounts instead of disabling them."
echo "-r Removes the home directory associated with the account(s)."
echo "-a Creates an archive of the home directory associated with the
accounts(s) to /archive."
exit 1
}

check_exit_status() {
  NON_ZERO_MESSAGE="${1}"
  if [[ "${?}" -ne 0 ]]
  then
    echo "${NON_ZERO_MESSAGE}" >&2
    exit 1
  fi
}

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo "Run with sudo or as root"
  usage
  exit 1
fi



# Parse the options.
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER='true';;
    r) REMOVE_OPTION='-r';;
    a) ARCHIVE='true';;
  esac
done
			
# Remove the options while leaving the remaining arguments.
shift $(( ${OPTIND} - 1 ))
# If the user doesn't supply at least one argument, give them help.
if [[ "${#}" -lt 1 ]]
then
  echo 'You need to give at least one username to process'
fi

# Loop through all the usernames supplied as arguments.
for USERNAME in "${@}"
do
  USERID=$(id ${USERNAME} -u)
  # Make sure the UID of the account is at least 1000.
  if [[ "${USERID}" -lt 1000 ]]
  then
    echo "${USERNAME} UID must be at least 1000" >&2
    exit 1
  fi

  # Create an archive if requested to do so.
  if [[ "${ARCHIVE}" = 'true' ]]
  then
    # Make sure the ARCHIVE_DIR directory exists.
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "Creating ${ARCHIVE_DIR} directory"
      mkdir -p ${ARCHIVE_DIR}
      check_exit_status "The archieve directory could not be created"
    fi		
    # Archive the user's home directory and move it into the ARCHIVE_DIR
    HOME_DIR="/home/${USERNAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
      check_exit_status "Could not create ${ARCHIVE_FILE}."
    else
      echo "${HOME_DIR} does not exist or is not a directory" >&2
      exit 1
    fi
  fi
# tar -z:compress  c:create an archive f:location of the archive file
# Delete the user.
  if [[ "${DELETE_USER}" = 'true' ]]
  then
    userdel ${REMOVE_OPTION} ${USERNAME}
    # Check to see if the userdel command succeeded.
    check_exit_status "The account ${USERNAME} was NOT deleted"
    echo "The account ${USERNAME} was deleted"
  else
    chage -E 0 ${USERNAME}
    # Check to see if the chage command succeeded.
    # We don't want to tell the user that an account was disabled when it hasn't been.
    check_exit_status "The account ${USERNAME} was NOT disabled"
  fi
done

exit 0
