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

## Spoof Device

You can spoof a vulnerable device to make RasPot more juicy.
Hostname and MAC address are generated out of a known pool.

### IP-Cams

Finest selection of cheap IP cams that have root backdoor accounts and many more exploits 

_[raw source](https://raw.githubusercontent.com/pierrekim/pierrekim.github.io/6bd008fa7672325d470723bce18b7d00fad3d0e2/blog/2017-03-08-camera-goahead-0day.html)_


_MAC vendor list [raw source](https://gist.githubusercontent.com/aallan/b4bb86db86079509e6159810ae9bd3e4/raw/846ae1b646ab0f4d646af9115e47365f4118e5f6/mac-vendor.txt)_


## Telegram Notifications

You can get a message on Telegram if RasPot detected something.

1. Create Telegram bot with @BotFather
2. Get Bot's Token
3. Get the Chat_ID of your Telegram account
4. `mv telegram.conf.example telegram.conf`
5. Paste Token and Chat_ID into `telegram.conf`
6. Select Telegram during installation.