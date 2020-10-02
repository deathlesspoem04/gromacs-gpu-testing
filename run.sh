#!/bin/bash
start=`date +%s`
gmx pdb2gmx -f 1d01_singlechain.pdb -o 1.gro -p 1.top -water spce
gmx editconf -f 1.gro -o box.gro -c -d 1.0 -bt cubic
gmx solvate -cp box.gro -cs spc216.gro -o water_box.gro -p 1.top
gmx grompp -f ions.mdp -c water_box.gro -p 1.top -o ions.tpr
gmx genion -s ions.tpr -o water_ions.gro -p 1.top -pname NA -nname CL -neutral
gmx grompp -f minim.mdp -c water_ions.gro -p 1.top -o energyminimization.tpr
gmx mdrun -v -s energyminimization.tpr -deffnm em
gmx energy -f em.edr -o potential.xvg
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p 1.top -o nvt.tpr
gmx mdrun -deffnm nvt -nb gpu
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p 1.top -o npt.tpr
gmx mdrun -deffnm npt -nb gpu
gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p 1.top -o full_md.tpr
gmx mdrun -deffnm full_md -nb gpu
gmx rms -s full_md.tpr -f full_md1.xtc -o rmsd.xvg
gmx rmsf -s full_md.tpr -f full_md1.xtc -res -o rmsf.xvg
gmx gyrate -s full_md.tpr -f full_md1.xtc -o gyr.xvg
end=`date +%s`
runtime=$((end-start))
printf "\n"
echo "Script ran in $runtime seconds"
