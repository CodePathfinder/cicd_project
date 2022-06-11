#!/bin/bash
sudo apt install wget unzip apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
wget https://www.tooplate.com/zip-templates/2117_infinite_loop.zip
unzip -o 2117_infinite_loop.zip
sudo cp -r 2117_infinite_loop/* /var/www/html/
sudo systemctl restart apache2
