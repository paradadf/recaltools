WINDOWS BATCH:
Place fastsorter.bat on your roms folder and copy the clean gamelist to a text file called 'fastsorter.txt' next to it.
If you prefer, you can create specific gamelists instead, e.g. 'Parents only.txt', which would be read first.
Instructions: http://imgur.com/a/iyxKF


WIP:
OS X & LINUX BASH:
#!/bin/bash
ROMNAME in `cat fastsorter.txt` ; do ; mkdir -p "Parents only" ;  cp $ROMNAME "Parents only" ; done
