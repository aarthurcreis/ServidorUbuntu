#!/bin/bash

set -e

echo "Atualizando repositórios..."
apt update -y

echo "Instalando pacotes..."
xargs -a pacotes.txt apt install -y

echo "Tudo instalado. Não pense que fiz isso por você, ok?"
