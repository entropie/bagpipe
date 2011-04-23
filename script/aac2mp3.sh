#!/bin/bash
#
# $Id: aac2mp3,v 1.2  03/30/2008 10:00 Daniel Tavares (dantavares@gmail.com) - 
# Based on Script -  rali Exp $
#
#
# Convert one or more AAC/M4A files to MP3.  Based on a script example
# I found at: http://gimpel.gi.funpic.de/Howtos/convert_aac/index.html
#
ME=`basename ${0}`
FFMPEG="/usr/bin/ffmpeg"
EXT="mp4"
BITRATE="128"
do_usage() {            # explanatory text
 echo "usage: ${ME} [-b nnn] [-e ext] [-f] [-c] [-r] [-v] [-h] [file list]"
 echo "       Convert music from AAC format to MP3"
 echo "  -m /path/app  Specify the location of ffmpeg(1)"
 echo "  -b nnn        bitrate for mp3 encoder to use"
 echo "  -e ext        Use .ext rather than .m4a extension"
 echo "  -f            Force overwrite of existing file"
 echo "  -c            Delete original AAC|M4A file(s)"
 echo "  -v            Verbose output"
 echo "  -h            This information"
 echo ""
 echo "For recursive directory, use: find -name '*.${EXT}' -exec ${ME} "{}" [args] \;"
 exit 0
 }
do_error() {
 echo "$*"
 exit 1
 }
file_overwrite_check() {
 if [ "$FORCE" != "yes" ]
 then
   test -f "${1}" && do_error "${1} already exists."
 else
   test -f "${1}" && echo "  ${1} is being overwritten."
 fi
 }
create_mp3() {  # use ffmpeg(1) to convert from AAC to MP3
 file_overwrite_check "${2}"
 test $VERBOSE && echo -n "Converting file: ${1}"
 ${FFMPEG} -v 5 -y -i "${1}" -acodec libmp3lame -ac 2 -ab ${BITRATE}k "${2}";
 if [ $? -ne 0 ]
 then
   echo ""
   echo "Error!"
   do_cleanup
   do_error "Exiting"
 fi
 test $VERBOSE && echo ".  OK"
 }
do_cleanup() {  # Delete intermediate and (optionally) original file(s)
 test ${RMM4A} && rm -f "${1}"
 test $VERBOSE && echo ".  OK"
 }
do_set_bitrate() {
 test $VERBOSE && echo -n "Setting bitrate to: $1 kbps"
 BITRATE=$1
 test $VERBOSE && echo ".  OK"
 }
GETOPT=`getopt -o l:m:b:e:cfhrv -n ${ME} -- "$@"`
if [ $? -ne 0 ]
then
 do_usage
fi
eval set -- "$GETOPT"
while true
do
 case "$1" in
   -m) FFMPEG=$2 ; shift ; shift ;;
   -b) do_set_bitrate $2 ; shift ; shift ;;
   -e) EXT=$2 ; shift ; shift ;;
   -f) FORCE="yes" ; shift ;;
   -c) RMM4A="yes" ; shift ;;
   -v) VERBOSE="yes" ; shift ;;
   -h) do_usage ;;
   --) shift ; break ;;
    *)  do_usage ;;
 esac
done
test -f $FFMPEG || do_error "$FFMPEG not found. Use \"-m\" switch."
if [ $# -eq 0 ]
then                    # Convert all files in current directory
 for IFILE in *.${EXT}
 do
   if [ "${IFILE}" == "*.${EXT}" ]
   then
     do_error "Not found ${EXT} in this folder."
   fi
   OUT=`echo "${IFILE}" | sed -e "s/\.${EXT}//g"`
   create_mp3 "${IFILE}" "${OUT}.mp3"
   do_cleanup "${IFILE}" 
 done
else                    # Convert listed files
 for IFILE in "$*"
 do
   test -f "${IFILE}" || do_error "${IFILE} not found."	 
   OUT=`echo "${IFILE}" | sed -e "s/\.${EXT}//g"`	 
   create_mp3 "${IFILE}" "${OUT}.mp3"
   do_cleanup "${IFILE}" 	
 done	 
fi	 
exit 0
[edit]
