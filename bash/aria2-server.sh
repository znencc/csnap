#!/bin/bash

if [ -f "function.sh" ]; then
    source function.sh
else
    source <(curl -fsSL bit.ly/funcsh)
fi

READ BW_EMAIL 
READ BW_PASSWD
READ RPC_DOMAIN

apt update
apt install -y unzip expect jq

INF "Installing Bitwarden CLI..."
wget https://github.com/bitwarden/cli/releases/download/v1.22.1/bw-linux-1.22.1.zip
unzip bw-linux-1.22.1.zip
rm bw-linux-1.22.1.zip
mv bw /usr/local/bin
chmod +x /usr/local/bin/bw
export BW_SESSION=$(bw login $BW_EMAIL $BW_PASSWD  --raw)

RcloneConf=$(bw get item Rclone)
RPC_SECRET=$(echo $RcloneConf | jq -r '.fields[] | select(.name == "RPC_SECRET") | .value')
client_id=$(echo $RcloneConf | jq -r '.fields[] | select(.name == "client_id") | .value')
client_secret=$(echo $RcloneConf | jq -r '.fields[] | select(.name == "client_secret") | .value')
config_token=$(echo $RcloneConf | jq -r '.fields[] | select(.name == "config_token") | .value')

if ! command -v docker &> /dev/null
then
    INF "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
fi

mkdir -p /etc/caddy/
cat  > /etc/caddy/Caddyfile <<EOF
$RPC_DOMAIN {
    reverse_proxy localhost:6800
}
EOF

INF "Run Aria2-pro container..."
docker run -d \
--name aria2-pro \
--restart unless-stopped \
--log-opt max-size=1m \
--network host \
-e PUID=$UID \
-e PGID=$GID \
-e RPC_SECRET=$RPC_SECRET \
-e RPC_PORT=6800 \
-e LISTEN_PORT=6888 \
-v /etc/aria2/config:/config \
-v /root/eden:/downloads \
-e SPECIAL_MODE=rclone \
p3terx/aria2-pro

INF "Run Caddy container..."
docker run -d \
--net=host \
--name caddy \
-v caddy_data:/data \
-v caddy_config:/config \
-v /etc/caddy/site:/srv \
-v /etc/caddy/Caddyfile:/etc/caddy/Caddyfile \
caddy

expect <<EOF
set timeout 10

spawn docker exec -it aria2-pro rclone config

expect "n/s/q>"
send "n\r"

expect "name>"
send "OneDrive\r"

expect "Storage>"
send "31\r"

expect "client_id>"
send "$client_id\r"

expect "client_secret>"
send "$client_secret\r"

expect "region>"
send "1\r"

expect "y/n>"
send "n\r"

expect "y/n>"
send "n\r"

expect "config_token>"
send "$config_token\r"

expect "config_type>"
send "1\r"

expect "config_driveid>"
send "1\r"

expect "y/n>"
send "y\r"

expect "y/e/d>"
send "y\r"

expect "e/n/d/r/c/s/q>"
send "q\r"

expect eof
EOF

sed -i 's/#drive-dir=\/DRIVEX\/Download/drive-dir=\/Eden\/'"$HOSTNAME"'/g' /etc/aria2/config/script.conf
