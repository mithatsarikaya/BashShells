#!/bin/bash

# This script creates a new user on the local system.
# You must supply a username as an argument to the script.

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
	echo "You need to be root or run with sudo in order to add new users"
	exit 1
fi

# If the user doesn't supply at least one argument, then give them help.
if [[ "${#}" -eq 0 ]]
then
	echo "usage: ${0} USER_NAME [COMMENT]..."
	echo "You need to give user name and comment for the user"
	exit 1
fi

# The first parameter is the user name.
USER_NAME="${1}"
shift

# The rest of the parameters are for the account comments.
COMMENT="${*}"

# Generate a password.
PASSWORD=$(date +%s%N${RANDOM} | sha256sum | head -c12)

# Create the user with the password.
useradd -c "${COMMENT}" -m ${USER_NAME}

# Check to see if the useradd command succeeded.
if [[ "${?}" -eq 0 ]]
then
	echo "${USER_NAME} added"
else
	echo "${USER_NAME} could not add"
	exit 1
fi
# Set the password.
echo ${PASSWORD} | passwd --stdin ${USER_NAME}
# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
	echo 'Password allocation failed!'
else
	echo 'Password allocation succeded'
fi
# Force password change on first login.
passwd -e ${USER_NAME}
# Display the username, password, and the host where the user was created.
echo
echo "Username is ${USER_NAME}"
echo
echo "Password is ${PASSWORD}"
echo
echo "Host is ${HOSTNAME}"
