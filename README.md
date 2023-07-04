# usb-connect-4gv2-ppp-linux

## Requirements
- USB Connect 4Gv2 dongle + active SIM
- Linux OS (tested on Raspberry Pi model 4 with Ubuntu server 22.10 64-bit & Pi OS 64-bit)

## Option 1 - Use the install script
Unzip the archive and run the install script as root 
```
wget https://github.com/mcallistertad/usb-connect-4gv2-ppp-linux/archive/refs/heads/main.zip
unzip main.zip
cd usb-connect-4gv2-ppp-linux
sudo bash install.sh
```

## Option 2 - Install and configure manually
### Step 1. Install packages
Update installed package list and install pppd
```
apt-get update
apt-get install ppp usb-modeswitch
```
### Step 2. Determine USB modem serial ID
In /etc/ppp/peers/vodafone 
replace line beginning /dev/serial/by-id/<usb-id>
```
$ ls -l /dev/serial/by-id
```
### Step 3. Install ppp scripts
```
wget https://github.com/mcallistertad/usb-connect-4gv2-ppp-linux/archive/refs/heads/main.zip
unzip main.zip
cd usb-connect-4gv2-ppp-linux
mv ../chatscripts/vodafone_chat ~/etc/ppp/
mv ../peers/vodafone ~/etc/ppp/peers/vodafone/
```
### Step 4. Connect to the cellular network
```
pon vodafone
```
### Step 5. Check connection
Check PPP interface is up
```
ifconfig -a
```
Ping namserver on PPP interface
```
ping -I ppp0 8.8.8.8
```
Check IP address
```
hostname -I
```
Check Vodafone DNS entries have been populated
```
cat /etc/resolv.conf
```
### Step 6. Disconnect from the cellular network
```
poff vodafone
```
### Step 7. Create the daemons to keep the ppp connection up
```
mv ../services/ppp-connect.service /etc/systemd/system/
mv ../services/ppp-connect.timer /etc/systemd/system/
```
### Step 7. Enable the daemons
```
systemctl enable ppp-connect.service
systemctl enable ppp-connect.timer
```
Check status
```
systemctl status ppp-connect.service
systemctl enable ppp-connect.timer
```