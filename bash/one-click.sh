#!/bin/bash

if [ -f "function.sh" ]; then
    source function.sh
else
    source <(curl -fsSL bit.ly/funcsh)
fi

READ domain
READ flexget_passward

apt update
apt install python3-pip python3-venv -y

python3 -m venv venv
source /root/venv/bin/activate

INF "Installing JupyterLab..."
pip install jupyterlab
pip install bash_kernel
python -m bash_kernel.install
pip install --upgrade jupyterlab jupyterlab-git
pip install 'jupyterlab>=3.0.0,<4.0.0a0' jupyterlab-lsp
pip install 'python-lsp-server[all]'

INF "Installing FlexGet..."
pip install flexget

deactivate

mkdir -p /root/.flexget/
cat > /root/.flexget/config.yml <<EOF
web_server:
    bind: 0.0.0.0
    port: 5050
    web_ui: yes

templates:
    anime:
        accept_all: yes
        seen: local
        aria2:
            path: /flexget/
            port: 
            server: <server>
            secret: <secret>
    
tasks:
    U149:
        rss: https://share.dmhy.org/topics/rss/rss.xml?keyword=U149+1080+%E7%AE%80+Production&sort_id=0&team_id=669&order=date-desc
        template: anime

#schedules:
#  - tasks: '*'
#    interval:
#      minutes: 30
EOF
ln /root/.flexget/config.yml /root/conf/FlexGet.yml
/root/venv/bin/flexget web passwd $flexget_passward

cat > /etc/systemd/system/flexget.service <<EOF
[Unit]
Description=FlexGet
After=network.target

[Service]
Type=simple
User=root
ExecStart=/root/venv/bin/flexget daemon start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/jupyterlab.service <<EOF
[Unit]
Description=JupyterLab
After=network.target

[Service]
Type=simple
User=root
ExecStart=/root/venv/bin/jupyter-lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
WorkingDirectory=/root
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start jupyterlab
systemctl enable jupyterlab
systemctl start flexget
systemctl enable flexget

mkdir -p /etc/caddy/
mkdir -p /root/conf/
cat  > /etc/caddy/Caddyfile <<EOF
al.$domain {
    reverse_proxy localhost:5244
}
dc.$domain {
    reverse_proxy localhost:9000
}
fg.$domain {
    reverse_proxy localhost:5050
}
lab.$domain {
    reverse_proxy localhost:8888
}
# www.$domain {
#     redir https://$domain{uri}
# }
EOF
ln /etc/caddy/Caddyfile /root/conf/Caddyfile.conf


INF "Installing Docker..."
curl -fsSL https://get.docker.com | sh

INF "Run AList container..."
docker run -d \
-p 5244:5244 \
--name alist \
--restart=always \
-v /etc/alist:/opt/alist/data \
-e PUID=0 -e PGID=0 -e UMASK=022 \
xhofe/alist:latest
mkdir -p /etc/alist/eden/
ln -s /etc/alist/eden/ /root/eden

INF "Run Portainer container..."
docker run -d \
-p 8000:8000 \
-p 9000:9000 \
--name portainer \
--restart=always \
-v portainer_data:/data \
-v /var/run/docker.sock:/var/run/docker.sock \
portainer/portainer-ce:latest

INF "Run Caddy container..."
docker run -d \
--net=host \
--name caddy \
-v caddy_data:/data \
-v caddy_config:/config \
-v /etc/caddy/site:/srv \
-v /etc/caddy/Caddyfile:/etc/caddy/Caddyfile \
caddy

docker exec -it alist ./alist admin

/root/venv/bin/jupyter server list