pushover.bash
=============

Shell-script wrapper around curl for sending messages through PushOver

Usage
=====
    pushover [-t <title>] [-d <device>] <message>

Shell compatibility
===================

A word of warning: I use bash (as in real bash, not dash) on all of my machines and I have a tendency to forget what syntax is cross-shell compatible. If things behave very strangely for you, this is very likely the first thing you should check. Better yet, if you know a better way a particular line could be implemented, don't hessitate to submit a patch :-)