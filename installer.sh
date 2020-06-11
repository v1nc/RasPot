#!/bin/bash
whiptail --infobox "RasPot is based on HoneyPi by mattymcfatty!\n" 20 60
#check root
if [ $UID -ne 0 ]
then
 echo "Please run this script as root: sudo ./installer.sh"
 exit 1
fi

####Change password if you haven't yet###
if [ $SUDO_USER == 'pi' ]
then
 if whiptail --yesno "You're currently logged in as default pi user. If you haven't changed the default password 'raspberry' would you like to do it now?" 20 60
 then
  passwd
 fi
fi

####Install Debian updates ###
if whiptail --yesno "Do you want to update your RasPot?" 20 60
then
 apt-get update
 apt-get dist-upgrade
fi

####Select spoofed device###
DEVICE=$(whiptail --menu "Choose a device to spoof" 20 60 5 "IP-Cam" "A vulnerable IP-Cam" 3>&2 2>&1 1>&3)
case $DEVICE in
	IP-Cam)
		HOSTNAME=$(sort -R device_data/ip_cams/hostnames | head -n 1  | cut -c 1-23)
		VENDOR=$(echo "$HOSTNAME" | cut -d "-" -f1)
		PREFIX=$(cat device_data/ip_cams/macs | grep -i $VENDOR | cut -d "	" -f1)
		MAC=$PREFIX$(printf ': %02X: %02X: %02X' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])

		echo " smsc95xx.macaddr = $MAC">>/boot/cmdline.txt
		echo $MAC > /root/MAC
		echo $HOSTNAME > /etc/hostname
		echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

	;;
esac



####Install PSAD ###
whiptail --infobox "Installing a bunch of software like the log monitoring service and other dependencies...\n" 20 60
apt-get -y install psad msmtp msmtp-mta python-twisted iptables-persistent libnotify-bin fwsnort raspberrypi-kernel-headers

###Choose Notification Option###
OPTION=$(whiptail --menu "Choose how you want to get notified:" 20 60 5 "email" "Send me an email" "script" "Execute a script" "blink" "Blink a light on your Raspberry Pi" "telegram" "Get a message on Telegram" 3>&2 2>&1 1>&3)
emailaddy=test@example.com
enablescript=N
externalscript=/bin/true
alertingmethod=ALL
check=1

case $OPTION in
	email)
		emailaddy=$(whiptail --inputbox "Mmmkay. Email is a pain to set up. We have defaults for gmail so use that if you have it. What's your email address?" 20 60 3>&1 1>&2 2>&3)
        	msmtp --configure $emailaddy > msmtprc
        	echo "account default : $emailaddy" >> msmtprc
        	sed -i 's/passwordeval.*/password XXX/g' msmtprc
        	sed -i 's/# -.*/### Just replace XXX with your app password/g' msmtprc
        	sed -i 's/#  .*/### and press Ctrl-X to quit and save/g' msmtprc
        	cp msmtprc /etc/
		check=30
		whiptail --msgbox "Now, create an 'App Password' for your gmail account (google it if you don't know how). Because we don't want to assign your password to any variables, you have to manually edit the smtp configuration file on the next screen. Save and exit the editor and I'll see you back here." 20 60
		pico /etc/msmtprc
		whiptail --msgbox "Welcome back! Well Done! Here comes a test message to your email address..." 20 60
		echo "test message from RasPot" | msmtp -vvv $emailaddy
		if whiptail --yesno "Cool. Now wait a couple minutes and see if that test message shows up. 'Yes' to continue or 'No' to exit and mess with your smtp config." 20 60
 		then
  			echo "Continue"
		else
			exit 1
 		fi

	;;
	script)
		externalscript=$(whiptail --inputbox "Enter the full path and name of the script you would like to execute when an alert is triggered:" 20 60 3>&1 1>&2 2>&3)
		enablescript=Y
		alertingmethod=noemail
	;;
	telegram)
		externalscript="/root/RasPot/telegram.sh -ip SRCIP"
		enablescript=Y
		alertingmethod=noemail
	;;
	blink)
		enablescript=Y
		alertingmethod=noemail
		externalscript="/usr/bin/python /root/RasPot/blinkonce.py"
	;;
esac

###update vars in configuration files
sed -i "s/xhostnamex/$HOSTNAME/g" psad.conf
sed -i "s/xemailx/$emailaddy/g" psad.conf
sed -i "s/xenablescriptx/$enablescript/g" psad.conf
sed -i "s/xalertingmethodx/$alertingmethod/g" psad.conf
sed -i "s=xexternalscriptx=$externalscript=g" psad.conf
sed -i "s/xcheckx/$check/g" psad.conf


###Wrap up everything and exit
whiptail --msgbox "Configuration files created. Next we will move those files to the right places." 20 60
mkdir /root/RasPot
cd /root/ && git clone https://github.com/v1nc/RasPot
chmod +x /root/RasPot/*.sh
#cp blink*.* /root/RasPot
cp telegram.conf /root/RasPot
#cp telegram.sh /root/RasPot
#cp psad.conf /etc/psad/psad.conf
iptables --flush
iptables -A INPUT -p igmp -j DROP
#too many IGMP notifications. See if that prevents it
iptables -A INPUT -j LOG
iptables -A FORWARD -j LOG
service netfilter-persistent save
service netfilter-persistent restart
psad --sig-update
service psad restart
#cp raspot.py /root/RasPot
(crontab -l 2>/dev/null; echo "@reboot python /root/RasPot/raspot.py &") | crontab -
ifconfig
printf "\n \n"
if whiptail --yesno "RasPot installation finished. You should reboot. Do it now?" 20 60
 then
  reboot now
 fi
