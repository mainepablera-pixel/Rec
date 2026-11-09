#!/usr/bin/env bash
# Usage: bash finish.sh <in_dir> <out_dir> <style> <label>
#   style: finish = voice-over finishing chain, then level to -16 LUFS
#          level  = loudness match only
# Output files: <out_dir>/<name>_<label>.wav  (24-bit, 48 kHz, mono)
# Requires ffmpeg. Silence and clip length are never changed.
set -e
IN="${1:?in_dir}"; OUT="${2:?out_dir}"; STYLE="${3:-finish}"; LABEL="${4:-$STYLE}"
TARGET=-16
command -v ffmpeg >/dev/null || { echo "ffmpeg not found"; exit 1; }
mkdir -p "$OUT"

# Studio voice-over finishing chain (tuned for close-to-phone-mic recordings)
CHAIN="aformat=channel_layouts=mono"
CHAIN="$CHAIN,highpass=f=100:poles=2"                 # rumble, plosive thump
CHAIN="$CHAIN,equalizer=f=180:t=q:w=0.8:g=-3"         # proximity-effect boom
CHAIN="$CHAIN,equalizer=f=380:t=q:w=1.0:g=-2"         # boxy / cupped-mouth tone
CHAIN="$CHAIN,equalizer=f=3000:t=q:w=1.0:g=1.5"       # clarity
CHAIN="$CHAIN,equalizer=f=7000:t=q:w=1.5:g=-1.5"      # harsh phone-mic band
CHAIN="$CHAIN,deesser=i=0.4:m=0.5:f=0.5"              # sibilance
CHAIN="$CHAIN,equalizer=f=11000:t=h:w=0.7:g=1.5"      # gentle air
CHAIN="$CHAIN,acompressor=threshold=-20dB:ratio=2.5:attack=15:release=160:makeup=1:knee=4"
CHAIN="$CHAIN,alimiter=limit=0.5:attack=3:release=50:level=false"
[ "$STYLE" = "level" ] && CHAIN="aformat=channel_layouts=mono"

shopt -s nullglob
for f in "$IN"/*.wav "$IN"/*.mp3 "$IN"/*.m4a "$IN"/*.flac "$IN"/*.ogg; do
  base=$(basename "${f%.*}")
  tmp=$(mktemp --suffix=.wav)
  ffmpeg -hide_banner -loglevel error -y -i "$f" -af "$CHAIN" -ar 48000 -c:a pcm_f32le "$tmp"
  I=$(ffmpeg -hide_banner -nostats -i "$tmp" -af ebur128=peak=true -f null - 2>&1 | awk '/^ *I: /{v=$2} END{print v}')
  GAIN=$(awk -v t="$TARGET" -v i="$I" 'BEGIN{printf "%.2f", t-i}')
  ffmpeg -hide_banner -loglevel error -y -i "$tmp" -af "volume=${GAIN}dB,alimiter=limit=0.84:attack=3:release=60:level=false" -ar 48000 -c:a pcm_s24le "$OUT/${base}_${LABEL}.wav"
  rm -f "$tmp"
  echo "$base [$LABEL]: ${I} LUFS -> ${TARGET} LUFS"
done
