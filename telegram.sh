#!/bin/bash
#use %0A for new line
source telegram.conf
TEXT="Undefined RasPot alert!"
case $1 in
	-ip)
		TEXT="<b>⚠️⚠️⚠️RasPot Alert⚠️⚠️⚠️</b>%0A%0ADetected <b>portscan</b> from IP: <code>${2}</code>"
	;;
	-text)
		TEXT="${2}"
	;;
esac
		

URL="https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHAT_ID}&parse_mode=HTML&text=${TEXT}"
curl --silent --output /dev/null "$URL"