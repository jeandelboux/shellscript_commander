#!/bin/bash
#
# DESCRIÇÃO: Colocar aqui a descrição da Norma
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     21/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=5
CRITICO=true
EXECUTANDO_IN="IN5"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Desabilitando servicos desnecessarios"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    chkconfig --level 12345 apmd off &&
    chkconfig --level 12345 autofs off &&
    chkconfig --level 12345 avahi-daemon off &&
    chkconfig --level 12345 avahi-dnsconfd off &&
    chkconfig --level 12345 bluetooth off &&
    chkconfig --level 12345 conman off &&
    chkconfig --level 12345 cpuspeed off &&
    chkconfig --level 12345 cups off &&
    chkconfig --level 12345 dund off &&
    chkconfig --level 12345 firstboot off &&
    chkconfig --level 12345 gpm off &&
    chkconfig --level 12345 haldaemon off &&
    chkconfig --level 12345 hidd off &&
    chkconfig --level 12345 ip6tables off &&
    chkconfig --level 12345 irda off &&
    chkconfig --level 12345 irqbalance off &&
    chkconfig --level 12345 kudzu off &&
    chkconfig --level 12345 mcstrans off &&
    chkconfig --level 12345 mdmonitor off &&
    chkconfig --level 12345 microcode_ctl off &&
    chkconfig --level 12345 netfs off &&
    chkconfig --level 12345 netplugd off &&
    chkconfig --level 12345 NetworkManager off &&
    chkconfig --level 12345 nfs off &&
    chkconfig --level 12345 nfslock off &&
    chkconfig --level 12345 nscd off &&
    chkconfig --level 12345 pand off &&
    chkconfig --level 12345 pcscd off &&
    chkconfig --level 12345 portmap off &&
    chkconfig --level 12345 rdisc off &&
    chkconfig --level 12345 restorecond off &&
    chkconfig --level 12345 rpcgssd off &&
    chkconfig --level 12345 rpcidmapd off &&
    chkconfig --level 12345 rpcsvcgssd off &&
    chkconfig --level 12345 saslauthd off &&
    chkconfig --level 12345 smartd off &&
    chkconfig --level 12345 wpa_supplicant off &&
    chkconfig --level 12345 ypbind off &&
    chkconfig --level 12345 yum-updatesd off
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

