#!/bin/bash
set -e

print () {
  no_color='\033[0m'
  if [ "$2" = "green" ]; then     color='\033[1;32m'
  elif [ "$2" = "yellow" ]; then  color='\033[1;33m'
  elif [ "$2" = "red" ]; then     color='\033[1;31m'
  fi
  echo -e "${color}$1${no_color}"
}

cd "$(dirname "$0")"

print "[1/3] bitcoind" yellow
chmod +x bitcoincash/bin/bitcoind
print "  OK (pre-built binary)" green

print "[2/3] ckpool-bch" yellow
cd ckpool-bch
./autogen.sh
./configure --enable-sv2
make -j$(nproc)
print "  OK" green
cd ..

print "[3/3] ckstats-bch" yellow
cd ckstats-bch
pnpm install
pnpm build
print "  OK" green
cd ..

echo ""
print "All built." green
echo ""
echo "Next steps:"
echo "  1. Edit bitcoincash/bitcoind.conf.example -> bitcoind.conf"
echo "  2. Start bitcoind"
echo "  3. Edit ckpool-bch/ckpool.conf"
echo "  4. Start ckpool"
echo "  5. Edit ckstats-bch config"
echo "  6. Start ckstats"
