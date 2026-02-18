#!/bin/bash

INT=$1

if [ -z $INT ]; then
  printf "No interface specified, using: "
  INT=`ip route | grep ^default | awk '{print $5}' | head -1` #first default route interface
  if [ -z $INT ]; then
    INTS=`cat /proc/net/dev | tail -n +3 | awk -F: '{print $1}' | sed -e 's/\ //g' | tr '\n' ' '`
    printf "Could not determine default gateway, please specific an interface: $INTS"
    exit
  fi
  INTS=`cat /proc/net/dev | tail -n +3 | awk -F: '{print $1}' | sed -e 's/\ //g' | tr '\n' ' ' | sed -e "s/$INT //g"`
  printf "\033[0;35m$INT\033[m \033[1;35m[ $INTS]\033[m\n";
else
  INTS=`cat /proc/net/dev | tail -n +3 | awk -F: '{print $1}' | sed -e 's/\ //g' | tr '\n' ' ' | sed -e "s/$INT //g"`
  printf "Using interface: \033[0;35m$INT\033[m \033[1;35m[ $INTS]\033[m\n"
fi

BYTES=`cat /proc/net/dev | grep -w $INT: | awk '{print $2,$10}'`
RX=`echo $BYTES | awk '{print $1}'`
TX=`echo $BYTES | awk '{print $2}'`
printf "\rWaiting for first stats"

function get_bytes {
        OLDRX=$1
        OLDTX=$2
        for (( x=1; x<=2; x++ )); do
          printf "."
          sleep 1
        done
        printf "3"
        sleep 1
        printf "\b2"
        sleep 1
        printf "\b1"
        sleep 1
        printf "\b\b\b       "
        BYTES=`cat /proc/net/dev | grep -w $INT: | awk '{print $2,$10}'`
        RX=`echo $BYTES | awk '{print $1}'`
        TX=`echo $BYTES | awk '{print $2}'`
        if [ `expr $RX - $OLDRX` -lt 655360 ]; then
          RXBYTES=`echo $RX $OLDRX | awk '{printf "%.2f", ($1 - $2) * 8 / 1024 / 1024 / 5}'`
          RSCALE="kbps"
        else 
          RXBYTES=`echo $RX $OLDRX | awk '{printf "%.2f", ($1 - $2) * 8 / 1024 / 1024 / 5}'`
          RSCALE="mbps"
        fi
        if [ `expr $TX - $OLDTX` -lt 655360 ]; then
          TXBYTES=`echo $TX $OLDTX | awk '{printf "%.2f", ($1 - $2) * 8 / 1024 / 1024 / 5}'`
          TSCALE="kbps"
        else 
          TXBYTES=`echo $TX $OLDTX | awk '{printf "%.2f", ($1 - $2) * 8 / 1024 / 1024 / 5}'`
          TSCALE="mbps"
        fi
        RXBYTES=`printf "%03.2f" $RXBYTES;`
        TXBYTES=`printf "%03.2f" $TXBYTES;`
        printf "\r[\033[0;35m$INT\033[m] `date '+%H:%M:%S %Z %m/%d/%Y'` IN: \033[0;36m$RXBYTES\033[m $RSCALE OUT: \033[0;32m$TXBYTES\033[m $TSCALE"
        get_bytes $RX $TX
}

get_bytes $RX $TX
