# RasPot
A local honey pot on your Raspberry Pi.

_Fork of [HoneyPi](https://github.com/mattymcfatty/HoneyPi)_


## Installation

Start with a fresh Raspbian Lite, login via SSH:
```
git clone https://github.com/v1nc/RasPot
cd RasPot
chmod +x *.sh
sudo ./installer.sh
```

## Telegram Notifications

You can get a message on Telegram if RasPot detected something.

1. Create Telegram bot with @BotFather
2. Get Bot's Token
3. Get the Chat_ID of your Telegram account
4. `mv telegram.conf.example telegram.conf`
5. Paste Token and Chat_ID into `telegram.conf`
6. Select Telegram during installation.