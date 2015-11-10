# About

This shell script will update your QW binaries. It's using Deurk GitHub sources as a primary source to recompile following:
* ktx
* mvdparser
* mvdsv
* qtv
* qwfwd

## Requirements

* git
* bash
* gcc/make

## Installation

Put this script anywhere in your system. Remember to update configuration section. Every variable is described so you shouldn't have any problems with that.

```
################################################### CONFIGURATION STARTS HERE
# directory to store GIT sources
SRCROOTDIR=/home/users/quake/src/_official
# full path(s) to mvdsv binary currently installed in your system
LOC_MVDSV="/home/users/quake/q1/mvdsv"
# full path(s) to ktx binary currently installed in your system
LOC_KTX="/home/users/quake/q1/ktx/qwprogs.so /home/users/quake/q1/ffa/qwprogs.so"
# full path to mvdparser binary currently installed in your system
LOC_MVDPARSER=
# full path to qtv binary currently installed in your system
LOC_QTV=
# full path to qwfwd binary currently installed in your system
LOC_QWFWD=
# automatically update sources?
AUTOUPDATE=yes
# debug: 0=no, anything else=yes
DEBUG=0
################################################### CONFIGURATION END HERE - DO NOT MODIFY ANYTHING BELOW THIS LINE
```

## Example outputs:
### help
```
[d2@quake ~/src/_official] $ ./build.sh
[-] usage: build.sh [ktx|mvdparser|mvdsv|qtv|qwfwd]

this script is using Deurk sources (https://github.com/deurk/)
```

### clean, debug-free output from copilation of KTX
```
[d2@quake ~/src/_official] $ ./build.sh ktx
[i] working on "ktx" project
        [+] trying to update sources first
                [+] OK
        [+] configure
                [+] OK
        [+] make
                [+] OK
        [i] done, "qwprogs.so" should be available under "/home/users/quake/src/_official/ktx/binaries" directory
        [i] updatng binaries
                [+] updating "/home/users/quake/q1/ktx/qwprogs.so"
                        [+] creating backup copy: /home/users/quake/q1/ktx/qwprogs.so_2015-11-10@104231
                [+] updating "/home/users/quake/q1/ffa/qwprogs.so"
                        [+] creating backup copy: /home/users/quake/q1/ffa/qwprogs.so_2015-11-10@104231
                [i] done, remember to restart "ktx"
```

### Bugs

None so far :-)

### Ideas? Reports?

Contact me at: d2@tdhack.com