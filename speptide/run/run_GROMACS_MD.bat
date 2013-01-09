#PBS -l nodes=2:ppn=8,pmem=2000M,walltime=01:00:00
#PBS -N GROMACS
#PBS -A bgoldiez
#PBS -q batch128
#PBS -j oe
#PBS -V

## DO NOT EDIT BELOW =====================================================
cd $PBS_O_WORKDIR
echo "Starting GROMACS run" > GROMACS-$PBS_JOBID.out
date >> GROMACS-$PBS_JOBID.out
hostname >> GROMACS-$PBS_JOBID.out
echo "=========================" >> GROMACS-$PBS_JOBID.out
echo " " >> GROMACS-$PBS_JOBID.out

#Set up Hosts File for OpenMPI
cat $PBS_NODEFILE | uniq > hosts-$PBS_JOBID.dat
export NP=`wc -l $PBS_NODEFILE | cut -d' ' -f1`
## DO NOT EDIT ABOVE =====================================================

## EDIT BELOW ************************************************************

# ----- Initial energy minimization -----
if [ -e "em.tpr" ]
then
    echo " ***** Energy Minimization ****** "
    mpirun -np $NP -machinefile $PBS_NODEFILE mdrun -pd -v -deffnm em 
    echo " "
else
    echo "Cannot start energy minimization; setup must have failed."
    exit
fi

# ------ NVT with fixed atoms -----
if [ -e "em.gro" ]
then
    echo " ***** NVT MD, Fixed Atoms ****** "
    grompp -maxwarn 3 -f NVT_fixed_atoms.mdp -c em.gro -p topol.top -o nvt_constrained.tpr
    echo " "
    mpirun -np $NP -machinefile $PBS_NODEFILE mdrun -pd -deffnm nvt_constrained
    echo " "

else
    echo "Cannot start NVT; energy minimization not completed."
    exit
fi

# ----- NPT with fixed atoms -----
if [ -e "nvt_constrained.gro" ]
then
    echo " ***** NPT MD, Fixed Atoms ****** "
    grompp -maxwarn 3 -f NPT_fixed_atoms.mdp -c nvt_constrained.gro -p topol.top -o npt_constrained.tpr
    echo " "

    mpirun -np $NP -machinefile $PBS_NODEFILE mdrun -pd -deffnm npt_constrained
    echo " "
else
    echo "Cannot start restrained NPT; restrained NVT not completed."
    exit
fi

# ----- NPT with no constraints -----
if [ -e "npt_constrained.gro" ]
then
    echo " ***** NPT MD, Unconstrained ****** "
    grompp -maxwarn 3 -f NPT.mdp -c npt_constrained.gro -t npt_constrained.cpt -p topol.top -o md_0_1.tpr
    echo " "

    mpirun -np $NP -machinefile $PBS_NODEFILE mdrun -pd -v -deffnm md_0_1
    echo " "
else
    echo "Cannot start full NPT; restrained NPT not completed."
    exit
fi

## EDIT ABOVE **********************************************************
echo "Completed Gromacs MD Run"
echo " "

##DO NOT EDIT BELOW ====================================================
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

