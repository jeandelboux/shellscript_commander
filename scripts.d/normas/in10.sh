#!/bin/bash
#
# DESCRIÇÃO: Colocar aqui a descrição da Norma
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     23/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=10
CRITICO=false
EXECUTANDO_IN="IN10"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Desabilitar Zeroconf"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    cp -p /etc/sysconfig/network $RESTOREPOINT_DIR/network.IN10 &&
    cp -p /etc/sysconfig/network $TEMP_DIR/network &&
    echo 'NOZEROCONF=yes' >> /etc/sysconfig/network
    evaluate_return_code $?
}

function do_rollback()
{
    echo "[+] $EXECUTANDO_IN - ROLLBACK"
    linha=$(grep -n 'NOZEROCONF=yes' /etc/sysconfig/network | cut -d: -f1)
    evaluate_return_code ${PIPESTATUS[@]}
    cp -p /etc/sysconfig/network $TEMP_DIR/network &&
    sed "${linha}d" $TEMP_DIR/network > /etc/sysconfig/network
    evaluate_return_code $?
}


# Main
if [[ $TIPO_DE_EXECUCAO -eq 1 ]]; then
    do_config
else
    do_rollback
fi

