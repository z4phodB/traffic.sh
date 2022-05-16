# traffic.sh
Shell script to display traffic stats on a single interface

Usage: traffic.sh \<optional interface name\>

If no interface is specificied the first default route interface will be used.
  
Use ctrl+c to quit

<i>Known Issue: Interface counters in proc are 32-bit and can infrequently roll over causing traffic.sh to segfault if they roll while script is running.</i>
