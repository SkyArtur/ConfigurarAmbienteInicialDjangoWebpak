#!/bin/bash

# Desativa a exibição dos comandos no console para uma aparência mais limpa
set -e

# Substitua o nome do app
APP="app_test"

# Altera o diretório para onde o script está localizado e sobre um nível
cd "$(dirname "$0")"
cd ..

# Cria um ambiente virtual Python.
python3 -m venv .venv

# Inicia o ambiente virtual do projeto
source .venv/bin/activate

# Atualiza o pip e instala as bibliotecas necessárias
pip install --upgrade pip
pip install django pillow python-dotenv passlib psycopg2-binary

# Inicializa o Node.js e instala pacotes
npm init -y
npm i --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env \
  css-loader sass-loader sass style-loader mini-css-extract-plugin source-map-loader \
  css-minimizer-webpack-plugin terser-webpack-plugin bootstrap bootstrap-icons jquery dotenv

# Inicia o projeto Django
django-admin startproject setup .

# Cria o app
python3 manage.py startapp "$APP"

# Cria as pastas iniciais do projeto
mkdir -p templates/pages templates/includes src/js src/sass "$APP"/static/css "$APP"/static/js

# Garante que as pastas de destino existem antes de mover os arquivos
mkdir -p "$APP"/static/bootstrap "$APP"/static/bootstrap/icons "$APP"/static/jquery

# Move os módulos necessários para a pasta 'static' do projeto
mv node_modules/bootstrap/dist "$APP"/static/bootstrap
mv node_modules/bootstrap-icons/font "$APP"/static/bootstrap/icons
mv node_modules/jquery/dist "$APP"/static/jquery

# Copia arquivos de configuração se existirem
[ -f config/files/.env ] && cp config/files/.env ./.env
[ -f config/files/webpack.config.js ] && cp config/files/webpack.config.js ./webpack.config.js
[ -f config/files/docker-compose.yaml ] && cp config/files/docker-compose.yaml ./docker-compose.yaml

# Verifica se o Docker está rodando antes de iniciar os containers
docker info > /dev/null 2>&1
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
  echo "Docker não está rodando. Por favor, inicie o Docker."
  exit 1
fi

# Inicia os containers Docker
docker compose up -d

echo "Configuração concluída com sucesso!"