#!/bin/sh
set -e

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

echo "Installing mini-router web files..."
install -d /www/mini-router
install -m 0644 "$ROOT_DIR/www/mini-router/index.html" /www/mini-router/index.html
install -m 0755 "$ROOT_DIR/www/cgi-bin/traffic.sh" /www/cgi-bin/traffic.sh
install -m 0755 "$ROOT_DIR/www/cgi-bin/firewall.sh" /www/cgi-bin/firewall.sh

/etc/init.d/uhttpd reload || true

echo "Done. Open http://<router-ip>/mini-router/"
