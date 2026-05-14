#!/bin/sh

echo "Content-Type: application/json"
echo ""

read_body() {
  cat
}

allowed_policy() {
  case "$1" in
    ACCEPT|REJECT|DROP) return 0 ;;
    *) return 1 ;;
  esac
}

send_defaults() {
  INPUT=$(uci -q get firewall.@defaults[0].input)
  OUTPUT=$(uci -q get firewall.@defaults[0].output)
  FORWARD=$(uci -q get firewall.@defaults[0].forward)
  SYN=$(uci -q get firewall.@defaults[0].synflood_protect)
  [ -z "$INPUT" ] && INPUT="ACCEPT"
  [ -z "$OUTPUT" ] && OUTPUT="ACCEPT"
  [ -z "$FORWARD" ] && FORWARD="REJECT"
  [ -z "$SYN" ] && SYN="1"

  echo "{\"ok\":true,\"defaults\":{\"input\":\"$INPUT\",\"output\":\"$OUTPUT\",\"forward\":\"$FORWARD\",\"synflood_protect\":\"$SYN\"}}"
}

if [ "$REQUEST_METHOD" = "GET" ]; then
  send_defaults
  exit 0
fi

if [ "$REQUEST_METHOD" = "POST" ]; then
  BODY=$(read_body)
  IN=$(echo "$BODY" | jsonfilter -e '@.input')
  OUT=$(echo "$BODY" | jsonfilter -e '@.output')
  FWD=$(echo "$BODY" | jsonfilter -e '@.forward')
  SYN=$(echo "$BODY" | jsonfilter -e '@.synflood_protect')

  if ! allowed_policy "$IN" || ! allowed_policy "$OUT" || ! allowed_policy "$FWD"; then
    echo '{"ok":false,"error":"invalid policy"}'
    exit 0
  fi

  if [ "$SYN" != "0" ] && [ "$SYN" != "1" ]; then
    echo '{"ok":false,"error":"invalid synflood_protect"}'
    exit 0
  fi

  uci set firewall.@defaults[0].input="$IN" || { echo '{"ok":false,"error":"uci set input failed"}'; exit 0; }
  uci set firewall.@defaults[0].output="$OUT" || { echo '{"ok":false,"error":"uci set output failed"}'; exit 0; }
  uci set firewall.@defaults[0].forward="$FWD" || { echo '{"ok":false,"error":"uci set forward failed"}'; exit 0; }
  uci set firewall.@defaults[0].synflood_protect="$SYN" || { echo '{"ok":false,"error":"uci set synflood failed"}'; exit 0; }

  uci commit firewall || { echo '{"ok":false,"error":"uci commit failed"}'; exit 0; }
  /etc/init.d/firewall reload >/dev/null 2>&1 || { echo '{"ok":false,"error":"firewall reload failed"}'; exit 0; }

  echo '{"ok":true}'
  exit 0
fi

echo '{"ok":false,"error":"method not allowed"}'
