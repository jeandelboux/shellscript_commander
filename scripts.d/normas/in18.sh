#!/bin/bash
#
# DESCRIÇÃO: 
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     20/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=18
CRITICO=true
EXECUTANDO_IN="IN18"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Apenas usuarios administradores tevem ter shell valido"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    cp -p /etc/passwd $TEMP_DIR/passwd.IN18 &&
    awk 'BEGIN { FS=":" ; OFS=":" } {
        if ($3==0)
            $7="/bin/bash";
        else $7="/sbin/nologin";
        print $0;
    }' /etc/passwd > $TEMP_DIR/passwd.IN18 &&
    mv $TEMP_DIR/passwd.IN18 /etc/passwd
    evaluate_return_code $?
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

