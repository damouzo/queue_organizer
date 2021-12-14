#!/bin/bash


##############
# What's going on in our nodes?
##############
cd /home/dmouzo/CheckNodo/
qstat -f | awk '{gsub("-", "")}1' | awk 'NF' | tr -s ' ' | column -t > infoqstat.txt
/opt/slurm/bin/squeue > infosqueue.txt
 

echo "====== QUEUE ORGANAIZER =====" 
echo "=============================" 
echo ">>> WORKING W/ SGE"
grep -i "r " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u 
echo "> waiting:"
grep -i "q " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u 
echo "-----------------------------" 

echo ">>> WORKING W/ SLURM"
grep -i "R " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u 
echo "> waiting:"
grep -i "PD " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u 
echo "-----------------------------" 

echo ">>> LOADED NODES"
cat infoqstat.txt | awk '$4>0.05' | grep -v NA | grep -o "\w*nodo\w*" | sort -u 
echo "============================="



