#!/bin/bash

if [ -f "function.sh" ]; then
    source function.sh
else
    source <(curl -fsSL bit.ly/funcsh)
fi

# 定义菜单头部
header() {
  clear
  echo -e "${CYAN}${BOLD}====================${RESET}"
  echo -e "${CYAN}${BOLD}        菜单        ${RESET}"
  echo -e "${CYAN}${BOLD}====================${RESET}"
}

# 定义菜单选项
menu_options() {
  echo -e "${YELLOW}${BOLD}0.${RESET}${GREEN} 退出${RESET}"
  echo -e "${CYAN}${BOLD}--------------------${RESET}"
  echo -e "${YELLOW}${BOLD}1.${RESET}${GREEN} Docker安装AList${RESET}"
  echo -e "${YELLOW}${BOLD}2.${RESET}${GREEN} 选项2${RESET}"
  echo -e "${YELLOW}${BOLD}3.${RESET}${GREEN} 选项3${RESET}"
  echo ""
}

# 主菜单循环
while true; do
  header
  menu_options
  READ choice

  case $choice in
    1)
      # 执行选项1操作
      INF "执行选项1操作..."
      read -n 1 -s -r -p "按任意键继续..."
      ;;
    2)
      # 执行选项2操作
      INF "执行选项2操作..."
      read -n 1 -s -r -p "按任意键继续..."
      ;;
    3)
      # 执行选项3操作
      INF "执行选项3操作..."
      read -n 1 -s -r -p "按任意键继续..."
      ;;
    0)
      echo "退出程序..."
      exit 0
      ;;
    *)
      ERR "无效的输入"
      read -n 1 -s -r -p "按任意键继续..."
  esac
done