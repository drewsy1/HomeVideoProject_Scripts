#!/bin/bash
#
# dvd2iso - A script to create an ISO image of a physical DVD along with a .sha1 file containing the DVD's checksum.

##### Functions

usage()
{
    echo "usage: dvd2iso -if file -od directory [-n name] | [-h]"
}


##### Main

discdrive_device=/dev/sr0
dvdname=
output_directory=~/Videos
output_iso=
output_sha1=

if [ "$1" != "" ]; then
    while [ "$1" != "" ]; do
        case $1 in
            -if | --input_file )    	shift
                                    	discdrive_device=$1
                                    	;;
            -od | --output_directory )	shift
    									output_directory=$1
                                    	;;
        	-n | --name )		    	shift
                                    	dvdname=$1
                                    	;;
            -h | --help )           	usage
                                    	exit
                                    	;;
            * )                     	usage
                                    	exit 1
        esac
        shift
    done

    if [ "$dvdname" == ""]; then
    	dvdname=$(sudo blkid -o value -s LABEL $discdrive_device)
    fi

    output_iso="$output_directory/$dvdname.iso"
    output_sha1="$output_directory/$dvdname.iso.sha1"

    dd if=$discdrive_device bs=2048 | tee $output_iso | sha1sum > $output_sha1
    sed -i "s/\-/$dvdname.iso/" "$output_sha1"

else
    usage
    exit 1
fi