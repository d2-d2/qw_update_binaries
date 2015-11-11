#!/bin/sh

################################################### CONFIGURATION STARTS HERE
# directory to store GIT sources
SRCROOTDIR=/home/users/quake/src/_official
# full path(s) to mvdsv binary currently installed in your system
LOC_MVDSV="/home/users/quake/q1/mvdsv"
# full path(s) to ktx binary currently installed in your system
LOC_KTX="/home/users/quake/q1/ktx/qwprogs.so /home/users/quake/q1/ffa/qwprogs.so"
# full path to mvdparser binary currently installed in your system
LOC_MVDPARSER=
# full path to qtv binary currently installed in your system
LOC_QTV=
# full path to qwfwd binary currently installed in your system
LOC_QWFWD=
# automatically update sources?
AUTOUPDATE=no
# debug: 0=no, anything else=yes
DEBUG=0
################################################### CONFIGURATION END HERE - DO NOT MODIFY ANYTHING BELOW THIS LINE

b_update_locations() {
    if [ ${AUTOUPDATE} = "yes" ]; then
        printf "\t[i] updatng binaries\n" | tee -a ${LOGFILE}
        val=LOC_$(b_upper ${PROJECT})
        vval=$(eval "echo \$$val")
        for binarylocation in ${vval}; do
            if [ ! -e ${binarylocation} ]; then
                printf "\t\t[-] \"${binary}\" binary does not exists under \"${binarylocation}\" location, unable to update it. Please verify \"${val}\" variable\n" | tee -a ${LOGFILE}
            else
                printf "\t\t[+] updating \"${binarylocation}\"\n" | tee -a ${LOGFILE}
                DNOW=$(date +%Y-%m-%d@%H%M%S)
                printf "\t\t\t[+] creating backup copy: ${binarylocation}_${DNOW}\n" | tee -a ${LOGFILE}
                cp -pr ${binarylocation} ${binarylocation}_${DNOW}
                cp -pr ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}/${binary} ${binarylocation}
                chmod 755 ${binarylocation}
            fi
        done
        printf "\t\t[i] done, remember to restart \"${PROJECT}\"\n" | tee -a ${LOGFILE}
        b_end
    else
        printf "\t[i] automatic updates are disabled, please copy new binaries manually\n" | tee -a ${LOGFILE}
        b_end
    fi
}

b_start() {
    echo "#### START: $(date +%Y-%m-%d@%H%M%S) ####" | tee -a ${LOGFILE}
}

b_end() {
    echo "#### END: $(date +%Y-%m-%d@%H%M%S) ####" | tee -a ${LOGFILE}
}

b_upper() {
    echo ${1} | tr "[a-z]" "[A-Z]"
}

b_check_status() {
    if [ ${?} = 0 ]; then
        printf "\t\t[+] OK\n" | tee -a ${LOGFILE}
    else
        printf "\t\t[-] operation failed\n" | tee -a ${LOGFILE}
        b_end
        exit 1
    fi
}

b_git_update() {
    if [ ! -e ${SRCROOTDIR}/${PROJECT} ]; then
        printf "\t[-] unable to find proper \"${PROJECT}\" sources, trying git clone https://github.com/deurk/${PROJECT}\n" | tee -a ${LOGFILE}
        b_run git clone ${GITOPTIONS} https://github.com/deurk/${PROJECT} 2>&1 >> ${LOGFILE}
        b_check_status
    else
        printf "\t[+] trying to update sources first\n" | tee -a ${LOGFILE}
        cd ${SRCROOTDIR}/${PROJECT}
        b_run git pull ${GITOPTIONS} 2>&1 >> ${LOGFILE}
        b_check_status
    fi
}

b_run() {
    if [ ${DEBUG} -ne 0 ]; then
        n_cmd=$(exec 2>&1 && set -x && set -- "$@")
        echo "#### DEBUG: executing ->${n_cmd#*--} ####" 2>&1 >> ${LOGFILE}
        "$@" 2>&1 >> ${LOGFILE}
    else
        GITOPTIONS=" --quiet "
        GCCOPTIONS=" --quiet "
        CFGOPTIONS=" > /dev/null 2>&1 "
        "$@" >/dev/null 2>&1
    fi
}

b_project() {
    printf "[i] working on \"${PROJECT}\" project\n" | tee -a ${LOGFILE}
    b_git_update
    if [ -e ${SRCROOTDIR}/${PROJECT}/build/make ]; then
        cd ${SRCROOTDIR}/${PROJECT}/build/make
    else
        cd ${SRCROOTDIR}/${PROJECT}
    fi
    b_run make ${GCCOPTIONS} clean 2>&1 >> ${LOGFILE}
    if [ ! -e ${SRCROOTDIR}/${PROJECT}/${BINARYDIR} ]; then
        printf "\t\t[i] creating \"${SRCROOTDIR}/${PROJECT}/${BINARYDIR}\" directory\n" | tee -a ${LOGFILE}
        mkdir -p ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}
    fi
    if [ -e ./configure ]; then
        printf "\t[+] configure\n" | tee -a ${LOGFILE}
        b_run ./configure 2>&1 >> ${LOGFILE}
        b_check_status
    fi
    printf "\t[+] make\n" | tee -a ${LOGFILE}
    b_run make ${GCCOPTIONS} 2>&1 >> ${LOGFILE}
    b_check_status
    if [ -e ${SRCROOTDIR}/${PROJECT}/build/make/${binary} ]; then
        mv ${SRCROOTDIR}/${PROJECT}/build/make/${binary} ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}/
    elif [ -e ${SRCROOTDIR}/${PROJECT}/${binary} ]; then
        mv ${SRCROOTDIR}/${PROJECT}/${binary} ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}/
    else
        printf "\t[-] unable to find \"${binary}\" (checked ${SRCROOTDIR}/${PROJECT}/build/make/${binary} and ${SRCROOTDIR}/${PROJECT}/${binary})\n" | tee -a ${LOGFILE}
        b_end
        exit 1
    fi
    printf "\t[i] done, \"${binary}\" should be available under \"${SRCROOTDIR}/${PROJECT}/${BINARYDIR}\" directory\n" | tee -a ${LOGFILE}
}

b_root() {
    if [ $(whoami) = root ]; then
        printf "[i] please do not run this script as root\n" | tee -a ${LOGFILE}
        b_end
        exit 1
    fi
}

# project name to compile
PROJECT=${1}
# destination directory created under each project
BINARYDIR=binaries
# logfile for debugging purposes
if [ ${DEBUG} -ne 0 ]]; then
    rm /tmp/${PROJECT}_debug.log > /dev/null 2>&1
    LOGFILE=/tmp/${PROJECT}_debug.log
else
    LOGFILE=/dev/null
fi

b_start

if [ ! -e ${SRCROOTDIR} ]; then
    printf "[-] unable to find ${SRCROOTDIR}. Create one (mkdir ${SRCROOTDIR}) and launch this script again\n" | tee -a ${LOGFILE}
    b_end
    exit 1
fi

if [ $(which git > /dev/null 2>&1; echo ${?}) -ne 0 ]; then
    printf "[-] unable to find git binaries, this is required. Please install it (Debian: sudo apt-get install git)\n" | tee -a ${LOGFILE}
    b_end
    exit 1
fi

b_root

case ${PROJECT} in
    ktx)        binary=qwprogs.so
                b_project
                b_update_locations
                ;;
    mvdparser)  binary=mvdparser
                b_project
                b_update_locations
                ;;
    mvdsv)      binary=mvdsv
                b_project
                b_update_locations
                ;;
    qtv)        binary=qtv.bin
                b_project
                b_update_locations
                ;;
    qwfwd)      binary=qwfwd.bin
                b_project
                b_update_locations
                ;;
    *)          printf "[-] usage: $(basename ${0}) [ktx|mvdparser|mvdsv|qtv|qwfwd]\n\nthis script is using Deurk sources (https://github.com/deurk/)\n" | tee -a ${LOGFILE}
                exit 1
                ;;
esac