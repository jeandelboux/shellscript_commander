#!/bin/bash
#
# DESCRIÇÃO: Script de implementação da IN 00-00-00 publicada em dd/mm/aaaa
#            Segurança para Sistemas Operacionais Linux/Unix
# 
# VERSAO  DATA        AUTOR                DESCRICAO
# 0.1     21/11/2011  Jean D'Elboux Diogo  Criação do script
# 0.2     16/12/2011  Jean D'Elboux Diogo  Revisão de código, correções e
#                                          desenvolvimento de novas features
# 0.3     26/12/2011  Jean D'Elboux Diogo  Adicionei mais features; bug corri-
#                                          gido: todos erros dos STEP=0 nao
#                                          podem ser ignorados com a opcao -f
# 0.4     20/01/2012  Jean D'Elboux Diogo  Criação de diretórios através de
#                                          variaveis globais e parametrizadas
# 0.5     22/01/2012  Jean D'Elboux Diogo  Criação de diretórios temporários e
#                                          lógica para detectar jobs executados
#                                          com erro critico e não crítico
# 0.6     22/01/2012  Jean D'Elboux Diogo  Adicionado o modo manual de rollback
# 0.7     23/01/2012  Jean D'Elboux Diogo  Criação do --restore-dir e integrado
#                                          com --manual-rollback
# 0.8     27/01/2012  Jean D'Elboux Diogo  Retorno=77 significa fazer rollback
#                                          Retorno=1 significa nada foi exec.
#                                          Retorno=33 significa que se foi
#                                          usado -m -r então deve-se usar -d tb
#
##############################################################################

export INSTALLATION_DIR="/hardening" #Configurar esse diretorio antes de executar!

export SCRIPTS_PATH=${INSTALLATION_DIR}/scripts.d
export SCRIPTS_NORMAS=${SCRIPTS_PATH}/normas
export TEMP_DIR=${INSTALLATION_DIR}/tmp
export RESTOREPOINT_DIR=${INSTALLATION_DIR}/restorepoint/$(date '+%Y%m%d_%H%M')
export STEPS_CRITICOS_FALHADOS=${TEMP_DIR}/crit_faileds.tmp
export STEPS_NAO_CRITICOS_FALHADOS=${TEMP_DIR}/notcrit_faileds.tmp
export IGNORE_ERROS_NESSES_STEPS=${TEMP_DIR}/ignore_erros.tmp
export PROCESS_NAME="$0"
export PARAMETERS="$@"
if [[ x${EXEC_ROLLBACK}x = xx ]]; then
    export EXEC_ROLLBACK=false
fi
export EXECUTANDO_IN="IN0"
export STEP=0
export LISTA_DE_JOBS=
export LISTA_DE_JOBS_EXECUTADOS=""

{ unalias cp
  unalias rm
  unalias mv
  unalias ls
} 2>/dev/null

source ${SCRIPTS_PATH}/common_functions.sh

echo "*** Iniciando shell script de Hardening de Red Hat Enterprise 5.3/5.4" 

# Faz a leitura dos parametros passados para o script
echo "[+] Processando parametros passados para o script"
for i in $(seq 1 1 $#); do
    CMD=$(eval echo \$$i)
    ARG=$(eval echo \$$(expr $i + 1))
    if [[ $CMD = "-r" ]] || [[ $CMD = "--rollback" ]]; then
        export EXEC_ROLLBACK=true
    fi
    if [[ $CMD = "-m" ]] || [[ $CMD = "--manual-rollback" ]]; then
        export MANUAL_ROLLBACK=true
        manual_rollback_flag=true
    fi
    if [[ $CMD = "-d" ]] || [[ $CMD = "--restore-dir" ]]; then
        export RESTOREPOINT_DIR=$ARG
        restore_dir_flag=true
    fi
    if [[ $CMD = "-f" ]] || [[ $CMD = "--force" ]]; then
        export IGNORE_ERROS_NESSES_STEPS="$ARG"
    fi
    if [[ $CMD = "-j" ]] || [[ $CMD = "--jobs" ]]; then
        export LISTA_DE_JOBS=$(echo $ARG | sed -e 's/^,//' -e 's/,/ /g')
    fi
done
if [[ ${manual_rollback_flag} = true ]] && 
   [[ ${EXEC_ROLLBACK} = true ]] &&
   [[ ! ${restore_dir_flag} = true ]]; then
    echo "Se você usou --manual-rollback e --rollback entao deve usar tambem --restore-dir"
    exit 33
fi
#if [[ ${manual_rollback_flag} = true ]] && 
#   [[ ${EXEC_ROLLBACK} = true ]] &&
#   [[ ${restore_dir_flag} = true ]]; then
#    extra_parameters=""
#fi

# Cria diretorio temporario caso não exista
EXECUTANDO_IN="START-0"
STEP=0
CRITICO=true
echo "[+] Criando diretorio temporario"
if [[ ! -d $TEMP_DIR ]]; then
    mkdir -p $TEMP_DIR
    evaluate_return_code $?
fi


# Enumera os scripts do diretório
EXECUTANDO_IN="START-1"
STEP=0
CRITICO=true
echo "[+] Construindo a lista de normas a serem executadas"
if [[ -z $LISTA_DE_JOBS ]]; then
    LISTA_DE_JOBS=$(cd ${SCRIPTS_NORMAS} && ls *.sh | sort -r)
    evaluate_return_code ${PIPESTATUS[@]}
    for crap in $LISTA_DE_JOBS; do
        if [[ -x ${SCRIPTS_NORMAS}/${crap} ]]; then
            JOBS="${crap} ${JOBS}"
        fi
    done
    LISTA_DE_JOBS="${JOBS}"
    unset JOBS
fi

# Verifica se é execução de rollback ou configuração
EXECUTANDO_IN="START-2"
STEP=0
CRITICO=true
echo "[+] Verificando se é execucao de rollback ou configuracao"
if [[ $EXEC_ROLLBACK = true ]]; then
    echo -n "[+] INICIANDO ROLLBACK EM..."
    delay 20 ; echo
    echo "[+] LISTA DE JOBS A SEREM EXECUTADOS NO ROLLBACK = $LISTA_DE_JOBS"
    for job in $LISTA_DE_JOBS; do
        ${SCRIPTS_NORMAS}/${job} 0
    done
    echo hooooo
    clean_up -v
    echo haaaaa
    exit 0
    echo hiiiiii
fi


# Cria os diretórios de restauração para um eventual rollback
EXECUTANDO_IN="START-3"
STEP=0
CRITICO=true
echo "[+] Criando ponto de restauracao"
if [[ ! -d ${RESTOREPOINT_DIR} ]]; then
    mkdir -p ${RESTOREPOINT_DIR}
    evaluate_return_code $?
fi


# Executa os scripts enumerados anteriormente
echo "[+] Executando scripts..."
echo
for job in $LISTA_DE_JOBS; do
    if [[ -x ${SCRIPTS_NORMAS}/${job} ]]; then
        LISTA_DE_JOBS_EXECUTADOS=${LISTA_DE_JOBS_EXECUTADOS},${job}
        ${SCRIPTS_NORMAS}/${job} 1
        if [[ $? -eq 77 ]] && [[ ! $MANUAL_ROLLBACK = true ]]; then
            # retorno 77 significa que temos que fazer um rollback pq deu pau
            #export EXEC_ROLLBACK=true
            source ${INSTALLATION_DIR}/startjob.sh ${PROCESS_NAME} --jobs ${LISTA_DE_JOBS_EXECUTADOS} --rollback
            exit $?
        fi
        foi_executado_alguma_coisa=sim
    fi
done


# Finalizando o Hardening
EXECUTANDO_IN="END"
STEP=0
CRITICO=false
echo
echo "Relatorio de execucao:"
if [[ $foi_executado_alguma_coisa = sim ]]; then
echo ho
    cf=$(cat ${STEPS_CRITICOS_FALHADOS} | sort -u)
    ncf=$(cat $STEPS_NAO_CRITICOS_FALHADOS | sort -u)
echo ha
    echo "STEPS CRITICOS FALHADOS:" $cf
    echo "STEPS NAO CRITICOS FALHADOS:" $ncf
    clean_up -v
    rc=0
else
    echo "[nenhum job foi executado]"
    rc=1
fi
echo "Fim do Hardening para RedHat Linux"

exit $rc

