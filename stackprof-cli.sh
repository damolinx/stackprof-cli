#!/bin/sh
#
# Simple Stackprof CLI
# Inspired by https://github.com/quirkey/stackprof-remote
#

load() {
  if [[ "$1" != "$fileName" ]]; then
    fileName="$1"
    baseFileName="$(basename "$fileName")"
    echo "Loaded: $fileName"
  else
    echo "Already loaded, nothing to do."
  fi
}

printError() {
  echo "$(tput setaf 1)$1$(tput sgr 0)"
}

# Init
if [[ $# -eq 0 ]] ; then
  echo "Usage: $(basename "$0") file"
  exit 1
fi

# enable extended pattern matching for commands
shopt -s extglob
#
# Simple Stackprof CLI
# Inspired by https://github.com/quirkey/stackprof-remote
#

# Init
if [[ $# -eq 0 ]] ; then
  echo "Usage: $(basename $0) file"
  exit 1
fi

# enable extended pattern matching for commands
shopt -s extglob

# Print header
echo "Use CTRL+C or 'q' to exit, 'help' for help"
load "$1"
echo

# Prompt

while true; do
  read -e -p "[$baseFileName]>> " cmd
  history -s "$cmd"
  case "$cmd" in
    # ([fF]|[fF]iles)?([:space:])*)
    [fF]?("iles")?([:space:])*)
      top=$(echo "$cmd" | awk '{print $2}')
      if ! [[ -z $top ]]; then
        limit="--limit $top"
      fi
      stackprof $fileName --files $limit
      unset top limit
    ;;
    [hH]?("elp"))
      echo " $(tput bold)f$(tput sgr 0)iles        Show files. Optionally, pass number of results."
      echo " $(tput bold)l$(tput sgr 0)oad path    Sets new file to work with."
      echo " $(tput bold)m$(tput sgr 0)ethod grep  Show details about method."
      echo " $(tput bold)t$(tput sgr 0)op n        Show top methods ordered by inner sample time."
      echo " $(tput bold)to$(tput sgr 0)tal n      Show top methods ordered by total time."
      echo
      echo " $(tput bold)h$(tput sgr 0)elp         Help."
      echo " $(tput bold)q$(tput sgr 0)uit         Quit."
    ;;
    [lL]?("oad")?([:space:])*)
      newFileName=$(echo "$cmd" | awk '{print $2}')
      if ! [[ -z $newFileName ]]; then
        if [[ -f $newFileName ]]; then
          load "$newFileName"
        else
          printError "File not found. File: '$newFileName'."
        fi
      else
        printError "Load requires a file name."
      fi
      unset newFileName
    ;;
    [mM]?("ethod")?([:space:])*)
      name=$(echo "$cmd" | awk '{print $2}')
      if ! [[ -z $name ]]; then
        stackprof $fileName --method "$name"
      else
        printError "Method requires a method name grep expression."
      fi
      unset name
    ;;
    [tT]?("op")?([:space:])*)
      top=$(echo "$cmd" | awk '{print $2}')
      if [[ $top == +([0-9]) ]]; then
        stackprof $fileName --limit $top
      else
        printError "Top requires a numeric value, received '$top'."
      fi
      unset top
    ;;
    [tT]o?("tal")?([:space:])*)
      top=$(echo "$cmd" | awk '{print $2}')
      if ! [[ -z $top ]]; then
        limit="--limit $top"
      fi
      stackprof $fileName --sort-total $limit
      unset top limit
    ;;
    [qQ]?("uit"))
      echo
      echo " Bye!"
      exit 0
    ;;
    *)
      printError "Unknown command '$cmd'."
    ;;
  esac
  echo
done
