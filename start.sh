#!/bin/bash
# version 1.8.0

REQNUM=1
ST=13
LOGFILE="/var/log/start_sh.log"
ECHOCMD="$( which echo )"
CURLCMD="$( which curl )"
GREPCMD="$( which grep )"
SEDCMD="$( which sed )"
SLEEPCMD="$( which sleep )"
TAILCMD="$( which tail )"
NETSTAT="$( which netstat )"
DATE="$( which date )"
AMBSERVER="hdpkub"
APIURL="http://$AMBSERVER:8080/api/v1"
USPW="admin:admin"
HTAG="X-Requested-By:MyCompany"

[[ "TRACE" ]] && set -x

debug() {
  [[ "DEBUG" ]]  && $ECHOCMD "[DEBUG] [$($DATE +"%T")] $@" 1>&2
}

start_ambari() {
  while [ -z "$($NETSTAT -tulpn | $GREPCMD -w 8080)" ]; do
    ambari-server start
    $SLEEPCMD 30
  done
}

fix_resolv_conf() {
  $ECHOCMD 'nameserver 8.8.8.8' > /etc/resolv.conf
}

wait4hosts()
{
    local HOSTNUM=$( $CURLCMD -sS -u $USPW -X GET -i $APIURL/hosts | $GREPCMD -c 'host_name' )
    $ECHOCMD "[$(date +"%D %T")] - Creating log file" > $LOGFILE
    while [[ $HOSTNUM -lt $REQNUM ]]
        do
#             debug "Required hosts number is $REQNUM and we have $HOSTNUM"
            $ECHOCMD "[$(date +"%D %T")] - Required hosts number is $REQNUM and we have $HOSTNUM" >> $LOGFILE
#             debug "Waiting until hosts number will reach $HOSTNUM, sleeping for $ST seconds"
            $ECHOCMD "[$(date +"%D %T")] - Waiting until hosts number will reach $HOSTNUM, sleeping for $ST seconds" >> $LOGFILE
            $SLEEPCMD $ST
        done
    $ECHOCMD "$HOSTNUM host(s) are ready for deployment"
}

apply_blueprint() {
  local HOSTNUM=$( $CURLCMD -sS -u $USPW -X GET -i $APIURL/hosts | $GREPCMD -c 'host_name' )
  if [ "$HOSTNUM" == "$REQNUM" ]; then
    cd /
    $CURLCMD -u $USPW -X POST -H "$HTAG" $APIURL/blueprints/DockerClusterBP?validate_topology=false -d @bp.json
  fi
}

map_hosts() {
  cd /
  $CURLCMD -u $USPW -X POST -H "$HTAG" $APIURL/clusters/AutoCluster1 -d @map.json
}

main() {
  fix_resolv_conf
  service sshd start
  start_ambari
#   ambari-server start
  ambari-agent start
  $SLEEPCMD 45
#   wait4hosts
  apply_blueprint
  $SLEEPCMD 10
  map_hosts

   while true; do
     $SLEEPCMD 3
     $TAILCMD -f /var/log/ambari-server/ambari-server.log
   done
}

main "$@"
