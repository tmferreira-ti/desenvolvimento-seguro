#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/desenvolvimento-seguro/refs/heads/main/interfaces -O /etc/network/interfaces
curl -fsSL https://raw.githubusercontent.com/tmferreira-ti/desenvolvimento-seguro/refs/heads/main/prepara_lab.sh | sudo bash
curl -fsSL https://git.tmferreira.tec.br/tiago.ferreira/desenvolvimento_sitemas_seg_info/raw/branch/main/deploy.sh | sudo bash
echo "Configuração finalizada, reiniciando."
sleep 3
sudo reboot
