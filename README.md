# An ALCHEMBED tutorial.

## Pre-release notes (to be modified)

One can obtain this tutorial from two places.

1. As a tarball as part of the Supplementary Information of the *ALCHEMBED* paper. This version is therefore easier to find and will be maintained indefinitely, but will not evolve with time.
2. As an open GitHub repository. Changes will be made to this repository with time to reflect e.g. changes in GROMACS functionality. 

To obtain the repository, assuming you have git installed, issue. 
 
    git clone https://github.com/philipwfowler/alchembed-tutorial.git 

which will create a directory called `alchembed-tutorial` and download the files.

## Objective

To demonstrate how the *ALCHEMBED* method can embed different membrane proteins into lipid bilayers. 

## Citing (to be modified)

This tutorial accompanies the following paper

    @article{Jefferys2015,
    author = {Jefferys, Elizabeth and Sands, Zara A and Shi, Jiye and Sansom, Mark S P and Fowler, W},
    title = {{Alchembed : A computational method for incorporating multiple proteins into complex lipid geometries .}},
    year = {2015}
    }

and allows the user to embed the five different membrane proteins shown in Figure 3 into a simple lipid bilayer comprising 512 POPC lipids. As in the paper, each protein can be embedded using either a fully-atomistic forcefield ([CHARMM27](http://www.gromacs.org/Documentation/Terminology/Force_Fields/CHARMM)) or a coarse-grained forcefield ([MARTINI2.2](http://md.chem.rug.nl/cgmartini/)).

If you use this tutorial please cite the above paper in your work.

## Pre-requisites

As in the paper, all the simulations are performed in [GROMACS](http://www.gromacs.org), although in principle the method should work equally well in AMBER, NAMD or CHARMM since all these codes include van der Waals soft-core functionality.

- [GROMACS](http://www.gromacs.org) 5.0.X or later. This will include the [CHARMM27 forcefield files](http://www.gromacs.org/Documentation/Terminology/Force_Fields/CHARMM).
- [VMD](http://www.ks.uiuc.edu/Research/vmd/) 1.9.X or later if you wish to visualise the resulting trajectories.

## Instructions

All the [GROMACS](http://www.gromacs.org) commands have been stored in a bash script, `try-alchembed.sh`, that is in the root of this repository. All of the files required for the simulations are stored in the `common-files/` directory. The five test proteins are referred to using these slightly shortened names ['nbar','pla2','cox1','kcsa','ompf'] and the forcefield is specified as one of ['at','cg'].

Take for example the 'nbar' protein in a 'cg' representation. 

    ls common-files/nbar-cg.*
    common-files/nbar-cg.itp common-files/nbar-cg.pdb
    common-files/nbar-cg.ndx common-files/nbar-cg.top
 
There are four files in `common-files/` specific to this protein/forcefield combination. (The atomistic simulations have a fifth file that `foo-at_posre.itp` that specifies which protein atoms to position restrain during the simulation). The PDB file contains the intial coordinates of the lipids, protein and water. Please visualise this using [VMD](http://www.ks.uiuc.edu/Research/vmd/)/PyMol/Chimera to satisfy yourself that many of the protein and lipid beads clash. To provide a more stringent test you could also move the protein relative to the bilayer, rather than use the conformation provided. The NDX file is contains the index groups; these are referred to in the MDP file (see below). Finally the TOP file specifies the composition of the system and the location of the ITP files (including the protein one listed above) which describe the connectivity of the different molecules.

The *ALCHEMBED* process has two steps; the first is a short energy minimisation. The run parameters for this are specified in 

    less common-files/em-cg.mdp

The second step is a short 1000 step [GROMACS](http://www.gromacs.org) MD simulation where the van der Waals interaction between the protein and the rest of the system is described by a soft-core van der Waals potential. The run parameters for this are here

    less common-files/alchembed-cg.mdp
    
The strength of the (soft-core) van der Waals interaction between the protein and the rest of the system is described by a coupling parameter, lambda. Initially, lambda is zero and there are no forces between the protein and the rest of the system. Here lambda increases by 0.001 for 1000 steps, thereby smoothly "turning on" the interactions between the protein and the rest of the system. During this process the position of the protein beads (or atoms) are restrained and as lambda increases the lipid beads (or atoms) move out of the space occupied by the protein.

The `try-alchembed.sh` script takes two arguments (the script is commented also if you'd like to look inside). The name of the protein (taken from the list above) and the forcefield. Hence to run it type

    ./try-alchembed.sh nbar cg

and assuming you have [GROMACS](http://www.gromacs.org) in your `$PATH` etc, then it should perform the short energy minimisation and then the embedding simulation. On a single core of at Intel Xeon E5 processor (c. 2014) this took 13 seconds. The larger proteins and the atomistic cases will take longer (nbar at took around 15 min on the same processor).

All the regular [GROMACS](http://www.gromacs.org) output files are stored in `protein/forcefield/`, i.e. `nbar/cg/` in this case (the script automatically creates the directory if it doesn't exist). The files ending in `-em` are from the energy minimisation run and those ending in `-alchembed` are from the embedding run. Hence to examine the result of the above short run,

    cd nbar/cg/
    ls
     nbar-cg-alchembed.cpt      nbar-cg-alchembed.trr      nbar-cg-em.log
     nbar-cg-alchembed.edr      nbar-cg-alchembed.xtc      nbar-cg-em.mdp
     nbar-cg-alchembed.gro      nbar-cg-alchembed.xvg      nbar-cg-em.tpr
     nbar-cg-alchembed.log      nbar-cg-alchembed_prev.cpt nbar-cg-em.trr
     nbar-cg-alchembed.mdp      nbar-cg-em.edr
     nbar-cg-alchembed.tpr      nbar-cg-em.gro
    vmd -pdb ../../common-files/nbar-cg.pdb -xtc nbar-cg-alchembed.xtc

assuming you have [VMD](http://www.ks.uiuc.edu/Research/vmd/) installed and in your $PATH. A good way in [VMD](http://www.ks.uiuc.edu/Research/vmd/) of seeing what is going on is to first create a Graphical Representation of the protein. A Transparent QuickSurf works well. Then create a Graphical Representation that displays the number of lipid/water beads/atoms within sigma of the protein. Opaque VDW is good here. For AT simulations the Selected Atoms would be

    not protein and within 2.4 of protein
 
and then check "Update Selection Every Frame" under the "Trajectory" tab. For CG a difficulty is that the "protein" keyword does not work. Instead try

    resname W POPC and within 4.7 of (not resname W POPC)

Also, you will need to remove the jumps across the periodic boundary conditions in any AT sim via `trjconv`, which is part of the [GROMACS](http://www.gromacs.org) packages so should be in your $PATH. For example, for nbar at

    trjconv -f nbar-at-alchembed.xtc -s nbar-at-alchembed.tpr -pbc mol -o nbar-at-alchembed-nojump.xtc
 
then load this XTC file into [VMD](http://www.ks.uiuc.edu/Research/vmd/) instead

    vmd -pdb ../../common-files/nbar-at.pdb -xtc nbar-at-alchembed-nojump.xtc 

## Extensions

To further convince yourself that the *ALCHEMBED* process has successfully embedded the test proteins into the POPC bilayer, you could use the final GRO file (e.g. `nbar-cg-alchembed.gro`) to start a standard MD NpT simulation.




