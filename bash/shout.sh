#!/bin/bash

################################################################################
###
### pre-defined values and param setup
###
################################################################################
SHTBX_PARAM=( $@ )
SHTBX_PARAMS=$#
SHTBX_CONFIG=$HOME/.shoutbox

SHTBX_HOST=http://shoutbox.io
SHTBX_PORT=80
SHTBX_PATH=/status
SHTBX_PROXY_HOST=
SHTBX_PROXY_PORT=
SHTBX_AUTH_TOKEN=
SHTBX_USER_AGENT="bash shoutbox client (+https://github.com/asaaki/shoutbox-client-lib)"
SHTBX_GROUP=Home #default group!
SHTBX_STATUS=
SHTBX_NAME=
SHTBX_MSG=
SHTBX_EXP=
SHTBX_JDATA=

################################################################################
###
### configuration
###
################################################################################
shtbx_config() {
  if [[ ! -f $SHTBX_CONFIG ]]; then
    shtbx_error "Found no .shoutbox config file in $HOME!" #func
  fi
  CFG_SHTBX_AUTH_TOKEN=`awk -F ": " '$1~/^auth_token$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_AUTH_TOKEN ]]; then
    SHTBX_AUTH_TOKEN=$CFG_SHTBX_AUTH_TOKEN
  else
    shtbx_error "No Auth_Token found!" #func
  fi
  CFG_SHTBX_HOST=`awk -F ": " '$1~/^host$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_HOST ]]; then SHTBX_HOST=$CFG_SHTBX_HOST; fi
  CFG_SHTBX_PORT=`awk -F ": " '$1~/^port$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_PORT ]]; then SHTBX_PORT=$CFG_SHTBX_PORT; fi
  CFG_SHTBX_PROXY_HOST=`awk -F ": " '$1~/^proxy_host$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_PROXY_HOST ]]; then SHTBX_PROXY_HOST=$CFG_SHTBX_PROXY_HOST; fi
  CFG_SHTBX_PROXY_PORT=`awk -F ": " '$1~/^proxy_port$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_PROXY_PORT ]]; then SHTBX_PROXY_PORT=$CFG_SHTBX_PROXY_PORT; fi
  CFG_SHTBX_GROUP=`awk -F ": " '$1~/^group$/ {print $2}' $SHTBX_CONFIG`
  if [[ -n $CFG_SHTBX_GROUP ]]; then SHTBX_GROUP=$CFG_SHTBX_GROUP; fi
}

################################################################################
###
### curl binary check
###
################################################################################
shtbx_curlcheck() {
  SHTBX_CURL=`which curl`
  if [[ -z `which curl` ]]; then
    shtbx_error "no curl found - please install"
  fi
}

################################################################################
###
### input
###
################################################################################
shtbx_input() {
  case $SHTBX_PARAMS in
    0)
      # no input => help
      shtbx_error "no input"
      ;;
    1)
      # only help modus available
      case ${SHTBX_PARAM[0]} in
        ?|--help|--usage)
          shtbx_usage #func
          exit 0
          ;;
        42)
          shtbx_answers #func
          exit 42
          ;;
        *)
          # also help because we couldn't recognize input
          shtbx_usage #func
          exit 1
          ;;
      esac
      ;;
    2)
      # status and name;no message, no options
      shtbx_status #func
      shtbx_name #func
      ;;
    3)
      # status, name and message; no options
      shtbx_status #func
      shtbx_name #func
      shtbx_message #func
      ;;
    *)
      # status, name and message + options
      shtbx_status
      shtbx_name
      shtbx_message
      shtbx_more_options
      ;;
  esac
}

################################################################################
###
### status check
###
################################################################################
shtbx_status() {
  sts=${SHTBX_PARAM[0]}
  case $sts in
    green)
      SHTBX_STATUS=$sts
      ;;
    yellow|red)
      if [[ -z ${SHTBX_PARAM[2]} ]]; then
        shtbx_error "no message provided" #func
      fi
      SHTBX_STATUS=$sts
      ;;
    remove)
      # ignore message if provided => empty the value for later call
      SHTBX_PARAM[2]=
      SHTBX_STATUS=$sts
      ;;
    *)
      shtbx_error "wrong status" #func
      ;;
  esac
}

################################################################################
###
### name assignment
###
################################################################################
shtbx_name() {
  SHTBX_NAME=${SHTBX_PARAM[1]} #no further checks needed
}

################################################################################
###
### message assignment
###
################################################################################
shtbx_message() {
  SHTBX_MSG=${SHTBX_PARAM[2]} #no further checks needed
}

################################################################################
###
### group assignment
###
################################################################################
shtbx_group() {
  SHTBX_GROUP=$1 #use given param
}

################################################################################
###
### expires_in assignment
###
################################################################################
shtbx_expires_in() {
  SHTBX_EXP=$1 #use given param
}

################################################################################
###
### more options checker for group/expires_in
###
################################################################################
shtbx_more_options() {
  for (( key=3; key<=$SHTBX_PARAMS; key++ ))
  do
    case ${SHTBX_PARAM[$key]} in
      -g|--group)
        shtbx_group ${SHTBX_PARAM[$key+1]} #func
        continue #skips next
        ;;
      -e|--expires|--expires_in)
        shtbx_expires_in ${SHTBX_PARAM[$key+1]} #func
        continue #skips next
        ;;
    esac
  done
}

################################################################################
###
### json builder
###
################################################################################
shtbx_build_json() {
#pre + status&name&group
SHTBX_JDATA=`cat <<JSON
{"status":"$SHTBX_STATUS","name":"$SHTBX_NAME","group":"$SHTBX_GROUP"
JSON`
#add message if available
if [[ -n $SHTBX_MSG ]]; then
SHTBX_JDATA=$SHTBX_JDATA`cat <<JSON
,"message":"$SHTBX_MSG"
JSON`
fi
#add expires_in time if available
if [[ -n $SHTBX_EXP ]]; then
SHTBX_JDATA=$SHTBX_JDATA`cat <<JSON
,"expires_in":"$SHTBX_EXP"
JSON`
fi
#post
SHTBX_JDATA=$SHTBX_JDATA`cat <<JSON
}
JSON`
}

################################################################################
###
### shout it - Yeeha!
###
################################################################################
shtbx_shout() {
  RESP=`curl -X PUT $SHTBX_HOST:$SHTBX_PORT$SHTBX_PATH \
    -A "$SHTBX_USER_AGENT" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-Shoutbox-Auth-Token: $SHTBX_AUTH_TOKEN" \
    -d "$SHTBX_JDATA" \
    2>/dev/null`

  if [[ $RESP == "OK" ]]; then
    exit 0
  else
    shtbx_error "shoutbox.io Error! [response: $RESP]" #func
  fi
}

shtbx_answers() {
  shtbx_curlcheck #func
  curl http://23569.net/42 2>/dev/null
}

################################################################################
###
### usage - basic help
###
################################################################################
shtbx_usage() {
cat <<USAGEBANNER
# shoutbox.io Bash Script
# 2011 by Christoph Grabo <chris@dinarrr.com>
# License: MIT/X11

Usage:
  shout.sh STATUS NAME [MESSAGE] [OPTION]...

  STATUS
  
    *only: (green|yellow|red|remove)

    'green' can go without a MESSAGE
    'yellow' and 'red' really need a MESSAGE!
    'remove' deletes a NAME term from your shoutbox

  NAME
  
    short descriptive term
    for example your service names, websites, servers, ...
    put "quotation marks" around the term if spaces are used

  MESSAGE
  
    *optional for green status
    
    information about what went wrong
    put "quotation marks" around the message if spaces are used
    HINT: you can use HTML tags like <a href="{URL}">service-link</a>

  OPTIONS

    -g|--group GROUPNAME
    
      *optional
      you can group your shouts
      put "quotation marks" around the group if spaces are used
      
    -e|--expires|--expires_in SECONDS
    
      *optional
      you can group your shouts
      put "quotation marks" around the group if spaces are used


This help can be viewed with:
$0 (no parameters)
or with: -h, --help, --usage, ?

More infos can be found under https://github.com/asaaki/shoutbox.io-client-lib

shoutbox.io is a website for live status monitoring. (See: http://shoutbox.io/)

USAGEBANNER
}

################################################################################
###
### error message and exit
###
################################################################################
shtbx_error() {
  echo "Error! (reason: $1)"
  echo
  shtbx_usage #func
  exit 1
}

################################################################################
###
### main routine
###
################################################################################
main() {
  shtbx_curlcheck #func
  shtbx_config #func
  shtbx_input #func
  shtbx_build_json #func
  shtbx_shout #func
}

#run!
main
exit 0

################################################################################
#EOF
