#!/bin/bash -e
####---------Generate png Files of Surface Images--------#######
####----Last Updated: 7/30/2018 Authors: Katherine Xu
####----This script was designed to automate the production of the png images from a template scene. The template scene can be customized and saved in the workbench gui.This is a slimmed down version from 2017 (antsct_heatmap.sh also in /data/grossman/tools/workbench/scripts)


####----For more information regarding wb_command -metric-palette see: http://www.humanconnectome.org/software/workbench-command/-metric-palette
####----For more information regarding wb_command -show-scene see: http://www.humanconnectome.org/software/workbench-command/-show-scene


if [[ $# -lt 1 ]]; then
cat <<USAGE

	$0 <subject_z.nii.gz> <OPTIONAL min z-score> <OPTIONAL max z-score>

	nifti file with the subjects z-scores produced

	Files Created: R/L.surf.gii, .scene, and .png file of heatmap renders in same directory as input

	Note .scene file (which can be opened with wb_view for modification)

USAGE

exit 1

fi

#Creates variable to point to the template scene

#templateold='/data/grossman/tools/workbench/scripts/templatefiles/neuroprint.scene'
template='/flywheel/v0/misc/neuroprint_abs.scene'

# Whenever the scene is edited and saved, it defaults to relative path names. This command removes the relative path names and saves it to a new template to be accessed later
#cat $templateold | sed 's/\.\.\/\.\.\/\.\.\/\.\.//g'| sed 's/\.\.\///g' > $template


# This is the line in the template scene that will be replaced by the user's new file name. This may need to be edited based on different templates
toremove='data/grossman/tools/workbench/scripts/templatefiles/s1_100190_20081103_CorticalThicknessNormalizedToMNI152'
alsoremove='s1_100190_20081103_CorticalThicknessNormalizedToMNI152'


#Default variables
height=880
width=910
scene=1
min=1.75
max=5


#Takes the .nii file. Replaces template files with the outputted files in the template using a sed command.
if [ -e "$1" ]; then
	fileinput=$1
	fileraw=`readlink -e $fileinput`
	input=${fileraw%.nii.gz}

	# Uses the vol2surf.sh script to generate the L/R surface gifti files
	/flywheel/v0/src/vol2surf.sh $fileraw

	# sed command to remove the template files and replace with input files
	cat $template | sed "s|${toremove}|${input}|g" | sed "s|${alsoremove}|${input}|g" > ${input}_scene.scene

else
	echo "Error -- requires a valid file name"
	exit 1

fi


if [[ $2 -gt 0 ]]; then
	min=$2
	echo $min
fi

if [[ $3 -gt 0 ]]; then
	max=$3
	echo $max
fi

wb_command -metric-palette ${input}_L.shape.gii MODE_USER_SCALE -palette-name FSL -pos-user $min $max
wb_command -metric-palette ${input}_R.shape.gii MODE_USER_SCALE -palette-name FSL -pos-user $min $max

wb_command -show-scene ${input}_scene.scene $scene ${input}_pic.png $width $height

#display ${input}_pic.png &