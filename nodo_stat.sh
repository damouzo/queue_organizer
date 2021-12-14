#!/bin/bash


##############
# What's going on in our nodes?
##############
cd /home/dmouzo/CheckNodo/
qstat -f | awk '{gsub("-", "")}1' | awk 'NF' | tr -s ' ' | column -t > infoqstat.txt
/opt/slurm/bin/squeue > infosqueue.txt
 
echo "=============================" 
echo "====== QUEUE ORGANAIZER =====" 
echo "=============================" 

## SGE STATUS 
echo ">>> WORKING W/ SGE"
    # Normal running jobs in SGE
grep -i " r " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u 

    # Waiting things in SGE
SGE_WAIT=$(grep -i " qw " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SGE_WAIT" ]; then true; else echo "> waiting job(s):" && echo $SGE_WAIT; fi
    # Pending things in SGE
SGE_PEND=$(grep -i " hqw " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SGE_PEND" ]; then true; else echo "> holded job(s):" && echo $SGE_PEND; fi
    # Pending things in SGE
SGE_EQW=$(grep -i " Eqw " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SGE_EQW" ]; then true; else echo "> job(s) with error:" && echo $SGE_EQW; fi
    # Transferring things in SGE
SGE_TRANS=$(grep -i " t " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SGE_TRANS" ]; then true; else echo "> transferring job(s):" && echo $SGE_TRANS; fi
echo "-----------------------------" 

## SLURM STATUS 
echo ">>> WORKING W/ SLURM"
grep -i "R " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u 

    # Waiting things in SLURM
SLURM_WAIT=$(grep -i " PD " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SLURM_WAIT" ]; then true; else echo "> waiting job(s):" && echo $SLURM_WAIT; fi
    # Pending things in SLURM
SLURM_PEND=$(grep -i " PR " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SLURM_PEND" ]; then true; else echo "> holded job(s):" && echo $SLURM_PEND; fi
    # Fail things in SLURM
SLURM_FAIL=$(grep -i " F " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SLURM_FAIL" ]; then true; else echo "> failed job(s):" && echo $SLURM_FAIL; fi
    # Stopped things in SLURM
SLURM_STOP=$(grep -i " ST " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SLURM_STOP" ]; then true; else echo "> stopped job(s):" && echo $SLURM_STOP; fi
    # Suspended things in SLURM
SLURM_SUS=$(grep -i " S " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
if [ -z "$SLURM_SUS" ]; then true; else echo "> suspended job(s):" && echo $SLURM_SUS; fi
echo "-----------------------------" 

echo ">>> LOADED NODES"
cat infoqstat.txt | awk '$4>0.05' | grep -v NA | grep -o "\w*nodo\w*" | sort -u 
echo "============================="



