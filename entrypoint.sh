#!/bin/sh
set -e

echo "Generating SSH host keys..."
ssh-keygen -A

echo "Setting up SSH permissions for paste user..."
mkdir -p /home/paste/.ssh
if [ -n "$AUTHORIZED_HOSTS" ]; then
    echo "$AUTHORIZED_HOSTS" > /home/paste/.ssh/authorized_keys
elif [ -n "$AUTHORIZED_HOSTS_FILE" ] && [ -f "$AUTHORIZED_HOSTS_FILE" ]; then
    cat "$AUTHORIZED_HOSTS_FILE" > /home/paste/.ssh/authorized_keys
else
    touch /home/paste/.ssh/authorized_keys
fi
chown -R paste:paste /home/paste/.ssh
chmod 700 /home/paste/.ssh
chmod 600 /home/paste/.ssh/authorized_keys


echo "Configuring hourly cleanup cron..."
echo "0 * * * * find /var/www/pastes -type f -mmin +1440 -delete" > /etc/crontabs/root

touch /var/log/all.log
chmod 666 /var/log/all.log

mkdir -p /var/log/nginx
ln -sf /var/log/all.log /var/log/nginx/access.log
ln -sf /var/log/all.log /var/log/nginx/error.log

echo "Starting crond..."
crond -b -L /var/log/all.log

echo "Starting sshd..."
/usr/sbin/sshd -D -e >> /var/log/all.log 2>&1 &

echo "Starting nginx..."
nginx -g "daemon off;" >> /var/log/all.log 2>&1 &

tail -f /var/log/all.log &
tail_pid=$!

trap 'kill -TERM $tail_pid; exit 0' TERM INT

wait $tail_pid
