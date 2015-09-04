#!/bin/bash
#
# DESCRIÇÃO: 
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     20/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=15
CRITICO=true
EXECUTANDO_IN="IN15"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Desativar roteamento, dump de programas suid e ativar o exec shield"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    cp -p /etc/sysctl.conf $RESTOREPOINT_DIR/sysctl.conf.IN15 &&
    awk 'BEGIN {a=0; b=0; c=0; d=0; e=0; f=0} {
        if ($1=="net.ipv4.ip_forward") {
           $3=0;
           a=1;
        }
        if ($1=="net.ipv4.conf.all.send_redirects") {
           $3=0;
           b=1;
        }
        if ($1=="net.ipv4.conf.default.send_redirects") {
           $3=0;
           c=1;
        }
        if ($1=="fs.suid_dumpable") {
           $3=0;
           d=1;
        }
        if ($1=="kernel.exec-shield") {
           $3=1;
           e=1;
        }
        if ($1=="kernel.randomize_va_space") {
           $3=1;
           f=1;
        }
        print $0;
    } END {
        print "";
        if(!a) print "net.ipv4.ip_forward = 0";
        if(!b) print "net.ipv4.conf.all.send_redirects = 0";
        if(!c) print "net.ipv4.conf.default.send_redirects = 0";
        if(!d) print "fs.suid_dumpable = 0";
        if(!e) print "kernel.exec-shield = 1";
        if(!f) print "kernel.randomize_va_space = 1";
    }' $RESTOREPOINT_DIR/sysctl.conf.IN15 > /etc/sysctl.conf
    evaluate_return_code $?
}

function do_rollback()
{
    echo "[+] $EXECUTANDO_IN - ROLLBACK"
    cp -p $RESTOREPOINT_DIR/sysctl.conf.IN15 /etc/sysctl.conf
}


# Main

if [[ $TIPO_DE_EXECUCAO -eq 1 ]]; then
    do_config
else
    do_rollback
fi

