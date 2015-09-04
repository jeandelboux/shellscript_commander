#!/bin/bash
#
# DESCRIÇÃO: Colocar aqui a descrição da Norma
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     23/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=11
CRITICO=false
EXECUTANDO_IN="IN11"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Permitir login root somente de um unico terminal"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    f=/etc/ssh/sshd_config
    n=$(grep -n '^PermitRootLogin \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    n=$(grep -n '^AllowTcpForwarding \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    n=$(grep -n '^X11Forwarding \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    n=$(grep -n '^StrictModes \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    n=$(grep -n '^IgnoreRhosts \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    n=$(grep -n '^HostbasedAuthentication \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    n=$(grep -n '^RhostsRSAAuthentication \(yes\|no\)' $f) && sed "${n}d" $f > $TEMP_DIR/sshd_config
    cp -p /etc/sysconfig/network $RESTOREPOINT_DIR/network.IN10 &&
    cp -p /etc/sysconfig/network $TEMP_DIR/network &&
    echo 'NOZEROCONF=yes' >> /etc/sysconfig/network
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

