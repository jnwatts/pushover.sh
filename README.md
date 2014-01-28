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

    pushover.sh [-d <device>] [-D <timestamp>] [-p <priority>] [-t <title>] [-T <TOKEN>] [-s <sound>] [-u <url>] [-U <USER/GROUP>] [-a <url_title>] <message>

To use this script, you must have TOKEN and USER (or GROUP) keys from [PushOver][1]. These may then be specified on the terminal with `-T` and `-U`, or you may store default values for both in `${HOME}/.config/pushover.conf`. If used, the file must look like:

    TOKEN="your application's token here"
    USER="your user/group key here"

Shell compatibility
===================

A word of warning: I use bash (as in real bash, not dash) on all of my machines and I have a tendency to forget what syntax is cross-shell compatible. If things behave very strangely for you, this is very likely the first thing you should check. Better yet, if you know a better way a particular line could be implemented, don't hesitate to submit a patch. I would really like for this script to someday work on bash, dash and sh equally. :-)

[1]: http://www.pushover.net
