#!/bin/bash

ERROR=$(echo -e "[\033[31m*\033[0m]")
WARN=$(echo -e "[\033[33m*\033[0m]")
SUCCESS=$(echo -e "[\033[32m*\033[0m]")
INFO=$(echo -e "[*]")

function error_exit {
    echo "$1" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
    exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

function help(){
    echo "civmpx - Create VM from cloud images on Proxmox";
    echo "Usage example:";
    echo "civmpx [-h] -i 9000 -p /path/to/img";
    echo "Options:";
    echo "-h : Displays this information.";
    echo "-i : Virtual machine identifier. Required.";
    echo "-p : Path to the cloud image file. Required.";
    exit 1;
}

# If no options provided, show help
if [ $# -eq 0 ];
then
    help
    exit 0
fi

# Parse options and args
while getopts ":i:p:" option; do
    case "${option}" in
        i)
            vmid=${OPTARG}
            if ! [ "$vmid" -eq "$vmid" ] 2> /dev/null; then
    			echo "vmid is missing or not an integer"
			fi
            ;;
        p)
            imagepath=${OPTARG}
            if [ ! -f "$imagepath" ]; then
                echo "$imagepath not found"
            fi
            ;;
        *)
            help
            ;;
        /?)
            help
            ;;
    esac
done

# Check if cloud-init is installed
echo "$INFO Check if cloud-init is installed"
if [ ! -x "$(command -v cloud-init)" ]; then
    echo "$WARN Not installed, trying to install"
    apt-get update -qq 2> /dev/null
    apt install -qq -y cloud-init 2> /dev/null
    if [ ! -x "$(command -v cloud-init)" ]; then
      echo "$ERROR Failed to install cloud-init. Aborting.."
      exit 1
    fi
else
    echo "$SUCCESS Ok"
fi

# Create VM
echo "$INFO Creating VM"
qm create $vmid && echo "$SUCCESS Ok" || error_exit "Failed to create VM"

