#!/bin/bash
#
# DESCRIÇÃO: 
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     20/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=17
CRITICO=true
EXECUTANDO_IN="IN17"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Assegurar que o syslog esta sendo executado corretamente"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    a="syslog funcionando corretamente"
    b=$RANDOM
    c=$RANDOM
    logger "$a $b$c" &&
    sleep 2 &&
    tail -20 /var/log/messages | grep "$a $b$c" >/dev/null
    evaluate_return_code ${PIPESTATUS[@]}
}

function do_rollback()
{
    echo "[+] $EXECUTANDO_IN - ROLLBACK"
}


# Main

if [[ $TIPO_DE_EXECUCAO -eq 1 ]]; then
    do_config
else
    do_rollback
fi

