#!/bin/bash
#
# DESCRIÇÃO: Políticas de senhas devem estar conforme a norma de senhas e autenticação
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     19/01/2012  Jean D'Elboux Diogo  Criação do script
#
##############################################################################

STEP=1
CRITICO=true
EXECUTANDO_IN="IN1"
TIPO_DE_EXECUCAO=$1
DESCRICAO="Alterando a senha de root"

source ${SCRIPTS_PATH}/common_functions.sh

function do_config()
{
    echo "[+] $EXECUTANDO_IN - $DESCRICAO"
    echo "Gerando nova senha..."
    newpasswd=$(head -5 /dev/urandom | base64 | tail -3 | head -1 | cut -c1-8)
    evaluate_return_code ${PIPESTATUS[@]}
    echo "Favor anotar o passwd abaixo e pressionar uma tecla para continuar"
    echo "Novo password para root: ${newpasswd}"
    read
    echo "Alterando a senha de root..."
    echo -e "${newpasswd}\n${newpasswd}" | passwd </dev/stdin
    evaluate_return_code ${PIPESTATUS[@]} &&
    echo "Password atualizado com sucesso"
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

