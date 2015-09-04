#!/bin/bash
#
# DESCRIÇÃO: Colocar aqui a descrição da Norma
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     21/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=4
CRITICO=true
EXECUTANDO_IN="IN4"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Atualizacao do sistema com yum"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    export http_proxy=http://usuario:senha@servidor_proxy:porta
    export ftp_proxy=http://usuario:senha@servidor_proxy:porta
    yum update -y &&
    yum upgreade -y
    evaluate_return_code $?
}

function do_rollback()
{
    echo "[+] $EXECUTANDO_IN - ROLLBACK (nao ha rollback para esta norma)"
}


# Main

if [[ $TIPO_DE_EXECUCAO -eq 1 ]]; then
    do_config
else
    do_rollback
fi

