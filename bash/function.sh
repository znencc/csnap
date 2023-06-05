#!/bin/bash

# Define color codes
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

function ERR() {
  echo -e "${RED}${BOLD}[ERROR] $1${RESET}"
}

function INF() {
  echo -e "${GREEN}${BOLD}[INFO] $1${RESET}"
}

function WARN() {
  echo -e "${YELLOW}${BOLD}[WARNING] $1${RESET}"
}

function READ() {
  # Read user input and trim leading/trailing whitespace
  read -p "$(echo -e "${CYAN}${BOLD}Enter $1:${RESET} ")" $1
  eval $1=\${$1// /}
}