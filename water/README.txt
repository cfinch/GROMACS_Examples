This tutorial was inspired by the "official" GROMACS water tutorial at:
http://manual.gromacs.org/online/water.html
However, I think this example is much more comprehensive, because it shows you how to construct a box of water molecules from scratch. Because topology files for water are included with GROMACS, no additional structure files (such as .pdb) are required for this tutorial. This tutorial also corrects outdated syntax that is found in the .mdp file from the "official" tutorial.

----- Simulation -----
1. Generate a box:
editconf -f /usr/share/gromacs/top/spc216.gro -o empty_box.gro -bt dodecahedron -box 10

2. Fill box with solvent (water molecules):
genbox -cp empty_box.gro -cs /usr/share/gromacs/top/spc216.gro -o water.gro

3. Generate the topology and index files:
pdb2gmx -f water.gro -o water.gro -p water.top -n water.ndx
Try entering 14 for the force field (OPLS-AA/L) and 1 for the water model.

4. Run pre-processor to set up MD run
grompp -v -f water_MD.mdp -c water.gro -p water.top -o run_water

5. Run molecular dynamics simulation:
mdrun -s run_water.tpr -o -x -deffnm md_water

----- Analysis -----
1. View in VMD (http://www.ks.uiuc.edu/Research/vmd/)
a)Start VMD.
b) Go to File->New Molecule.  Select "water.gro" from the dialog box.
c) Right click on the name of the molecule you just created and choose "Load data into molecule".
Select "water.xtc" from the dialog box.

2. You can see that the box is a parallelepiped. GROMACS represents all box types as parallelepipeds for its internal calculations.  The utility "trjconv" can transform the box into the form that we requested (dodecahedron). 

Run once to convert the intial frame:
trjconv -f md_water.gro -s run_water.tpr -ur compact -pbc mol -o md_water_dodec.gro
Select 0 for "System" (not that it really matters in this case)

Run one more time to convert all frames in the trajectory:
trjconv -f md_water.xtc -s run_water.tpr -ur compact -pbc mol -o md_water_dodec.xtc

Load into VMD following the steps previously described.

Further information:
http://www.gromacs.org/Documentation/Terminology/Periodic_Boundary_Conditions

2. Radial distribution (pair correlation) function of water
a) Generate an index of oxygen atoms

This command requires an interactive session. First, delete the existing groups, then select all water oxygens (OW) and press q to save and quit:

--- Example Session ---
make_ndx -f md_water_dodec.gro -o oxygen.ndx

Reading structure file
Going to read 0 old index file(s)
Analysing residue names:
There are: 23452      Water residues

  0 System              : 93808 atoms
  1 Water               : 93808 atoms
  2 SOL                 : 93808 atoms

 nr : group       !   'name' nr name   'splitch' nr    Enter: list groups
 'a': atom        &   'del' nr         'splitres' nr   'l': list residues
 't': atom type   |   'keep' nr        'splitat' nr    'h': help
 'r': residue         'res' nr         'chain' char
 "name": group        'case': case sensitive           'q': save and quit
 'ri': residue index

> del 2
Removed group 2 'SOL'
> del 1
Removed group 1 'Water'
> del 0
Removed group 0 'System'
> a OW
Found 23452 atoms with name OW
  0 OW                  : 23452 atoms
> q

b) Use the index to calculate the pair correlation function for one frame:
g_rdf -f md_water_dodec.gro -n oxygen.ndx -o rdf.xvg

If you replace the .gro files with .xtc files, g_rdf will calculate the RDF for all frames in the trajectory and average them.  This will take substantially longer to complete.

c) View the plot:
xmgrace rdf.xvg 


