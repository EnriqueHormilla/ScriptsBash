#!/bin/bash
ROOT_UID=0
SUCCESS=0
FAIL=1
E_USEREXISTS=70

# Run as root, of course. (this might not be necessary, because we have to run the script somehow with root anyway)
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

#test, if both argument are there
if [ $# -eq 2 ]; then
username=$1
pass=$2

        # Check if user already exists.
        grep -q "$username" /etc/passwd
        if [ $? -eq $SUCCESS ]
        then
        echo "User $username does already exist."
        echo "please chose another username."
        exit
        fi

        mkdir -p /var/sftp/"$username"
        if [ $? -eq $FAIL ]
        then
        echo "Problem while creating folder"
        exit 
        fi

        useradd -d /var/sftp/"$username"/archivos "$username" -s /sbin/nologin -g usuarios_sftp
        echo "useradd dio -->$?"
        if [ $? -eq $FAIL ]
        then
        echo "Problem while creating user"
        exit
        fi
        
        echo "$pass" | passwd "$username" --stdin
        if [ $? -eq $FAIL ]
        then
        echo "Problem while creating pasword for user"
        exit
        fi

        echo "Match user $username"  >> /etc/ssh/sshd_config 
        echo "ChrootDirectory /var/sftp/"$username""  >> /etc/ssh/sshd_config 
        echo "ForceCommand internal-sftp"  >> /etc/ssh/sshd_config
	
	

        echo "User $username has been created"

else
        echo  " this programm needs 2 arguments you have given $# "
        echo  " you have to call the script $0 username and the password "
fi

exit 0
