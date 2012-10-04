This repo contains examples that show you how to run molecular dynamics (MD) calculations on the STOKES cluster (webstokes.ist.ucf.edu). 

CAVEAT: you will probably need to modify these scripts to suit your purposes. Do not use simulation software without understanding it! I make no guarantee that these examples will work and I assume no liability for any consequences.

The general structure of each example is:

Example_name
  |
  +-run
  +-MDP_Files
     |
     +-PDB structure file
     +-setup_GROMACS_job.sh
     +-run_GROMACS_MD.bat
     +-cleanup.sh

The MDP files are kept in a separate directory because they don't change from run to run.

setup_GROMACS_job.sh is an interactive Bash script that imports the structure from the PDB file, creates a solvated box, and adds ions to neutralize the charge (if necessary).  It then sets up, but does not run, the initial energy minimization. Before running this script, open in a text editor and read and follow the instructions.

run_GROMACS_MD.bat is a submit script for the Torque resource manager. It contains commands to run the initial energy minimization, an optional NVT simulation with fixed protein atoms, an NPT simulation with fixed protein atoms, and finally an NPT simulation without constraints on the protein atoms.  Even if you aren't using Torque, this script will show you which commands you need to run.

cleanup.sh is a potentially DANGEROUS script that deletes all of the simulation results from the directory in which it is run. You will have to re-run EVERYTHING after you run this script!
