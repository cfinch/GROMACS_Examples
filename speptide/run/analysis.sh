#!/bin/bash

# Save a 10ps snapshot of the trajectory as a PDB file
trjconv -f md_0_1.trr -s md_0_1.tpr -o md_0_1_10ps.pdb -dump 10
# Choose option 1 Protein

# Potential energy analysis
g_energy -f md_0_1.edr -o md_0_1_PE.xvg

# Low-pass filter for making smooth movies
g_filter -f md_0_1.trr -s md_0_1.tpr -ol md_0_1_resampled.xtc -all

# Center in box and fix boundary conditions
trjconv -f md_0_1.trr -s md_0_1.tpr -o md_0_1_nojump.xtc -center -pbc nojump

# Generate a PDB file for visualizing the nojump trajectory
trjconv -f md_0_1_nojump.xtc -s md_0_1.tpr -o md_0_1_nojump.pd

# Calculate RMSD of alpha carbons or backbone for nojump trajectory
g_rms -f md_0_1_nojump.xtc  -s md_0_1.tpr -o md_0_1_nojump_rmsd.xvg
# Choose group 3 (alpha carbons) for both

# Secondary structure analysis with DSSP
DSSP=/apps/DSSP/bin/dsspcmbi do_dssp -s md_0_1.tpr -f md_0_1.trr -dt 100 -tu ps
# Choose group 1 (Protein)

# Convert XPM to EPS (good format for publication)
xpm2ps -f ss.xpm -o ss.eps

# Convert EPS to PNG (for easier viewing)
convert ss.eps ss.png
