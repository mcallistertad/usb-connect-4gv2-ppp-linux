#!/bin/sh

VF='Vodafone'
AL='Alcatel'

now=$(date)
echo "Starting modem setup $now"

echo "Updating package list"
apt-get update

echo "Installing usb-modeswitch"
apt-get install ppp usb-modeswitch

echo "Checking USB modem is connected"
usb_id=$(ls -l /dev/serial/by-id)
if [[ "$usb_id" == *"$VF"* || *"$ALC"* ]];
then
    echo "Found a modem"
else
    echo "Modem not found"
    exit 1
fi

echo "Moving files to correct directories"
# Move chatscript to ppp directory
mv ../chatscripts/vodafone_chat ~/etc/ppp/
# Move dialup parameters to peers directory
mv ../peers/vodafone ~/etc/ppp/peers/vodafone/
# Move ppp job to systemd directory
mv ../services/ppp-connect.service /etc/systemd/system/
# Move ppp job timer to systemd directory
mv ../services/ppp-connect.timer /etc/systemd/system/

echo "Saving log..."
timeout 5s tail -f /var/log/messages | tee ../install_logs/log.txt

echo "Checking DNS"
for i in {1..5}
do
    grep -q DNS log.txt && echo "String \"DNS\" found";
    break
done

# "Appending DNS info to log..."
cat /etc/resolv.conf | tee -a ../install_logs/log.txt

echo  "Finished modem setup"
exit 0
