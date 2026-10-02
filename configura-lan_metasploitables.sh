#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/desenvolvimento-seguro/refs/heads/main/interfaces -O /etc/network/interfaces
curl -fsSL https://raw.githubusercontent.com/tmferreira-ti/desenvolvimento-seguro/refs/heads/main/prepara_lab.sh | sudo bash
wget https://git.tmferreira.tec.br/tiago.ferreira/desenvolvimento_sitemas_seg_info/raw/branch/main/fatecseg-corp.tar.gz -O /home/vagrant/fatecseg-corp.tar.gz
sudo mkdir /var/www/html/fatecseg > /dev/null
sudo tar -xzf /home/vagrant/fatecseg-corp.tar.gz -C /var/www/html/fatecseg > /dev/null
sudo chown -R www-data:www-data /var/www/html/fatecseg > /dev/null
echo "Configuração finalizada, reiniciando."
sleep 3
sudo reboot
