#!/bin/bash

if ! command -v unzip &> /dev/null
then
    echo "Please, install \"unzip\" to use this script"
    exit
fi

ARCHIVE="open_me.zip"
UNZIPPED_FOLDER="open_me"
PASSWORDS_FILE="passwords.txt"

ROOT=$PWD
TMP_FILE=$ROOT/.cracktmp

if [ "$1" == "build" ]
then
  dune build
elif [ ! -f $ROOT/password_finder.exe ]
then
    echo "Could not find password finder executable"
    echo "Please, run \"dune build\" or provide the argument: \"./crack build\""
    exit
fi

START=`date +%s`

while true
do
  # Run password finder on the file with encrypted passwords
  $ROOT/password_finder.exe $PASSWORDS_FILE | tee $TMP_FILE
  # Get decrypted passwords
  PASSWORDS=$(cat $TMP_FILE | awk -F '\t' '{print $2}' | awk -F ' ' '{print $2}')
  # Try passwords to unzip the archive until the right one is found
  for password in $PASSWORDS
  do
    UNZIP_OUTPUT=$(unzip -P $password $ARCHIVE 2>&1)
    INCORRECT_PASSWORD=$(echo $UNZIP_OUTPUT | grep -i "incorrect password")
    if [ -z "$INCORRECT_PASSWORD" ]
    then
      echo "Cracked using \"$password\""
      break
    else
      # Remove empty folder after wrong password guess
      rm -rf $UNZIPPED_FOLDER
    fi
  done

  rm $TMP_FILE
  cd $UNZIPPED_FOLDER

  if [ ! -e $PASSWORDS_FILE ]
  then
    END=`date +%s`
    echo "Finished cracking (took about $((END-START)) seconds)"
    break
  fi
done

cd $ROOT

if [ "$1" == "build" ]
then
  dune clean
fi
