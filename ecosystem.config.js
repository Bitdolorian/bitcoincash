module.exports = {
  apps: [{
    name: 'bitcoincash',
    script: '/home/YOURPATH/bitcoincash/bin/bitcoind',
    args: '-datadir=/home/YOURPATH/bitcoincash/data -daemon=0',
    interpreter: 'none',
    autorestart: true,
    log_type: 'json'
  }]
}

// change YOURPATH to your actual directory
