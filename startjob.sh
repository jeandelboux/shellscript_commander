#!/bin/bash
#
# DESCRIÇÃO: Wrapper para execução de scripts de hardening
#
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     03/01/2012  Jean D'Elboux Diogo  Criação do script
# 0.2     22/01/2012  Jean D'Elboux Diogo  Adicionei feature de log
#
##############################################################################

JOB_LOG_DIR=/var/log/hardening
JOB_LOG_NAME=hardening_$(date '+%Y%m%d_%H%M').log

function usage()
{
    echo "usage: $0 [jobname] [parameters]"
}

# Main

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

if [[ $(basename $1) = $1 ]]; then
    JOBNAME=./$1
else
    JOBNAME=$1
fi

ls $JOBNAME 2>&1 1>&/dev/null
if [[ $? -ne 0 ]]; then
    echo "Job name \"$JOBNAME\" not found"
    usage
    exit 1
fi

file $JOBNAME | grep -i "shell script" 2>&1 1>&/dev/null
if [[ $? -ne 0 ]]; then #somente o resultado do último comando interessa
    echo "Este wrapper deve ser usado apenas para execucao de scripts de hardening"
    usage
    exit 1
fi

touch $JOB_LOG_DIR/$JOB_LOG_NAME 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "Nao foi possivel criar o log em $JOB_LOG_DIR/$JOB_LOG_NAME"
    echo "Verifique se o diretorio base de log $JOB_LOG_DIR existe"
    exit 1
fi

echo "Logging in $JOB_LOG_DIR/$JOB_LOG_NAME"
echo "Starting $JOBNAME"

shift
echo

# finally...
$JOBNAME $@ 2>&1 | tee -a $JOB_LOG_DIR/$JOB_LOG_NAME

