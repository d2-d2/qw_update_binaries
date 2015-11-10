#!/bin/bash

############################## CONFIGURATION STARTS HERE
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
AUTOUPDATE=yes
# debug: 0=no, anything else=yes
DEBUG=0
############################## CONFIGURATION END HERE - DO NOT MODIFY ANYTHING BELOW THIS LINE

# project name to compile
PROJECT=${1}
# destination directory created under each project
BINARYDIR=binaries

function b_update_locations() {
    if [[ ${AUTOUPDATE} = "yes" ]]; then
        echo -e "\t[i] updatng binaries"
        val=LOC_$(b_upper ${PROJECT})
        vval=$(eval "echo \$$val")
        for binarylocation in ${vval}; do
            if [[ ! -e ${binarylocation} ]]; then
                echo -e "\t\t[-] \"${binary}\" binary does not exists under \"${binarylocation}\" location, unable to update it. Please verify \"${val}\" variable"
            else
                echo -e "\t\t[+] updating \"${binarylocation}\""
                DNOW=$(date +%Y-%m-%d@%H%M%S)
                echo -e "\t\t\t[+] creating backup copy: ${binarylocation}_${DNOW}"
                cp -pr ${binarylocation}{,_${DNOW}}
                cp -pr ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}/${binary} ${binarylocation}
                chmod 755 ${binarylocation}
            fi
        done
        echo -e "\t\t[i] done, remember to restart \"${PROJECT}\""
    else
        echo -e "\t[i] automatic updates are disabled, please copy new binaries manually"
    fi
}

function b_upper() {
    echo ${1} | tr "[a-z]" "[A-Z]"
}

function b_set_debug_options() {
    if [[ ${DEBUG} = 0 ]]; then
        GITOPTIONS=" --quiet "
        GCCOPTIONS=" --quiet "
        CFGOPTIONS=" > /dev/null 2>&1 "
    fi
}

function b_check_status() {
    if [[ ${?} = 0 ]]; then
        echo -e "\t\t[+] OK"
    else
        echo -e "\t\t[-] operation failed"
        exit 1
    fi
}

function b_git_update() {
    if [[ ! -e ${SRCROOTDIR}/${PROJECT} ]]; then
        echo -e "\t[-] unable to find proper \"${PROJECT}\" sources, trying git clone https://github.com/deurk/${PROJECT}"
        git clone ${GITOPTIONS} https://github.com/deurk/${PROJECT}
        b_check_status
    else
        echo -e "\t[+] trying to update sources first"
        cd ${SRCROOTDIR}/${PROJECT}
        git pull ${GITOPTIONS}
        b_check_status
    fi
}

function b_project() {
    echo -e "[i] working on \"${PROJECT}\" project"
    b_git_update
    if [[ -e ${SRCROOTDIR}/${PROJECT}/build/make ]]; then
        cd ${SRCROOTDIR}/${PROJECT}/build/make
    else
        cd ${SRCROOTDIR}/${PROJECT}
    fi
    $(eval make ${GCCOPTIONS} clean ${CFGOPTIONS})
    if [[ ! -e ${SRCROOTDIR}/${PROJECT}/${BINARYDIR} ]]; then
        echo -e "\t\t[i] \"creating ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}\" directory"
        mkdir -p ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}
    fi
    if [[ -e ./configure ]]; then
        echo -e "\t[+] configure"
        $(eval ./configure ${CFGOPTIONS})
        b_check_status
    fi
    echo -e "\t[+] make"
    $(eval make ${GCCOPTIONS} ${CFGOPTIONS})
    b_check_status
    if [[ -e ${SRCROOTDIR}/${PROJECT}/build/make/${binary} ]]; then
        mv ${SRCROOTDIR}/${PROJECT}/build/make/${binary} ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}/
    elif [[ -e ${SRCROOTDIR}/${PROJECT}/${binary} ]]; then
        mv ${SRCROOTDIR}/${PROJECT}/${binary} ${SRCROOTDIR}/${PROJECT}/${BINARYDIR}/
    else
        echo -e "\t[-] unable to find \"${binary}\" (checked ${SRCROOTDIR}/${PROJECT}/build/make/${binary} and ${SRCROOTDIR}/${PROJECT}/${binary})"
        exit 1
    fi
    echo -e "\t[i] done, \"${binary}\" should be available under \"${SRCROOTDIR}/${PROJECT}/${BINARYDIR}\" directory"
}

function b_root() {
    if [[ $(whoami) == root ]]; then
        echo -e "[i] please do not run this script as root"
        exit 1
    fi
}

if [[ ! -e ${SRCROOTDIR} ]]; then
    echo -e "[-] unable to find ${SRCROOTDIR}. Create one (mkdir ${SRCROOTDIR}) and launch this script again"
    exit 1
fi

if [[ $(which git) == "" ]]; then
    echo -e "[-] unable to find git binaries, this is required. Please install it (Debian: sudo apt-get install git)"
    exit 1
fi

b_root
b_set_debug_options

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
    *)          echo -e "[-] usage: $(basename ${0}) [ktx|mvdparser|mvdsv|qtv|qwfwd]\n\nthis script is using Deurk sources (https://github.com/deurk/)"
                exit 1
                ;;
esac