#!/bin/bash
# Filename: keepalive
# Location: LINUX  one:/mnt/scripts/keepalive/bin
# Author: bgstack15@gmail.com
# Startdate: 2015-11-10 09:15:57
# Title: Keepalive Script
# Purpose: 
# History: 2015-11-10
#    2015-11-12 uses local directory for default infile
#    2016-06-02 Updated for bgscripts 1.1-6, so keepalive 1.0-3
#    2016-07-22 This keepalive.sh is the keepalive-1.0-4 version before the project switched to python. This is included for historical reference only.
# Usage: 
# Reference: ftemplate.sh 2015-11-06a; framework.sh 2015-07-10a
#    Proxy Keepalive for Linux Bash (Alice User1 2014-07-31)
# Improve:
fiversion="2015-11-30a"
keepaliveversion="2016-06-02a"

usage() {
   less -F >&2 <<ENDUSAGE
usage: keepalive [-duV] [-k <keytab>] [-r <refreshvalue>] [-i <infile1>]
version ${keepaliveversion}
 -d debug     Show debugging info, including parsed variables.
 -u usage     Show this usage block.
 -V version   Show script version number.
 -k keytab    Overrides default keytab value. Default is ${keytab}
 -i infile    Overrides default infile value. Default is ${infile1}
 -r refresh   Overrides default wait time between checks. Default is ${refresh}
usage: keepalive out
     Will log out of the proxy and exit
Return values:
0 Normal
1 Help or version info displayed
2 Could not start: could be already running, bad lockfile, bad keytab
3 Incorrect OS type
4 Unable to find dependency
5 Not run as root or sudo
ENDUSAGE
}

# DEFINE FUNCTIONS
function klog {
   # abstracted out so I can either do a file or do syslog in the future easily
   ferror "$@" 
   #echo "" | flecho "$@" 1>&2
   #date "+[%Y-%m-%d %T] keepalive: $@" >&2
   #logger "keepalive: $@"
}

function proxylogout {
   # Logout the previously authenticated user
   /usr/bin/curl -s -o /dev/null http://proxylogout.example.com >/dev/null 2>&1
}

# DEFINE TRAPS

function clean_keepalive {
   klog "stopping"
   rm -f ${lockfile} >/dev/null 2>&1
   [ ] #use at end of entire script if you need to clean up tmpfiles
}

function CTRLC {
   #trap "CTRLC" 2
   [ ] #useful for controlling the ctrl+c keystroke
}

function CTRLZ {
   #trap "CTRLZ" 18
   [ ] #useful for controlling the ctrl+z keystroke
}

function parseFlag {
   flag=$1
   hasval=0
   case $flag in
      # INSERT FLAGS HERE
      "d" | "debug" | "DEBUG") debug=1;;
      "u" | "usage" | "help") usage; exit 1;;
      "V" | "fcheck" | "version") ferror "${scriptfile} version ${keepaliveversion}"; exit 1;;
      "k" | "keytab" | "kfile" | "ktfile") getval; keytab=${tempval};;
      "r" | "refresh" | "refreshtime") getval; refresh=${tempval};;
      "i" | "infile" | "inputfile") getval; infile1=${tempval};;
   esac
   
   [[ debug -eq 1 ]] && { [[ hasval -eq 1 ]] && ferror "flag: $flag = $tempval" || ferror "flag: $flag"; }
}

# DETERMINE LOCATION OF FRAMEWORK
while read flocation; do if [[ -x $flocation ]] && [[ $( $flocation --fcheck ) -ge 20160525 ]]; then frameworkscript=$flocation; break; fi; done <<EOFLOCATIONS
${scriptdir}/framework.sh
/usr/bgscripts/framework.sh
/etc/keepalive/bin/framework.sh
EOFLOCATIONS
[[ -z "$frameworkscript" ]] && echo "$0: framework not found. Aborted." 1>&2 && exit 4

# REACT TO OPERATING SYSTEM TYPE
case $( uname -s ) in
   AIX) echo "$scriptfile: 3. Linux-only script." 1>&2 && exit 3;;
   Linux) [ ];;
   *) echo "$scriptfile: 3. Indeterminate OS: $( uname -s )" 1>&2 && exit 3;;
esac

# INITIALIZE VARIABLES
# variables set in framework:
# today server thistty scriptdir scriptfile scripttrim
# is_cronjob stdin_piped stdout_piped stderr_piped sendsh sendopts
. ${frameworkscript} || echo "$0: framework did not run properly. Continuing..." 1>&2
infile1=/etc/keepalive/keepalive.conf # can be adjusted on the cli
outfile1=
logfile=${scriptdir}/${scripttrim}.${today}.out
interestedparties="bgstack15@example.com"
servercaps=$( echo "${server}" | tr 'a-z' 'A-Z' )

# DEFAULT VARIABLES THAT CAN BE ADJUSTED BY keepalive.conf
lockfile="/tmp/.keepalive.lock"
keytab=/etc/krb5.keytab
refresh=4
proxy1=https://proxy1.example.com:4433/?cfru=aHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS8=
proxy2=https://proxy2.example.com:4433/?cfru=aHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS8=

# REACT TO ROOT STATUS
case $is_root in
   1) # proper root
      [ ] ;;
   sudo) # sudo to root
      [ ] ;;
   "") # not root at all
      ferror "${scriptfile}: 5. Please run as root or sudo. Aborted."
      exit 5
      ;;
esac

# SET CUSTOM SCRIPT AND VALUES
#setval 1 sendsh sendopts<<EOFSENDSH      # if $1="1" then setvalout="critical-fail" on failure
#/test/sysadmin/bin/bgstack15/send.sh -hs   #                setvalout maybe be "fail" otherwise
#/test/sysadmin/bin/send.sh -hs
#/usr/bin/mail -s
#EOFSENDSH
#[[ "$setvalout" = "critical-fail" ]] && ferror "${scriptfile}: 4. mailer not found. Aborted." && exit 4

# VALIDATE PARAMETERS
# objects before the dash are options, which get filled with the optvals
# to debug flags, use option DEBUG
validateparams - "$@"

# CONFIRM TOTAL NUMBER OF FLAGLESSVALS IS CORRECT
#if [[ $thiscount -lt 2 ]];
#then
#   ferror "${scriptfile}: 1111. Fewer than 2 flaglessvals. Aborted."
#   exit 1111
#fi

# IF LOGOUT ONLY
case "${opt1}" in
   "out" | "logout") proxylogout; exit 0;; # probably will add the terminate-any-sessions command here
   *) [ ];;
esac

# READ CONFIG FILE
if [[ ! -f ${infile1} ]];
then
   klog "4. Cannot find conf ${infile1}. Using defaults."
   ferror "${scriptfile}: 4. Cannot find conf ${infile1}. Using defaults."
else
   while read -r line
   do
      if [[ "$line" == [* ]];
      then
         zone=$( echo "${line}" | tr -d '[]' )
         [[ "$debug" = "1" ]] && echo "zone ${zone}"
      else
         # probably a variable
         varname=$( echo "${line}" | awk '{print $1}' )
         varval=$( echo "${line}" | awk '{$1=""; printf "%s", $0}' | sed 's/^ //;' )
         [[ "$debug" = "1" ]] && echo "${varname}=\"${varval}\""
         case "${zone}" in
            "keepalive")
               case "${varname}" in
                  lockfile|keytab|refresh|proxy1|proxy2)
                     eval "${varname}"=\"${varval}\"
                     ;;
                  *) [ ];; # extra variable not defined yet
               esac
               ;;
         esac
      fi
   done < <( grep -viE "^$|^#" "${infile1}" | sed 's/[^\]#.*$//g;' )
fi

## CONFIGURE VARIABLES AFTER PARAMETERS
# EXIT IF LOCKFILE EXISTS
if [[ -e "${lockfile}" ]];
then
   klog "2. Already running. Will not run again."
   ferror "${scripttrim}: 2. Already running. Will not run again."
   exit 2
fi

# SET TRAPS # rearranged from template
#trap "CTRLC" 2
#trap "CTRLZ" 18
trap "clean_keepalive 0" 0

# CREATE LOCKFILE
if ! touch "${lockfile}";
then
   klog "2. Could not create lockfile ${lockfile}. Aborted."
   ferror "${scripttrim}: 2. Could not create lockfile ${lockfile}. Aborted."
   exit 2
fi

# EXIT IF KEYTABFILE IS INVALID
if [[ ! -f "${keytab}" ]];
then
   klog "2. Could not find keytab ${keytab}. Aborted."
   ferror "${scriptfile}: 2. Could not find keytab ${keytab}. Aborted."
   exit 2
fi

## REACT TO BEING A CRONJOB
#if [[ $is_cronjob -eq 1 ]];
#then
#   [ ]
#else
#   [ ]
#fi

# MAIN LOOP
while true;
do
   # Log out of any previous user
   proxylogout

   # Ensure kerberos ticket exists
   if ( klist 2>/dev/null | grep -qiE "principal.*${servercaps}" );
   then
      # valid
      klog "valid ticket found"
   else
      # invalid
      # make a new kerberos ticket
      kdestroy
      klog "requesting new ticket"
      kinit -kt "${keytab}" "${servercaps}\$"
   fi
   
   # So with a valid kerberos ticket, perform actions against both proxies
   # I was unable to get the WHICHPROXY functionality working
   /usr/bin/curl -s -o /dev/null --negotiate -u:ignoreMe -b ~/ProxyCookies.txt -c ~/ProxyCookies.txt $proxy1 2>&1
   /usr/bin/curl -s -o /dev/null --negotiate -u:ignoreMe -b ~/ProxyCookies.txt -c ~/ProxyCookies.txt $proxy2 2>&1
   
   sleep $refresh
done

# EMAIL LOGFILE
#$sendsh $sendopts "$server $scriptfile out" $logfile $interestedparties

# FINAL CLEANUP
trap '' 0       # reset trap to undefined
clean_keepalive end # so I can call it manually
