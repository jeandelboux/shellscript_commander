#!/bin/bash
#
# DESCRIÇÃO: Módulo de funções para shell scripts.
#            Compatível com /bin/bash
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     16/12/2011  Jean D'Elboux Diogo  Criação do script
# 0.2     07/01/2012  Jean D'Elboux Diogo  Added delay() function and bugfixes
# 0.3     22/01/2012  Jean D'Elboux Diogo  Added check_ignore_errors_parameters
# 0.4     25/01/2012  Jean D'Elboux Diogo  Added clean_up() function and fixed
#                                          a incorrect behavior on the function
#                                          evaluate_return_code() function
# 0.5     27/01/2012  Jean D'Elboux Diogo  
#
##############################################################################


function evaluate_return_code()
{
    for return_code in $@; do
        if [[ ${return_code} -ne 0 ]]; then
            if [[ ${CRITICO} = "true" ]]; then
                echo ${EXECUTANDO_IN} >> ${STEPS_CRITICOS_FALHADOS}
                if $(check_ignore_errors_parameter $IGNORE_ERROS_NESSES_STEPS) ; then
                    #echo "Ignorando erro(s) critico(s) encontrado(s) na norma $EXECUTANDO_IN"
                    return
                fi
                echo
                echo -n "ERRO CRITICO NORMA=${EXECUTANDO_IN} - execucao abortada em 10 segundos: "
                delay 10
                echo
                if [[ ${MANUAL_ROLLBACK} = true ]]; then
                    cf=$(cat ${STEPS_CRITICOS_FALHADOS} | sort -u)
                    ncf=$(cat ${STEPS_NAO_CRITICOS_FALHADOS} | sort -u)
                    echo "STEPS CRITICOS FALHADOS:" $cf
                    echo "STEPS NAO CRITICOS FALHADOS:" $ncf
                    echo "Exiting $PPID"
                    clean_up -v
                    kill -9 $PPID
                    exit 200
                    echo NUNCA DEVE SER EXIBIDO
                else
                    echo "Reiniciando script no modo de rollback..."
                    return 77 #código 77 significa fazer rollback
                fi
            else
                #echo "WARNING norma=${EXECUTANDO_IN}"
                echo ${EXECUTANDO_IN} >> ${STEPS_NAO_CRITICOS_FALHADOS}
                return
            fi
        fi
    done
}


function check_ignore_errors_parameter()
{
    if [[ $STEP -eq 0 ]]; then
        return 1
    fi
    for passo in $(echo $1 | sed -e 's/^,//' -e 's/,/ /g'); do
        if [[ $passo -eq $STEP ]]; then
            return 0
        fi
    done
    return 1
}


function delay()
{
    for i in $(seq $1 -1 0); do
        echo -ne $i
        sleep 1
        if [[ $i -gt 9 ]]; then
            echo -ne "\x08\x08\x20\x20\x08\x08"
        else
            echo -ne "\x08"
        fi
    done
}


function clean_up()
{
    rm -f $1 ${STEPS_CRITICOS_FALHADOS}
    rm -f $1 ${STEPS_NAO_CRITICOS_FALHADOS}
    rm -rf $1 ${TEMP_DIR}
}


