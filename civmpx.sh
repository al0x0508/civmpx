#!/bin/bash

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

while getopts ":i:p:" option; do
    case "${option}" in
        i)
            vmid=${OPTARG}
            if ! [ "$vmid" -eq "$vmid" ] 2> /dev/null; then
    			echo "vmid is missing or wrong type"
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
    esac
done
