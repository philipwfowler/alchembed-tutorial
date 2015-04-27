#! /bin/bash

# if necessary, put the required GROMACS version in your $PATH. Check via
#  > grompp --version
# you may only have one version on your machine, or you may use a modules environment

source /usr/local/gromacs/5.0.4/bin/GMXRC

# this script takes two arguments
# the first is the name of the protein (from pla2, nbar, cox1, kcsa, ompf)
protein=$1

# the second is whether it is atomistic (at) or coarse-grained (cg)
ff=$2

# create the output directory if it doesn't exist (e.g. nbar/cg/)
if [ ! -d "$protein" ]; then
	mkdir $protein
fi

if [ ! -d "$protein/$ff" ]; then
	mkdir $protein/$ff
fi

# First, prepare a TPR file for energy minimisation
grompp 	 -f common-files/em-$ff.mdp\
		 -c common-files/$protein-$ff.pdb\
		 -p common-files/$protein-$ff.top\
		 -n common-files/$protein-$ff.ndx\
	     -po $protein/$ff/$protein-$ff-em.mdp\
		 -o $protein/$ff/$protein-$ff-em\
	     -maxwarn 1

# ..now run using double precision (you may need to compile this as only single precision is compiled by default)
#  (or just try single precision...)
# This should only take a few seconds
mdrun_d  -deffnm $protein/$ff/$protein-$ff-em\
		 -ntmpi 1


# Now, prepare the ALCHEMBED TPR file
grompp 	 -f common-files/alchembed-$ff.mdp\
		 -c $protein/$ff/$protein-$ff-em.gro\
		 -p common-files/$protein-$ff.top\
		 -n common-files/$protein-$ff.ndx\
	     -po $protein/$ff/$protein-$ff-alchembed.mdp\
		 -o $protein/$ff/$protein-$ff-alchembed\
         -maxwarn 2

# ..and run on a single core. 
mdrun    -deffnm $protein/$ff/$protein-$ff-alchembed\
	     -ntmpi 1