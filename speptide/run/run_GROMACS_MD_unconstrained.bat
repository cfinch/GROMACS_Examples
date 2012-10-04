#!/bin/bash
#PBS -l nodes=4:ppn=8,pmem=2000M,walltime=36:00:00
#PBS -N GROMACS_MD
#PBS -A account_name
#PBS -q batch128
#PBS -V

# This script assumes that the constrained simulations have already
# completed.  It only runs the unconstrained NPT simulation.

##DO NOT EDIT HERE =======================================================
cd $PBS_O_WORKDIR
echo "Starting Gromacs Tests" > GROMACS-$PBS_JOBID.out
date >> GROMACS-$PBS_JOBID.out
hostname >> GROMACS-$PBS_JOBID.out
echo "=========================" >> GROMACS-$PBS_JOBID.out
echo " " >> GROMACS-$PBS_JOBID.out

#Set up Hosts File for OpenMPI
cat $PBS_NODEFILE | uniq > hosts-$PBS_JOBID.dat
export NP=`wc -l $PBS_NODEFILE | cut -d/ -f1`
##DO NOT EDIT ABOVE =====================================================

##EDIT HERE *************************************************************

#Run Gromacs Job MD
echo "Stating Gromacs MD run" >> GROMACS-$PBS_JOBID.out

# ----- NPT with no constraints -----
echo " ***** NPT MD, Unconstrained ****** " >> GROMACS-$PBS_JOBID.out
grompp -maxwarn 3 -f mdwt.mdp -c npt.gro -t npt.cpt -p topol.top -o md_0_1.tpr >> GROMACS-$PBS_JOBID.out
echo " " >> GROMACS-$PBS_JOBID.out

mpirun -np $NP -machinefile $PBS_NODEFILE mdrun -pd -v -deffnm md_0_1 >> GROMACS-$PBS_JOBID.out
echo " " >> GROMACS-$PBS_JOBID.out

echo "Completed Gromacs MD Run" >> GROMACS-$PBS_JOBID.out
echo " " >> GROMACS-$PBS_JOBID.out
##EDIT ABOVE ***********************************************************

##DO NOT EDIT HERE ====================================================
cat $PBS_NODEFILE >> GROMACS-$PBS_JOBID.out
echo "ulimit -l: " >> GROMACS-$PBS_JOBID.out
ulimit -l >> GROMACS-$PBS_JOBID.out
echo " " >> GROMACS-$PBS_JOBID.out
echo "=========================" >> GROMACS-$PBS_JOBID.out
echo "Finished Gromacs Tests" >> GROMACS-$PBS_JOBID.out
date >> GROMACS-$PBS_JOBID.out

#mkdir GROMACS-$PBS_JOBID
#mv *.out GROMACS-$PBS_JOBID
#mv *.log GROMACS-$PBS_JOBID
#mv hosts-$PBS_JOBID.dat GROMACS-$PBS_JOBID
#mv *.gro GROMACS-$PBS_JOBID

##DO NOT EDIT ABOVE ===================================================

