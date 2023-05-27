#!/bin/bash

# Define color codes
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
PINK='\e[1;35m'
SHAN='\e[1;33;5m'
NC='\e[0m' # No Color

function ERR() {
  echo -e "${RED}[ERROR] $1${NC}"
}

function WARN() {
  echo -e "${YELLOW}[WARNING] $1${NC}"
}

function INF() {
  echo -e "${GREEN}[INFO] $1${NC}"
}

function READ() {
  # Read user input and trim leading/trailing whitespace
  read -p "$(echo -e "${BLUE}Enter $1:${NC} ")" $1
  eval $1=\${$1// /}
}