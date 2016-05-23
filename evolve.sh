#!/bin/bash
# Harness for automatically evolving bots.
# Currently game reports results to JSON files in /tmp
cd `dirname $0`
RESULTSFILE="/tmp/result-pool.json"
CONFIGSFILE="/tmp/config-pool.json"
RESULTSDIR="results-`date +%F-%H%M%S`"
TOTALGENS=1000
RUNSPERGEN=8
PAR=3

[[ -d $RESULTSDIR ]] || mkdir $RESULTSDIR
# Reset neuron configs
rm $RESULTSFILE $CONFIGSFILE 2>/dev/null

# Evo loop. Note there is currently 3 bots per run. Means the pool size will be 30.
for i in `seq 1 $TOTALGENS`; do
  for j in `seq 1 $RUNSPERGEN`; do
     echo "############ Playing game $((($i-1)*$RUNSPERGEN+$j)) ############"
    ./Bubbles9000/application.linux64/Bubbles9000 #>/dev/null 2>&1
  done
  echo "############ Evolution $i ############"
  cp $RESULTSFILE "${RESULTSDIR}/${i}-`basename $RESULTSFILE`"
  # Generate a new config by evolving stored results.
  java -jar ./ShipEvolver/shipevolver.jar ${RESULTSFILE} 2>/dev/null  >${CONFIGSFILE}
  rm ${RESULTSFILE}
done
