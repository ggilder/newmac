#!/bin/bash
set -e

if [ ! -e "/usr/local/babushka" ]; then
  echo
  echo "Installing babushka..."
  sh -c "`curl https://babushka.me/up`" < /dev/null
fi

echo
echo "Updating babushka..."
babushka babushka

echo "Babushka version:" `babushka --version`

echo
echo "Installing stuff..."
babushka newmac
