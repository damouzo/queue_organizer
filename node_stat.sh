#!/bin/bash

########
# Help #
########
Help()
{
   # Display Help
   echo 
   echo "==========================================="
   echo "Hey there! Here is what you can do:"
   echo "Syntax: /path/nodo_stat.sh [-h|w|f|u|p]"
   echo
   echo "options:"
   echo "h | --help      Help."
   echo "w | --work      Working nodes info"
   echo "f | --free      Free nodes info"
   echo "u | --user      User queue working details"
   echo "p | --pipe      first free node to pipes"
   echo "v | --version   Version" 
   echo "==========================================="
   echo
}


###############################
#  Set tmp, workDir and TRAP  #
###############################
cd /home/dmouzo/CheckNodo/
PWD="/home/dmouzo/CheckNodo/" 

trap "rm -rf /home/dmouzo/CheckNodo/tmp" EXIT
         
if [ ! -d $PWD/tmp ]; then
   mkdir $PWD/tmp
   chmod 777 $PWD/tmp
fi                         

                                    
###############################
# Load node info in variables #
###############################       
USER_LIST=$(ls /home/)                                                    
qstat -u $USER_LIST | awk '{gsub("-", "")}1' | awk 'NF' | tr -s ' ' | column -t > $PWD/tmp/infoqstat.txt   #Introduce SGE path to qstat
/opt/slurm/bin/squeue | tr -s ' ' | column -t > $PWD/tmp/infosqueue.txt                                    #Introduce SLURM path to squeue
/opt/slurm/bin/sinfo | tr -s ' ' | column -t > $PWD/tmp/infosinfo.txt                                      #Introduce SLURM path to squeue


#SGE
SGE_RUN=$(grep -i " r " -B 1 $PWD/tmp/infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_WAIT=$(grep -i " qw " -B 1 $PWD/tmp/infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_PEND=$(grep -i " hqw " -B 1 $PWD/tmp/infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_EQW=$(grep -i " Eqw " -B 1 $PWD/tmp/infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_TRANS=$(grep -i " t " -B 1 $PWD/tmp/infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_NODE_DOWN=$(grep -i "au" $PWD/tmp/infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
#SLURM
SLURM_RUN=$(grep -i "R " $PWD/tmp/infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_WAIT=$(grep -i " PD " $PWD/tmp/infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_PEND=$(grep -i " PR " $PWD/tmp/infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_FAIL=$(grep -i " F " $PWD/tmp/infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_STOP=$(grep -i " ST " $PWD/tmp/infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_SUS=$(grep -i " S " $PWD/tmp/infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_NODE_DOWN=$(grep -i "down" $PWD/tmp/infosinfo.txt | grep -o "\w*nodo.*\w*" | sort -u)
#LOAD NODE
LOADED_NODES=$(cat $PWD/tmp/infoqstat.txt | awk '$4>0.05' | grep -v NA | grep -o "\w*nodo\w*" | sort -u)



##################
# The Main Thing #
##################
# Get the options
while getopts ":hwfupvz --help --work --free --user --pipe --version --zzz" option; do
   case $option in
      h | --help) # display Help
         Help
         exit;;
         
         
      w | --work) # Print working nodes info
          echo
          echo "==============================" 
          echo "====== QUEUE ORGANAIZER ======" 
          echo "=============================="
          echo 
          
          ## SGE STATUS 
          echo ">>>  WORKING W/ SGE"
              # Normal running jobs in SGE
          if [ -z "$SGE_RUN" ]; then true; else echo $SGE_RUN; fi
              # Waiting things in SGE
          if [ -z "$SGE_WAIT" ]; then true; else echo "> waiting job(s):" && echo $SGE_WAIT; fi
              # Pending things in SGE
          if [ -z "$SGE_PEND" ]; then true; else echo "> holded job(s):" && echo $SGE_PEND; fi
              # Pending things in SGE
          if [ -z "$SGE_EQW" ]; then true; else echo "> job(s) with error:" && echo $SGE_EQW; fi
              # Transferring things in SGE
          if [ -z "$SGE_TRANS" ]; then true; else echo "> transferring job(s):" && echo $SGE_TRANS; fi
              # Nodes that goes down
          if [ -z "$SGE_NODE_DOWN" ]; then true; else echo "> broken node communication:" && echo $SGE_NODE_DOWN; fi
          echo "------------------------------" 
                    
          ## SLURM STATUS 
          echo ">>>  WORKING W/ SLURM"
          if [ -z "$SLURM_RUN" ]; then true; else echo $SLURM_RUN; fi
              # Waiting things in SLURM
          if [ -z "$SLURM_WAIT" ]; then true; else echo "> waiting job(s):" && echo $SLURM_WAIT; fi
              # Pending things in SLURM
          if [ -z "$SLURM_PEND" ]; then true; else echo "> holded job(s):" && echo $SLURM_PEND; fi
              # Fail things in SLURM
          if [ -z "$SLURM_FAIL" ]; then true; else echo "> failed job(s):" && echo $SLURM_FAIL; fi
              # Stopped things in SLURM
          if [ -z "$SLURM_STOP" ]; then true; else echo "> stopped job(s):" && echo $SLURM_STOP; fi
              # Suspended things in SLURM
          if [ -z "$SLURM_SUS" ]; then true; else echo "> suspended job(s):" && echo $SLURM_SUS; fi
              # Nodes that goes down
          if [ -z "$SLURM_NODE_DOWN" ]; then true; else echo "> down node(s):" && echo $SLURM_NODE_DOWN; fi
          echo "------------------------------" 
          
          # LOAD NODE DATA
          echo ">>>  LOADED NODES"
          echo $LOADED_NODES 
          echo "=============================="
          echo
          exit;;
          
          
      f | --free) # Where are free node?
         declare -a ALL_NODES
         declare -a BUSY_NODES
         ALL_NODES=(nodo01 nodo02 nodo03 nodo04 nodo05)
         BUSY_NODES=($SGE_RUN $SGE_WAIT $SGE_PEND $SGE_EQW $SGE_TRANS $SLURM_RUN $SLURM_WAIT $SLURM_PEND $SLURM_FAIL $SLURM_STOP $SLURM_SUS $LOADED_NODES) 
         FREE_NODES=$(echo ${ALL_NODES[@]} ${BUSY_NODES[@]} | tr ' ' '\n' | sort | uniq -u)
         if [ -z "$FREE_NODES" ]; then echo "Sorry, but i don´t found a node for your jobs"; else 
         echo
         echo "===============================" 
         echo "======= FREE NODES LIST =======" 
         echo "===============================" 
         echo ${FREE_NODES[@]}
         echo "===============================" 
         echo 
         fi
         exit;;
         
         
      u | --user) #User working
         echo
         echo "====================================================="
         echo "  PERSON  |   NODE   |    JOB    |  QUEUE  |  STATE" 
         echo "=====================================================" 
         for NODE in nodo01 nodo02 nodo03 nodo04 nodo05; 
         do
           if grep -q $NODE $PWD/tmp/infosqueue.txt 
           then
             LINE=$(grep -no $NODE $PWD/tmp/infosqueue.txt | cut -d: -f1)
             COLUMN=4
             DOING_COL=3
             STATE_COL=5
             WHO=$(awk -v line="$LINE" -v col="$COLUMN" 'NR == line { print $col }' < $PWD/tmp/infosqueue.txt)
             DOING=$(awk -v line="$LINE" -v col="$DOING_COL" 'NR == line { print $col }' < $PWD/tmp/infosqueue.txt)
             STATE=$(awk -v line="$LINE" -v col="$STATE_COL" 'NR == line { print $col }' < $PWD/tmp/infosqueue.txt)
             if [ -z "$WHO" ]; then true ; else  
             echo $WHO "-->" $NODE "-->" $DOING "--> slurm" "--> " $STATE ; fi
           else
             true
           fi 
           
           if grep -q $NODE $PWD/tmp/infoqstat.txt 
           then
             LINE=$(grep -no $NODE $PWD/tmp/infoqstat.txt  | cut -d: -f1)
             COLUMN=4
             DOING_COL=3
             STATE_COL=5
             WHO=$(awk -v line="$LINE" -v col="$COLUMN" 'NR == line { print $col }' < $PWD/tmp/infoqstat.txt)
             DOING=$(awk -v line="$LINE" -v col="$DOING_COL" 'NR == line { print $col }' < $PWD/tmp/infoqstat.txt)
             STATE=$(awk -v line="$LINE" -v col="$STATE_COL" 'NR == line { print $col }' < $PWD/tmp/infoqstat.txt)
             if [ -z "$WHO" ]; then true ; else
             echo $WHO "-->" $NODE "-->" $DOING "--> SGE " "--> " $STATE ; fi
           else
             true
           fi 
                     
         done
         echo "=====================================================" 
         echo
         exit;;
      
      
      p | --pipe) # first free node to pipe works
         declare -a ALL_NODES
         declare -a BUSY_NODES
         ALL_NODES=(nodo01 nodo02 nodo03 nodo04 nodo05)
         BUSY_NODES=($SGE_RUN $SGE_WAIT $SGE_PEND $SGE_EQW $SGE_TRANS $SLURM_RUN $SLURM_WAIT $SLURM_PEND $SLURM_FAIL $SLURM_STOP $SLURM_SUS $LOADED_NODES) 
         FREE_NODES=$(echo ${ALL_NODES[@]} ${BUSY_NODES[@]} | tr ' ' '\n' | sort | uniq -u)
         GO_TO=$(echo $FREE_NODES | cut -d ' ' -f1)
         echo $GO_TO
         exit;;
 
 
      v | --version) # version 
         echo 
         echo "================================"
         echo "======== Node Organaizer ======="
         echo "================================"
         echo "version 1.0"
         echo "github: damouzo/queue_organizer"
         echo "================================"
         echo 
         exit;;
         
 
      z | --zzz) # Print poem
         echo
         echo "My code fails."
         echo "I do not know why."
         echo "My code works."
         echo "I do not know why."  
         echo 
         echo "Have a nice day :)"
         echo
         exit;;  

   esac
done

echo "Error: How I can help? check --help"

