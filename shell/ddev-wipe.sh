#!/bin/bash

if [ "$1" = "" ]; then
  read -p "Project directory: " Response
  if [ "$Response" = "" ]; then
    exit
  fi
  PROJECTDIR=$Response
else
  PROJECTDIR=$1
fi
STARTDIR=$(pwd)

if [ ! -d "$PROJECTDIR/.ddev" ]; then
  echo "$PROJECTDIR does not appear to be a DDEV project (no .ddev directory)"
  exit
fi;

read -p "Do you wish to delete the DDEV project at $PROJECTDIR? (y/n): " Response
if [[ ! $Response =~ ^[yY]$ ]]
then
  exit
fi

chmod -R u+w $PROJECTDIR
cd $PROJECTDIR
ddev delete -Oy
cd $STARTDIR

chmod u+w $PROJECTDIR
rm -r $PROJECTDIR

echo "Files and configuration in $PROJECTDIR deleted."
