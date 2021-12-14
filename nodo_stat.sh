#!/bin/bash


########
# Help #
########
Help()
{
   # Display Help
   echo "===================================" 
   echo "Hey! Here is what you'll find here."
   echo
   echo "Syntax: /path/nodo_stat.sh [-h|d|f|c|p]"
   echo "options:"
   echo "h     Print Help."
   echo "d     Print working nodes info"
   echo "f     Display free nodes"
   echo "p     Print a poem"
   echo 
}

############################################################
# Load node info in variables                              #
############################################################
#EXTRACT INFO
cd /home/dmouzo/CheckNodo/
qstat -f | awk '{gsub("-", "")}1' | awk 'NF' | tr -s ' ' | column -t > infoqstat.txt
/opt/slurm/bin/squeue > infosqueue.txt
/opt/slurm/bin/sinfo > infosinfo.txt

#SGE
SGE_RUN=$(grep -i " r " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_WAIT=$(grep -i " qw " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_PEND=$(grep -i " hqw " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_EQW=$(grep -i " Eqw " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
SGE_TRANS=$(grep -i " t " -B 1 infoqstat.txt | grep -o "\w*nodo\w*" | sort -u)
#SLURM
SLURM_RUN=$(grep -i "R " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_WAIT=$(grep -i " PD " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_PEND=$(grep -i " PR " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_FAIL=$(grep -i " F " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_STOP=$(grep -i " ST " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_SUS=$(grep -i " S " infosqueue.txt | grep -o "\w*nodo\w*" | sort -u)
SLURM_NODE_DOWN=$(grep -i "down" infosinfo.txt | grep -o "\w*nodo.*\w*" | sort -u)
#LOAD NODE
LOADED_NODES=$(cat infoqstat.txt | awk '$4>0.05' | grep -v NA | grep -o "\w*nodo\w*" | sort -u)



############################################################
# Process with the input options                           #
############################################################
# Get the options
while getopts ":hdfp" option; do
   case $option in
      h) # display Help
         Help
         exit;;
         
         
      d) # Print working nodes info
          echo "=============================" 
          echo "====== QUEUE ORGANAIZER =====" 
          echo "=============================" 
          
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
          echo "-----------------------------" 
                    
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
          echo "-----------------------------" 
          
          # LOAD NODE DATA
          echo ">>>  LOADED NODES"
          echo $LOADED_NODES 
          echo "============================="
          exit;;
          
          
      f) # Where is free node?
         declare -a ALL_NODES
         declare -a BUSY_NODES
         ALL_NODES=(nodo01 nodo02 nodo03 nodo04 nodo05)
         BUSY_NODES=($SGE_RUN $SGE_WAIT $SGE_PEND $SGE_EQW $SGE_TRANS $SLURM_RUN $SLURM_WAIT $SLURM_PEND $SLURM_FAIL $SLURM_STOP $SLURM_SUS $LOADED_NODES) 
         FREE_NODES=$(echo ${ALL_NODES[@]} ${BUSY_NODES[@]} | tr ' ' '\n' | sort | uniq -u)
         if [ -z "$FREE_NODES" ]; then echo "Sorry, but i don´t found a node for your jobs"; else echo "> free node(s):" && echo ${FREE_NODES[@]}; fi
         exit;;
         
 
      p) # Print poem
         echo
         echo "My code fails."
         echo "I do not know why."
         echo "My code works."
         echo "I do not know why."  
         echo 
         echo "Have a nice day :)"
         echo
         exit;;  

         
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done


############################################################
# Display info without arg.                                #
############################################################
echo "=============================" 
echo "====== QUEUE ORGANAIZER =====" 
echo "=============================" 

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
echo "-----------------------------" 
          
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
echo "-----------------------------" 

# LOAD NODE DATA
echo ">>>  LOADED NODES"
echo $LOADED_NODES 
echo "============================="



