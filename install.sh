#!/bin/bash
set -e

# TODO should check ownership of /usr/local here

if [ ! -d "/usr/local" ]; then
  sudo mkdir /usr/local
  sudo chown $(whoami) /usr/local
fi

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
