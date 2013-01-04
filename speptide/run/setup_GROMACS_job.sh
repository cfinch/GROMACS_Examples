#!/bin/bash

#This script needs to be edited for each run.
#Define PDB Filename & GROMACS Pameters

GROMACS_PDB=$1
GROMACS_FORCEFIELD="gromos53a6"
GROMACS_WATERMODEL="spc"
#GROMACS_BOXTYPE="dodecahedron"
GROMACS_BOXTYPE="cubic"
GROMACS_BOXORIENTATION="1.5"
GROMACS_BOXSIZE="5.0"
GROMACS_BOXCENTER="2.5"

#Setup GROMACS Job. Probably not necessary to edit past this point.
if [ -z "$GROMACS_PDB" ]; then
    echo "USAGE: ./setup_GROMACS_job.sh pdb_filename"
    echo "Do NOT include the .pdb extension in the file name."
    exit
fi

# Create symlinks to MDP files
find  '../MDP_Files' -name '*.mdp' -exec ln -s {} . \;

echo "Converting PDB to GMX format and setting water model and force field types" >  GROMACS-$GROMACS_PDB.out 2>&1

pdb2gmx -ignh -ff $GROMACS_FORCEFIELD -water $GROMACS_WATERMODEL \
-p topol.top -f $GROMACS_PDB.pdb -o $GROMACS_PDB.gro >> GROMACS-$GROMACS_PDB.out 2>&1

editconf -f $GROMACS_PDB.gro -o $GROMACS_PDB-box.gro -bt $GROMACS_BOXTYPE -c \
-d $GROMACS_BOXORIENTATION -box $GROMACS_BOXSIZE $GROMACS_BOXSIZE $GROMACS_BOXSIZE \
-center $GROMACS_BOXCENTER $GROMACS_BOXCENTER $GROMACS_BOXCENTER >> GROMACS-$GROMACS_PDB.out 2>&1

genbox -cp $GROMACS_PDB-box.gro -cs spc216.gro -p topol.top -o $GROMACS_PDB-solv.gro >> GROMACS-$GROMACS_PDB.out 2>&1

echo " " >> GROMACS-$GROMACS_PDB.out 2>&1

CHARGE=`grep "Total charge in system" GROMACS-$GROMACS_PDB.out`

if [ -n "$CHARGE" ]; then
    echo $CHARGE
    echo "Enter correct number of ions:"
    read IONS
    echo "Enter p for positive ions or n for negative ions:"
    read PNN

    echo "Neutralizing any latent charge left from initial solvation." >> GROMACS-$GROMACS_PDB.out 2>&1

    grompp -f energy_minimization.mdp -c $GROMACS_PDB-solv.gro -p topol.top -o ions.tpr >> GROMACS-$GROMACS_PDB.out 2>&1

    echo "Choose Group 13: SOL"
    genion -s ions.tpr -o $GROMACS_PDB-solv-ions.gro -p topol.top -pname NA -nname CL -n$PNN $IONS

else
    grep "System total charge" GROMACS-$GROMACS_PDB.out
    echo  ${GROMACS_PDB}-solv.gro ${GROMACS_PDB}-solv-ions.gro

    cp ${GROMACS_PDB}-solv.gro ${GROMACS_PDB}-solv-ions.gro
fi

echo "Preprocessing GROMACS Configuration" >> GROMACS-$GROMACS_PDB.out
grompp -f energy_minimization.mdp -c $GROMACS_PDB-solv-ions.gro -p topol.top -maxwarn 3 -v -o em.tpr

