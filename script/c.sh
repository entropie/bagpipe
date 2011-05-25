#!/bin/sh

vlc="/Applications/VLC.app/Contents/MacOS/VLC"
ext="mp3"
dst="/Users/mit/Documents/"

for a in *$fmt; do
$vlc -I dummy -vvv "./$a" --sout "#transcode{acodec=mp3,ab=128,channels=2,samplerate=44100}:std{mux=raw,dst=\"$dst$a.$ext\",access=file}" vlc://quit
done
