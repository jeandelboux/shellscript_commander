#!/bin/bash
#
# DESCRIÇÃO: 
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     20/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=2
CRITICO=false
EXECUTANDO_IN="IN2"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Desabilitando o comando ctrl+alt+del"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    cp -p /etc/inittab ${RESTOREPOINT_DIR}/inittab &&
    cp -p /etc/inittab $TEMP_DIR/inittab &&
    sed 's/^ca::ctrlaltdel/#ca::ctrlaltdel/' /etc/inittab > $TEMP_DIR/inittab &&
    cp -p $TEMP_DIR/inittab /etc/inittab &&
    rm -f $TEMP_DIR/inittab
    evaluate_return_code $?
}

function do_rollback()
{
    echo "[+] $EXECUTANDO_IN - ROLLBACK"
    cp -p ${RESTOREPOINT_DIR}/inittab /etc/inittab
}


# Main

if [[ $TIPO_DE_EXECUCAO -eq 1 ]]; then
    do_config
else
    do_rollback
fi

