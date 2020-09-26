#!/bin/sh

set -e

SKETCH=$1

FRAMES="$SKETCH/frames/fr%03d.png"
PALETTE="$SKETCH/tmp/palette.png"
VIDEO="$SKETCH/tmp/$SKETCH.mkv"
OUTPUTFILE="$SKETCH-$(date +%Y%m%d_%H%M%S).gif"

echo "generating palette from frames"
ffmpeg -v warning -i $FRAMES -vf palettegen -y $PALETTE
echo "converting frames to video"
ffmpeg -v warning -i $FRAMES -y $VIDEO
echo "converting video to gif"
ffmpeg -v warning -i $VIDEO -i $PALETTE -filter_complex paletteuse "$SKETCH/output/$OUTPUTFILE"
echo "removing temp files"
rm $SKETCH/tmp/*

# ffmpeg -v warning -i $FRAMES "$SKETCH/output/$OUTPUTFILE"
