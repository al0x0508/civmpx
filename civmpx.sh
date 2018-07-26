#!/bin/bash

ERROR=$(echo -e "[\033[31m*\033[0m]")
WARN=$(echo -e "[\033[33m*\033[0m]")
SUCCESS=$(echo -e "[\033[32m*\033[0m]")
INFO=$(echo -e "[*]")

# Default VM properties
CORES="1" # (1 - N) (default = 1)
SOCKETS="1" # (1 - N) (default = 1)
MEMORY="2048" # (16 - N) (default = 512)
NET0="virtio,bridge=vmbr2" # [model=]<enum> [,bridge=<bridge>] [,firewall=<1|0>] [,link_down=<1|0>] [,macaddr=<XX:XX:XX:XX:XX:XX>] [,queues=<integer>] [,rate=<number>] [,tag=<integer>] [,trunks=<vlanid[;vlanid...]>] [,<model>=<macaddr>]
STORAGE="local"
#IDE2="$STORAGE:cloudinit"
#BOOTDISK="scsi0" # (ide|sata|scsi|virtio)

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
    			error_exit "vmid is missing or not an integer"
            fi
            if [ "$vmid" -lt "100" ]; then
                error_exit "Please provide vmid greater than 100"
            fi
            ;;
        p)
            imagepath=${OPTARG}
            if [ ! -f "$imagepath" ]; then
                error_exit "$imagepath not found"
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
    echo "$SUCCESS OK"
fi

# Create VM
echo "$INFO Creating VM"
qm create $vmid --cores $CORES --sockets $SOCKETS --memory $MEMORY --net0 $NET0 &> /dev/null && echo "$SUCCESS OK" || error_exit "Failed to create VM. Aborting"

# Import image to storage
echo "Importing image to VM storage"
qm importdisk $vmid $imagepath $STORAGE &> /dev/null && echo "$SUCCESS OK" || error_exit "Failed to import storage. Aborting.."


