:: Desativa a exibição dos comandos no console para uma aparência mais limpa.
@echo off
setlocal EnableDelayedExpansion
:: Caminho para o arquivo .env
set ENV_FILE=.\files\.env
:: Verifica se o arquivo .env existe
if exist %ENV_FILE% (
    for /f "usebackq tokens=1,* delims== " %%A in (%ENV_FILE%) do (
        set %%A=%%B
    )
) else (
    echo Arquivo .env não encontrado.
    exit /b 1
)
:: Altera o diretório atual para o diretório onde o script está localizado.
cd /d %~dp0
:: Retorna o prompt para o diretório que será a raiz do projeto.
cd ..
:: cria um ambiente virtual Python para o projeto.
call python -m venv .venv
:: iniciar o ambiente virtual do projeto.
call .\.venv\Scripts\activate.bat
:: Atualiza o pip.
call python -m pip install --upgrade pip
:: instalar as bibliotecas python necessárias.
call pip install django pillow python-dotenv passlib psycopg2 psycopg2-binary
:: Inicia o NodeJS.
call npm init -y
:: Instala os módulos necessários.
call npm i  --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env css-loader sass-loader sass style-loader mini-css-extract-plugin source-map-loader css-minimizer-webpack-plugin terser-webpack-plugin bootstrap bootstrap-icons jquery dotenv
:: Inicia o projeto Django.
call django-admin startproject setup .
:: Cria o app.
call python .\manage.py startapp %APP%
:: Cria as pastas iniciais do projeto e para o desenvolvimento.
mkdir templates\pages
mkdir templates\includes
mkdir src\js
mkdir src\sass
mkdir %APP%\static\css
mkdir %APP%\static\js
:: Cria os arquivos iniciais para desenvolvimento frontend.
echo.>src\js\index.js
echo.>src\sass\main.sass
echo.>.gitignore
echo.>templates\index.html
:: Move os módulos necessários para a pasta 'static' do projeto.
move node_modules\bootstrap\dist %APP%\static\bootstrap
move node_modules\bootstrap-icons\font %APP%\static\bootstrap\icons
move node_modules\jquery\dist %APP%\static\jquery
copy config\files\.env .\.env
copy config\files\webpack.config.js .\webpack.config.js
copy config\files\docker-compose.yaml .\docker-compose.yaml
:: Verifica se o Docker está rodando.
call docker info >null 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Docker não está instalado, não está no PATH ou não está rodando. Inicie o Docker.
) ELSE (
    :: inicia a configuração do container do banco de dados da aplicação.
    call docker-compose up -d
)
echo "Ambiente configurado."
pause