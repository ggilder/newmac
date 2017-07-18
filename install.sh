#!/bin/bash
set -e

if [ ! -d "/usr/local" ]; then
  echo "Creating /usr/local..."
  sudo mkdir /usr/local
fi

if [ $(ls -ld /usr/local | awk '{print $3}') != $(whoami) ]; then
  echo "Changing ownership on /usr/local to $(whoami)..."
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
