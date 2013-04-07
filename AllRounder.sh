#!/bin/bash

#EXIT CODES INITIALIZATION

E_OK=0;
E_PROBLEM=1;

# DATE VARIABLES
TDATE=`date +%d%m%Y`
FDATE=`date`

function_date() {
echo "Date : ${FDATE}";
}

cmdfailed() {

if [ $? -ne 0 ]
then
	echo "Command execution failed either due to permission denied or command not available"
fi
}

helpinfo() {
cat<<EOF
Usage : $0 [option]

Current available options :
	-s | --serverinfo 	: All Basic and advanced server details 
        -u | --userinfo 	: Users and their information
        -d | --diskinfo 	: Mount and physical disk details
	-p | --processinfo	: Processes list details
	-c | --cpuinfo		: List of all CPU details
	-m | --memoryinfo	: List of all Memory details
	-n | --networkinfo	: Network, firewall details
        -a | --allinone 	: Displays all the above information
	-h | --help 		: Display help information 		

for example,
Linux # $0 --serverinfo
----------------------------
***  Server Details  ***
Server name : bt
Details : Linux bt 3.2.6 #1 SMP Fri Feb 17 10:40:05 EST 2012 i686 GNU/Linux
-----------------------------
or you can also use short key detector. Instead of using --serverinfo, you can also use -s.



AllRounder - This script can handle all basic required commands and displays all the required information regarding one of the particular topic above in Linux.
Author : Sankar Bheemarasetty ( sankar@learnsomuch.com )
License : Please read LICENSE file.
EOF
exit ${E_OK}

}

[ ${1} ] || helpinfo

serverinfo() {

sname=`hostname`
cmdfailed
echo "***  Server Details  ***";
echo "Server name : ${sname}";
echo "Details : `uname -a`";
}

userinfo() {

user=`whoami`
echo "***  User Details  ***";
echo "Running as $user";
echo "$user details : `id`";
echo "Number of users logged in : `who | wc -l`";
echo "";
echo "Users currently logged in :";users
cmdfailed
echo "";
echo "Last logged in users :"; lastlog
cmdfailed
echo "";
echo "Current user activity :";w
cmdfailed
echo "";
users_list=`getent passwd | cut -d ":" -f 1`
cmdfailed
echo "List of all the existing unique users : ${users_list}";
}

diskinfo() {

echo "***  Hard disk details  ***";
df -h | grep -v ^none | while read -r a;
do
	echo -e "\t ${a}";
done
echo "";

echo "***  Mount point details  ***";
mount | while read -r a
do
	echo -e "\t ${a}";
done
}

processinfo() {

echo "***  Processes details  ***";
echo "List of all the processes running";ps -ef
cmdfailed
echo "";
top -n1 -b | grep "Task"
cmdfailed
}

cpuinfo() {

echo "***  CPU details  ***"
echo "";
cat /proc/cpuinfo
cmdfailed
echo "";
top -n1 -b | grep "Cpu"
cmdfailed
}

memoryinfo() {

echo "***  Memory details  ***";
echo "";
top -n1 -b | grep "Mem"
cmdfailed
echo "";
sudo dmidecode --type 17 | head -5
cmdfailed
echo "";
cat /proc/meminfo
cmdfailed
echo "";
echo "Total RAM in MB : Free of ";echo $(($(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')/1024))
cmdfailed
echo ""
echo "Top 10 used memory - processes : "
ps -A --sort -rss -o comm,pmem | head -n 11
cmdfailed
echo "";
echo "Memory information in MB";
free -m
cmdfailed
echo "";
dmesg | grep memory; dmesg | grep Memory;
cmdfailed
echo "";
}

networkinfo() {

echo "***  Network details  ***";
echo "";
/sbin/ifconfig
cmdfailed
echo "";
/sbin/ip addr
cmdfailed
echo "";
echo "***  Routing details  ***";
echo "";
/sbin/route
cmdfailed
echo "";
/sbin/route -n
cmdfailed
echo "";
/sbin/ip route
cmdfailed
echo "";
rcount=$(echo `/sbin/route | wc -l` -1 | bc)
cmdfailed
/sbin/route | tail -n ${rcount} | while read -r a
do
	echo -e "\t ${a}";
done
cmdfailed
echo "";
/sbin/iptables -L
cmdfailed
echo "";
ip -6 addr
cmdfailed
echo "";
ip -6 route
cmdfailed
echo "";
echo "***  Ethtool info (Speed/duplex)  ***";
echo "";
einfo=`awk -F: '$1 ~ "eth" { print $1 } ' /proc/net/dev`
cmdfailed
for eth in ${einfo}
do
	ethtool ${einfo}
done
cmdfailed
echo "";
linfo=`awk -F: '$1 ~ "lo" { print $1 } ' /proc/net/dev`
cmdfailed
for lo in ${linfo}
do
	ethtool ${linfo}
done
cmdfailed
echo "";
echo "***  Active ports LISTENING / TIME_WAIT  ***";
echo "";
netstat -anp 
cmdfailed
echo "";
echo "***  Hosts file under /etc ***";
cat /etc/hosts
cmdfailed
echo "";
echo "***  List of all interface addresses (unicast/broadcast/anycast) ***";
echo "";
routel | grep "local"
cmdfailed
echo "";
echo "***  List of all (except ipv6 link-local) addresses of interfaces";
echo "";
routel | grep "local" | grep "host"
cmdfailed
echo "";
echo "***  List of all broadcast addresses of interfaces  ***";
echo "";
routel | grep "local" | grep "link"
cmdfailed
echo "";
echo "***  List of all routing entries  ***";
echo "";
routel | grep -v "local" | grep -v "unspec"
cmdfailed
echo "";
echo "***  List of all on-link routing entries  ***";
echo "";
routel | grep -v "local" | grep -v "unspec" | grep "link"
cmdfailed
echo "";
echo "***  List of all on-link routing entries that are added by kernel, (which also matches the netmask of the IP address)  ***";
echo "";
routel | grep -v "local" | grep -v "unspec" | grep "link" | grep "kernel"
cmdfailed
echo "";
echo "***  List of all non-on-link routes (aka gatewayed or routed)  ***";
echo "";
routel | grep -v "local" | grep -v "unspec" | grep -v "link"
cmdfailed
echo "";
echo "***  Vmstat information  ***";
echo "";
vmstat
cmdfailed
echo "";
/sbin/ip link
cmdfailed
echo "";
/sbin/ip tunnel
cmdfailed
echo "";
/sbin/ip rule
cmdfailed
echo "";
iptables-save
cmdfailed
echo "";
echo "***  sysctl  knobs, to know if someone enabled forwarding, ARP proxying  ***";
sysctl -a
cmdfailed

}

Allinone() {
function_date
echo "";
serverinfo
echo "";
userinfo
echo "";
diskinfo
echo "";
processinfo
echo "";
cpuinfo
echo "";
memoryinfo
echo "";
networkinfo
echo "";
}

options=$@

arguments=($options)

index=0;
for argument in $options
do
	index=`expr $index + 1`;
	case $argument in
	-s | --serverinfo ) serverinfo ;;
	-u | --userinfo ) userinfo ;;
	-d | --diskinfo ) diskinfo ;;
	-p | --processinfo ) processinfo ;;
	-c | --cpuinfo ) cpuinfo ;;
	-m | --memoryinfo ) memoryinfo ;;
	-n | --networkinfo ) networkinfo ;;
	-a | --allinone ) Allinone ;;
	-h | --help ) helpinfo ;;
	esac
done
exit;
