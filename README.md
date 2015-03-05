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
     -c <callback>
     -d <device>
     -D <timestamp>
     -e <expire>
     -p <priority>
     -r <retry>
     -t <title>
     -T <TOKEN> (required if not in config file)
     -s <sound>
     -u <url>
     -U <USER> (required if not in config file)

To use this script, you must have TOKEN and USER (or GROUP) keys from [PushOver][1]. These may then be specified on the terminal with `-T` and `-U`, or you may store default values for both in `${HOME}/.config/pushover.conf`. If you need to override this path, such as for multiple accounts, use the environment variable PUSHOVER_CONFIG with the full path to the desired config file.

Config file format
==================

    TOKEN="your application's token here"
    USER="your user/group key here"
    CURL_OPTS="options to pass to curl"

Shell compatibility
===================

A word of warning: I use bash (as in real bash, not dash) on all of my machines and I have a tendency to forget what syntax is cross-shell compatible. If things behave very strangely for you, this is very likely the first thing you should check. Better yet, if you know a better way a particular line could be implemented, don't hesitate to submit a patch. I would really like for this script to someday work on bash, dash and sh equally. :-)

[1]: http://www.pushover.net
