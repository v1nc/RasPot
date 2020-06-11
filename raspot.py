#!/usr/bin/python
# -*- coding: utf-8 -*-
import binascii
import time
import os

from twisted.internet.protocol import Protocol, Factory
from twisted.internet import reactor

#all interfaces
interface = '0.0.0.0'

#looked at some PCAPS and got this data. Dissect a few pcaps to add more. SSH would be nice eventually
VNC_RFB = binascii.unhexlify("524642203030332e3030380a")
FTP_response = binascii.unhexlify("3232302050726f4654504420312e332e306120536572766572202850726f4654504420416e6f6e796d6f75732053657276657229205b3139322e3136382e312e3233315d0d0a")
TELNET_response = binascii.unhexlify("fffd25")

def formattedprint(toprint):
	curr = time.strftime("%Y-%m-%d %H:%M:%S: ")
	print(curr + toprint)

def notify(text):
	os.system("bash /root/RasPot/telegram.sh -text {}".format(text))

def notify_connection(host,port):
	notify("<b>⚠️⚠️⚠️RasPot Alert⚠️⚠️⚠️</b>%0A%0A<code>{}</code> tried to connect on port <code>{}</code>".format(host,port))

class FakeTELNETClass(Protocol):
	def connectionMade(self):
		global TELNET_response
		host = self.transport.getPeer().host
		port = self.transport.getPeer().port
		notify_connection(host,port)
		formattedprint("Inbound TELNET connection from: %s (%d/TCP)" % (host, port))
		self.transport.write(TELNET_response)
		formattedprint("Sending TELNET response...")

class FakeFTPClass(Protocol):
	def connectionMade(self):
		global FTP_response
		host = self.transport.getPeer().host
		port = self.transport.getPeer().port
		notify_connection(host,port)
		formattedprint("Inbound FTP connection from: %s (%d/TCP)" % (host, port))
		self.transport.write(FTP_response)
		formattedprint("Sending FTP response...")

class FakeVNCClass(Protocol):
	def connectionMade(self):
		global VNC_RFB
		host = self.transport.getPeer().host
		port = self.transport.getPeer().port
		notify_connection(host,port)
		formattedprint("Inbound VNC connection from: %s (%d/TCP)" % (host, port))
		self.transport.write(VNC_RFB)
		formattedprint("Sending VNC response...")


FakeVNC = Factory()
FakeVNC.protocol = FakeVNCClass
FakeFTP = Factory()
FakeFTP.protocol = FakeFTPClass
FakeTELNET = Factory()
FakeTELNET.protocol = FakeTELNETClass

formattedprint("Starting up RasPot.")
reactor.listenTCP(5900, FakeVNC, interface = interface)
reactor.listenTCP(21, FakeFTP, interface = interface)
reactor.listenTCP(23, FakeTELNET, interface = interface)
reactor.run()
formattedprint("Shutting down RasPot.")

