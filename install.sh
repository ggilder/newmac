#!/bin/bash
set -e

if [ ! -d "/usr/local" ]; then
  echo "Creating /usr/local..."
  sudo mkdir /usr/local
fi

if [ ! -e "/usr/local/babushka" ]; then
  echo
  echo "Installing babushka..."
  sudo mkdir /usr/local/babushka
  sudo chown -R $(whoami) /usr/local/babushka
  sh -c "`curl https://babushka.me/up`"
fi

echo
echo "Updating babushka..."
babushka babushka

echo "Babushka version:" `babushka --version`

echo
echo "Babushka is installed! Now you might want to run one of the following:"
echo "> babushka newmac"
echo "> babushka workmac"
