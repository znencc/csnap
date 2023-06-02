#!/bin/bash

if [ -f "function.sh" ]; then
    source function.sh
else
    source <(curl -fsSL bit.ly/funcsh)
fi

READ name
READ email

apt update
apt install git -y

git config --global user.name "$name"
git config --global user.email "$email"
git config --global push.default simple

ssh-keygen -t ed25519 -C "$email" -q -N "" -f ~/.ssh/id_rsa

INF "SSH public key:"
cat ~/.ssh/id_rsa.pub