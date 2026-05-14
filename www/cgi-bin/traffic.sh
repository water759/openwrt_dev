#!/bin/sh

echo "Content-Type: application/json"
echo ""

if ! command -v ubus >/dev/null 2>&1; then
  echo '{"ok":false,"error":"ubus not found"}'
  exit 0
fi

IFACES="wan lan"
OUT='{"ok":true,"interfaces":['
SEP=""

for IF in $IFACES; do
  DATA=$(ubus call network.interface.$IF status 2>/dev/null)
  RX=$(echo "$DATA" | jsonfilter -e '@["statistics"]["rx_bytes"]' 2>/dev/null)
  TX=$(echo "$DATA" | jsonfilter -e '@["statistics"]["tx_bytes"]' 2>/dev/null)
  [ -z "$RX" ] && RX=0
  [ -z "$TX" ] && TX=0
  OUT="$OUT$SEP{\"name\":\"$IF\",\"rx_bytes\":$RX,\"tx_bytes\":$TX}"
  SEP=","
done

OUT="$OUT]}"
echo "$OUT"
