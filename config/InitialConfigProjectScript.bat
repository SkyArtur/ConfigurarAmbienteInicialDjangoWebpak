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

:: Altera o diretório para onde o script está localizado e sobe um nível
cd /d %~dp0
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
call npm i  --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env ^
    css-loader sass-loader sass style-loader mini-css-extract-plugin source-map-loader ^
    css-minimizer-webpack-plugin terser-webpack-plugin bootstrap bootstrap-icons jquery dotenv

:: Cria as pastas iniciais do projeto e para o desenvolvimento.
mkdir templates\pages templates\includes src\js src\sass  %APP%\static\css  %APP%\static\js

:: Cria os arquivos iniciais para desenvolvimento frontend.
echo.>src\js\index.js
echo.>src\sass\main.sass
echo.>.gitignore
echo.>templates\index.html

:: Copia os arquivos para a raiz do projeto.
if exist config\files\.env copy config\files\.env .\.env
if exist config\files\webpack.config.js copy config\files\webpack.config.js .\webpack.config.js
if exist config\files\docker-compose.yaml copy config\files\docker-compose.yaml .\docker-compose.yaml

:: Caso não deseje criar a aplicação automaticamente, remova o comentário( @REM ) de GOTO APLICACAO e :APLICACAO
@REM GOTO APLICACAO

:: Inicia o projeto Django.
call django-admin startproject setup .

:: Cria o app.
call python .\manage.py startapp %APP%

:: Cria os diretórios para os arquivos estáticos da aplicação.
mkdir %APP%\static\css  %APP%\static\js

:: Move os módulos necessários para a pasta 'static' do projeto.
move node_modules\bootstrap\dist %APP%\static\bootstrap
move node_modules\bootstrap-icons\font %APP%\static\bootstrap\icons
move node_modules\jquery\dist %APP%\static\jquery

@REM :APLICACAO

GOTO DOCKERCOMPOSE

:: Este bloco de código é ignorado pela execução do script
:: Caso deseje configurar o container para o banco de dados da aplicação, remova ou comente (@REM) GOTO DOCKERCOMPOSE e :DOCKERCOMPOSE
:: Verifica se o Docker está rodando.
call docker info >null 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Docker não está instalado, não está no PATH ou não está rodando. Inicie o Docker.
) else (
    :: inicia a configuração do container do banco de dados da aplicação.
    call docker-compose up -d
)

:DOCKERCOMPOSE

echo "Ambiente configurado."
pause