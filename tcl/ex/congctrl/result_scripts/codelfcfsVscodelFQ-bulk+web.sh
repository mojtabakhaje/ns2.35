#! /bin/bash
# Compare CoDel+FCFS with CoDel+FQ
# Workload: Bulk+Web on 15 mbps.

killall -s9 ns
rm *.log
rm *.codel
rm *.codelfcfs
rm *.droptail
rm *.rtt

seed=1

while [ $seed -lt 75 ]; do

  pls ./mixed_sims.tcl remyconf/dumbbell-buf1000-rtt150-bneck15.tcl -nsrc 2 -seed $seed -simtime 1000 -ontype flowcdf -offtime 0.2 -reset false -verbose true -gw sfqCoDel -tcp TCP/Newreno -sink TCPSink/Sack1 -maxq 100000000 -pktsize 1210 -rcvwin 10000000 -flowoffset 16384 -codel_target 0.005 -rttlog 2flow$seed.codelfcfs.rtt -maxbins 1 > 2flow$seed.codelfcfs &
  pls ./mixed_sims.tcl remyconf/dumbbell-buf1000-rtt150-bneck15.tcl -nsrc 2 -seed $seed -simtime 1000 -ontype flowcdf -offtime 0.2 -reset false -verbose true -gw sfqCoDel -tcp TCP/Newreno -sink TCPSink/Sack1 -maxq 100000000 -pktsize 1210 -rcvwin 10000000 -flowoffset 16384 -codel_target 0.005 -rttlog 2flow$seed.codel.rtt -maxbins 1024   > 2flow$seed.codel &

  seed=`expr $seed '+' 1`
done