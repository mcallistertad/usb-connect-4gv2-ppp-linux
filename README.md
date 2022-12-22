# usb-connect-4gv2-ppp-linux

## Requirements
- USB Connect 4Gv2 dongle
- Linux machine (tested on a Raspberry Pi model 4 with Pi OS 64-bit installed and Ubuntu server 22.10 64-bit)

## Step 1. Install packages
Update installed package list and install pppd
```
sudo apt-get update
sudo apt-get install ppp usb-modeswitch
```
## Step 2. Determine USB modem serial ID
In /etc/ppp/peers/vodafone 
replace line beginning /dev/serial/by-id/<usb-id>
```
$ ls -l /dev/serial/by-id
```
## Step 3. Install ppp scripts
```
wget https://github.com/mcallistertad/usb-connect-4gv2-ppp-linux/archive/refs/heads/main.zip
unzip main.zip
cd usb-connect-4gv2-ppp-linux
sudo cp chatscripts/vodafone_chat /etc/ppp
sudo cp peers/vodafone /etc/ppp/peers
```
## Step 4. Connect to the cellular network
```
sudo pon vodafone
```
## Step 5. Check connection
Check PPP interface is up
```
ifconfig -a
```
Ping Google namserver on PPP interface
```
ping -I ppp0 8.8.8.8
```
Check IP address
```
hostname -I
```
Check Vodafone namservers have been populated
```
sudo nano /etc/resolv.conf
```
## Step 6. Disconnect from the cellular network
```
sudo poff vodafone
```
