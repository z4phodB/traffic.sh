#!/bin/bash

INT=$1
if [ -z $INT ]; then
  printf "No interface specified, using: "
  INT=`ip route | grep ^default | awk '{print $5}' | head -1` #first default route interface
  printf "\033[1;35m$INT\033[m\n";
else
  printf "Using interface: \033[1;35m$INT\033[m\n"
fi

BYTES=`cat /proc/net/dev | grep $INT | awk '{print $2,$10}'`
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
        BYTES=`cat /proc/net/dev | grep $INT | awk '{print $2,$10}'`
        RX=`echo $BYTES | awk '{print $1}'`
        TX=`echo $BYTES | awk '{print $2}'`
        if [ `expr $RX - $OLDRX` -lt 655360 ]; then
          RXBYTES=`echo "scale=4;($RX-$OLDRX) * 8 / 1024 / 5" | bc`
          RSCALE="kbps"
        else 
          RXBYTES=`echo "scale=4;($RX-$OLDRX) * 8 / 1024 / 1024 / 5" | bc`
          RSCALE="mbps"
        fi
        if [ `expr $TX - $OLDTX` -lt 655360 ]; then
          TXBYTES=`echo "scale=4;($TX-$OLDTX) * 8 / 1024 / 5" | bc`
          TSCALE="kbps"
        else 
          TXBYTES=`echo "scale=4;($TX-$OLDTX) * 8 / 1024 / 1024 / 5" | bc`
          TSCALE="mbps"
        fi
        RXBYTES=`printf "%03.2f" $RXBYTES;`
        TXBYTES=`echo "scale=4;($TX-$OLDTX) * 8 / 1024 / 1024 / 5" | bc`
        TXBYTES=`printf "%03.2f" $TXBYTES;`
        printf "\r[\033[1;35m$INT\033[m] `date '+%H:%M:%S %Z %m/%d/%Y'` IN: \033[0;36m$RXBYTES\033[m $RSCALE OUT: \033[0;32m$TXBYTES\033[m $TSCALE"
        get_bytes $RX $TX
}

get_bytes $RX $TX
