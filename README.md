pushover.sh
===========

Shell script wrapper around curl for sending messages through [Pushover][1].

Installation
============

To install `pushover.sh`, run

```
git clone https://github.com/jnwatts/pushover.sh.git;
cd pushover.sh;
chmod +x pushover.sh;
```

Usage
=====

    pushover.sh <options> <message>
	 -A API key conf file
     -c <callback>
	 -C curl options
     -d <device>
     -D <timestamp>
     -e <expire>
     -p <priority>
	 -P <http://proxy:port/>
     -r <retry>
     -t <title>
     -T <TOKEN> (required if not in config file)
     -s <sound>
     -u <url>
     -U <USER> (required if not in config file)

To use this script, you must have TOKEN and USER (or GROUP) keys from [PushOver][1]. These may then be specified on the terminal with `-T` and `-U`, or you may store default values for both in `${HOME}/.config/pushover.conf`. If you need to override this path, such as for multiple accounts, use the environment variable PUSHOVER_CONFIG with the full path to the desired config file.

Sounds:
    pushover - Pushover (default)
	bike - Bike
	bugle - Bugle
	cashregister - Cash Register
	classical - Classical
	cosmic - Cosmic
	falling - Falling
	gamelan - Gamelan
	incoming - Incoming
	intermission - Intermission
	magic - Magic
	mechanical - Mechanical
	pianobar - Piano Bar
	siren - Siren
	spacealarm - Space Alarm
	tugboat - Tug Boat
	alien - Alien Alarm (long)
    climb - Climb (long)
	persistent - Persistent (long)
	echo - Pushover Echo (long)
	updown - Up Down (long)
	none - None (silent) 


Config file format
==================

    TOKEN="your application's token here"
    USER="your user/group key here"

Shell compatibility
===================

A word of warning: I use bash (as in real bash, not dash) on all of my machines and I have a tendency to forget what syntax is cross-shell compatible. If things behave very strangely for you, this is very likely the first thing you should check. Better yet, if you know a better way a particular line could be implemented, don't hesitate to submit a patch. I would really like for this script to someday work on bash, dash and sh equally. :-)

[1]: http://www.pushover.net
