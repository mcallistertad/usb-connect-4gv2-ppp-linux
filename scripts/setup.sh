#!/bin/sh

VF='Vodafone'
AL='Alcatel'

now=$(date)
echo "Starting modem setup\n $now"

# Update packages and install necessary software
echo "Updating package list"
apt-get update
if [ "$?" != "0" ]; then
	echo "[Error] package list update failed!" 1>&2
	exit 1
fi

echo "Installing usb-modeswitch"
apt-get install ppp usb-modeswitch
if [ "$?" != "0" ]; then
	echo "[Error] usb-modeswitch install failed!" 1>&2
	exit 1
fi

echo "Checking USB modem is connected"
usb_id=$(ls -l /dev/serial/by-id)
if [[ "$usb_id" == *"$VF"* || *"$AL"* ]];
then
    echo "Found a modem\n"
else
    echo "Modem not found\n"
    exit 1
fi

# TODO: Append USB device ID/ path to
# ppp-connect service (~/etc/ppp/peers/vodafone/)
# vodafone ppp parameter file (~/etc/ppp/peers/vodafone/)

# Move downloaded files
echo "Moving files to correct directories"
# Move chatscript to ppp directory
mv ../chatscripts/vodafone_chat ~/etc/ppp/
# Move dialup parameters to peers directory
mv ../peers/vodafone ~/etc/ppp/peers/vodafone/
# Move ppp job to systemd directory
mv ../services/ppp-connect.service /etc/systemd/system/
# Move ppp job timer to systemd directory
mv ../services/ppp-connect.timer /etc/systemd/system/
f [ "$?" != "0" ]; then
	echo "[Error] file move failed!" 1>&2
	exit 1
fi

# Start daemons - timer will enable service on boot
systemctl enable ppp-connect.service
systemctl enable ppp-connect.timer
if [ "$?" != "0" ]; then
	echo "[Error] ppp-connect service did not start!" 1>&2
	exit 1
fi

# Check timer is running
timer_stat=$(systemctl status ppp-connect.timer)
if [[ "$timer_stat" == *"$running"* ]];
then
    echo "timer running\n"
else
    echo "timer not running\n"
fi


echo "Saving log..."
timeout 5s tail -f /var/log/messages | tee ../install_logs/log.txt
timeout 5s tail -f /var/log/messages | tee log.txt

echo "Checking DNS"
for i in {1..5}
do
    grep -q DNS log.txt && echo "String \"DNS\" found";
    break
done

# "Appending DNS info to log..."
cat /etc/resolv.conf | tee -a ../install_logs/log.txt
if [ "$?" != "0" ]; then
	echo "[Error] log update failed!" 1>&2
	exit 1
fi

echo "Check DNS"
nameserver=$(grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" /etc/resolv.conf | head -1)
echo "DNS address: ${nameserver}"
ping_res=$(ping -c3 -I ppp0 ${nameserver})
if [[ "$ping_res" =~ .*"ttl"*. ]];
then
    echo "Ping ${nameserver} successful\n"
else
    echo "Ping test fail!"
fi

echo  "Finished modem setup"
exit 0