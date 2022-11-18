#!/bin/bash
printUsage () {
    echo "Simple script to generate the contents of the \"u2f_mappings\" file."
    echo "This script automates the use of the pamu2fcfg tool. For this reason, you want the lastest version of pamu2fcfg, I wrote this script using pamu2fcfg version 1.2.1"
    echo "Usage:"
    echo "   $0 <username>"
    echo "   $0 <username> <hostname>"
    echo "   $0 <username> <hostname> <algorithm>"
    echo "   $0 <username> <hostname> <algorithm> <output filename>"
    echo "Defaults:"
    echo "   $0 $USER $HOSTNAME $HOSTNAME EDDSA $PWD/u2f_mappings"
    echo "Algorithms:"
    echo "   EDDSA - EDDSA authentication using Curve25519 keys - you should usually prefer this one"
    echo "   ES256 - ECDSA authentication using curve P-256 keys (NIST curve)"
    #echo "   RS256 - RSA based authentication"
    echo "Note that the origin and appid strings are part of the U2F standard, in most cases you can and should set them both to your system's hostname ($HOSTNAME)."
    exit
}

if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then
    printUsage
fi

#set defaults values
#use control operators to make lines readable
[[ ! -z "$1" ]] && user="$1" || user="$USER" #use the current user's username if first arg is blank
[[ ! -z "$2" ]] && origin="$2" || origin="$HOSTNAME" #use the current system hostname
appid="$origin" #set them the same
[[ ! -z "$3" ]] && algo="$3" || algo="EDDSA" #use Ed25519 by default
[[ ! -z "$4" ]] && filename="$4" || filename="$PWD/u2f_mappings"

contents="$user" # store the output here, start with the username and append just th U2F key data
thiskey="" #store next U2F device, this allows for removing the last device if added by mistake
response="" #this tells us when we are done or to start a new user
totalkeys=0

echo "Starting new session."
echo "Options:"
echo "   Username:    $user"
echo "   Origin:      $origin"
echo "   AppID:       $appid"
echo "   Algorithm:   $algo"
echo "   Config file: $filename"
echo ""
echo "Ensure only the U2F device you want to enroll is connected, then press enter."
echo "Type \"done\" to exit, appending our configuration to the configuration file."
echo "Type \"abort\" to exit without appending our configuration to the config file."
echo "Type \"algo\" to change the algorithm pamu2fcfg will enroll"
echo "    If \"FIDO_ERR_INVALID_ARGUMENT\" or \"FIDO_ERR_UNSUPPORTED_ALGORITHM\" appear"
echo "        then try changing the algorithm for that U2F device."
echo "        Not all U2F devices can use all algorithms."

while [[ $response != "done" ]] && [[ $response != "abort" ]]; do
    echo "Total keys to enroll: $totalkeys"
    echo "Connect only to U2F device you want to enroll, and press enter."
    read response
    if [[ $response = "algo" ]] || [[ $response = "algorithm" ]]; then 
        echo "Changing algorithm to:"
        echo "    EDDSA"
        echo "    ES256"
        echo "    RS256"
        echo "    Any other algorithm your pamu2fcfg supports"
        echo "Choose one of the above algorithms."
        echo ""
        read algo
        if [[ $algo = "" ]]; then
            algo="EDDSA"
            echo "Defaulting to EDDSA since nothing was provided."
        fi
    elif [[ $response = "" ]]; then
        thiskey=$( pamu2fcfg -u$user -ipam://$appid -opam://$origin --type=$algo -n )
        if [[ ! -z "$thiskey" ]]; then
            totalkeys=$(($totalkeys+1)) #count up if key an entry was obtained
            contents="$contents$thiskey" #append current key to the total key string
        else
            echo "Something went wrong and pamu2fcfg did not give us an entry."
            echo "Try changing algorithms for this U2F device if issues persist."
        fi
    else
     echo "Unknown option"
    fi
done

if [[ $response != "abort" ]]; then #only the abort option stops the saving of the config file
    echo "Saving $totalkeys U2F device entries as enrolled for $user"
    echo "$contents" >> $filename
fi
