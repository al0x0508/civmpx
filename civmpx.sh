#!/bin/bash

ERROR=$(echo -e "[\033[31m*\033[0m]")
WARN=$(echo -e "[\033[33m*\033[0m]")
SUCCESS=$(echo -e "[\033[32m*\033[0m]")
INFO=$(echo -e "[*]")

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

apt-get update -qq 2> /dev/null
# Check if cloud-init is installed
echo "$INFO Check if cloud-init is installed"
if [ -x "$(command -v cloud-init)" ]; then
    echo "$WARN cloud-init not installed, trying to install"
    apt-get update -qq 2> /dev/null
fi

