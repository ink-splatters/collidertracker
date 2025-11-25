#/bin/bash

export DISPLAY=:0
export JACK_NO_START_SERVER=1
export JACK_NO_AUDIO_RESERVATION=1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib64/

sudo /etc/init.d/dbus start
jackd -V
$(cat /etc/jackdrc) &
sleep 0.5
icecast2 -c /etc/icecast2/icecast.xml &
sleep 0.5
darkice -c /etc/darkice.cfg &
sleep 0.25
jack_connect crone:output_1 darkice:left
jack_connect crone:output_2 darkice:right
tail -f /dev/null # stay alive
