#!/bin/bash

################################################################################
###
### pre-defined values and param setup
###
################################################################################
SHTBX_CONFIG=$HOME/.shoutbox

SHTBX_HOST=http://shoutbox.io
SHTBX_PORT=80
SHTBX_PROXY_HOST=
SHTBX_PROXY_PORT=

SHTBX_PATH=/status

SHTBX_AUTH_TOKEN=

SHTBX_USER_AGENT="bash shoutbox client (+https://github.com/asaaki/shoutbox-client-lib)"

SHTBX_GROUP=Home
SHTBX_STATUS=
SHTBX_NAME=
SHTBX_MSG=
SHTBX_EXP=

SHTBX_FIELDS=2

################################################################################
###
### configuration
###
################################################################################
config() {
  if [[ ! -f $SHTBX_CONFIG ]]; then
    echo
    echo "Found no .shoutbox config file in $HOME!"
    echo "Please create one."
    echo "For help and auth code go to http://shoutbox.io"
    echo "and follow the steps (when logged in; click on the wrench icon)."
    echo
    exit 7 #code 7 for missing config
  fi
  CFG_SHTBX_AUTH_TOKEN=`awk -F ": " '$1~/^auth_token$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_AUTH_TOKEN ]]; then
    SHTBX_AUTH_TOKEN=$CFG_SHTBX_AUTH_TOKEN
  else
    echo "No Auth_Token found!"
    echo "Get your token from shoutbox.io and save it into your config file!"
    exit 6 #code 6 for missing auth_token in config
  fi
  CFG_SHTBX_HOST=`awk -F ": " '$1~/^host$/ {print $2}' $SHTBX_CONFIG`
  CFG_SHTBX_PORT=`awk -F ": " '$1~/^port$/ {print $2}' $SHTBX_CONFIG`
  CFG_SHTBX_PROXY_HOST=`awk -F ": " '$1~/^proxy_host$/ {print $2}' $SHTBX_CONFIG`
  CFG_SHTBX_PROXY_PORT=`awk -F ": " '$1~/^proxy_port$/ {print $2}' $SHTBX_CONFIG`
  CFG_SHTBX_GROUP=`awk -F ": " '$1~/^group$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_HOST ]]; then SHTBX_HOST=$CFG_SHTBX_HOST; fi
  if [[ -n $CFG_SHTBX_PORT ]]; then SHTBX_PORT=$CFG_SHTBX_PORT; fi
  if [[ -n $CFG_SHTBX_PROXY_HOST ]]; then SHTBX_PROXY_HOST=$CFG_SHTBX_PROXY_HOST; fi
  if [[ -n $CFG_SHTBX_PROXY_PORT ]]; then SHTBX_PROXY_PORT=$CFG_SHTBX_PROXY_PORT; fi
  if [[ -n $CFG_SHTBX_GROUP ]]; then SHTBX_GROUP=$CFG_SHTBX_GROUP; fi
}

# curl binary check
curlcheck() {
  SHTBX_CURL=`which curl`
  if [[ -z `which curl` ]]; then
    echo "No curl found. Please install it before usage of shout.sh"
    exit 9; #code 9 for missing curl
  fi
  #echo "It seems to be that we can use curl."
}

################################################################################
###
### shout - Yeeha!
###
################################################################################
shout() {

# full template
JDATA=`cat <<JSON
{
  "status":"$SHTBX_STATUS",
  "name":"$SHTBX_NAME",
  "message":"$SHTBX_MSG",
  "group":"$SHTBX_GROUP",
  "expires_in":$SHTBX_EXP
} 
JSON`


case $SHTBX_FIELDS in
  2)
JDATA=`cat <<JSON
{
  "status":"$SHTBX_STATUS",
  "name":"$SHTBX_NAME"
} 
JSON`
    ;;
  3)
JDATA=`cat <<JSON
{
  "status":"$SHTBX_STATUS",
  "name":"$SHTBX_NAME",
  "message":"$SHTBX_MSG"
} 
JSON`
    ;;
  4)
  # status,name,message,group
JDATA=`cat <<JSON
{
  "status":"$SHTBX_STATUS",
  "name":"$SHTBX_NAME",
  "message":"$SHTBX_MSG",
  "group":"$SHTBX_GROUP"
} 
JSON`
    ;;
esac

echo "debug---"
echo "$JDATA"
echo "---debug"

#DATA_TEST='{"name":"shout.sh","status":"green","group":"shout.sh"}'

#JSON_CONTENT=""
#if [[ -z $input ]]; then JSONCONTENT=$JSON_CONTENT+$input; fi
#JSONDATA="{"+$JSON_CONTENT+"}"

  RESP=`curl -X PUT $SHTBX_HOST:$SHTBX_PORT$SHTBX_PATH \
    -A "$SHTBX_USER_AGENT" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-Shoutbox-Auth-Token: $SHTBX_AUTH_TOKEN" \
    -d "$JDATA" \
    2>/dev/null`

  if [[ $RESP == "OK" ]]; then
    echo "You shouted fine."
  else
    echo "Error! (Message: $RESP)"
    exit 8 #code 8 for broken curling
  fi
}

answers() {
  curlcheck
  curl http://23569.net/42 2>/dev/null
}

################################################################################
###
### usage - basic help
###
################################################################################
usage() {
cat <<USAGEBANNER
# shoutbox.io Bash Script
# 2011 by Christoph Grabo <chris@dinarrr.com>
# License: MIT/X11

Usage:
  shout.sh <status> <name> [<message>] [<group>] {options}
  
  status:
    <green|yellow|red|remove>

    'green' can go without a message
    'yellow' and 'red' really NEED a message!
    'remove' deletes a <what> term from your shoutbox
    
  name:
    short descriptive term
    for example your service names, websites, servers, ...
    put "quotation marks" around the term if spaces are used
        
  message:
    *optional
    information about what went wrong
    put "quotation marks" around the message if spaces are used
    HINT: you can use HTML tags like <a href="{URL}">service-link</a>
    
  group:
    *optional
    you can group your shouts
    put "quotation marks" around the group if spaces are used
    
  options:
    *not yet implemented

This help can be viewed with:
$0 (no parameters)
or with: -h, --help, --usage, ?

More infos can be found under https://github.com/asaaki/shoutbox.io-client-lib

shoutbox.io is a website for live status monitoring. (See: http://shoutbox.io/)
USAGEBANNER

curlcheck

}

################################################################################
###
### main
###
################################################################################

# no params?
if [[ -z $1 ]];           then usage; exit 1; fi #code 1 for shout.sh w/o params

# one param for help
if [[ $1 == "-h" ]];      then usage; exit 2; fi #code 2 for help
if [[ $1 == "--help" ]];  then usage; exit 2; fi
if [[ $1 == "--usage" ]]; then usage; exit 2; fi
if [[ $1 == "?" ]];       then usage; exit 2; fi
if [[ $1 == "42" ]];      then answers; exit 42; fi

# check for curl bin
curlcheck

# load config
config

# hard param structure:
# shout.sh status name message group options
if [[ $# -gt 1 ]]; then
  
  # $1 = STATUS
  if [[ "$1" = "green" ]] || [[ "$1" = "yellow" ]] || [[ "$1" = "red" ]] || [[ "$1" = "remove" ]]; then
    #echo "Status: $1"
    SHTBX_STATUS=$1
  else
    echo "Status: $1"
    echo "Error - You can select from [green,yellow,red,remove] only."
    echo "Use '$0 -h' for details."
    exit 4 #code 4 for wrong selection
  fi
  # $2 = NAME
  # no IF because we really need a minimum of 2 params!
  #echo "Name: $2"
  SHTBX_NAME=$2
  SHTBX_FIELDS=2
  
  # $3 = MESSAGE
  if [[ -n $3 ]]; then
    #echo "Message: $3"
    SHTBX_MSG=$3
    SHTBX_FIELDS=3
  fi
  
  # $4 = GROUP
  if [[ -n $4 ]]; then
    #echo "Group: $4"
    SHTBX_GROUP=$4
    SHTBX_FIELDS=4
  fi
  
  if [[ $# -gt 4 ]]; then
    echo "You have given more than 4 params, but {options} not yet implemented."
    echo "shout.sh will ignore the additional params!"
  fi
  
else
  usage
  exit 3 #you used only one param but not the help option!
fi

# do the shout!
shout

# fin!
exit 0
