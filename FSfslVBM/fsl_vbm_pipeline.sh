#!/usr/bin/env bash

while getopts ":i:o:f:v:n:t:c:e:" opt; do
  case $opt in
    i) IMAGE_PATH=$OPTARG ;;
    f) FREESURFER=$OPTARG ;;
    o) SAVE_PATH=$OPTARG;;
    n) ID=$OPTARG;;
    v) VBM_DIR=$OPTARG;;
    t) TEMPLATE=$OPTARG;;
    c) CONFIG=$OPTARG;;
    e) EXTENSION=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$IMAGE_PATH" ]; then
	echo " need -i full path to freesurfer  to input image (aseg.mgz or aseg.nii)"
	exit 2
fi
if [ -z "$FREESURFER_HOME" ]; then
	echo "need -f path to FreeSurfer ( example: /cm/shared/apps/freesurfer/5.1.0/ ) "
	exit 2
fi
if [ -z "$SAVE_PATH" ]; then
	echo "need -o output folder"
	exit 2
fi
if [ -z "$VBM_DIR" ]; then
	echo "need -v path to VBM scripts and templates folder"
	exit 2
fi
if [ -z "$ID" ]; then
	echo "need -n uniq name for image"
	exit 2
fi
if [ -z "$TEMPLATE" ]; then
	echo "need -t full path to template image"
	exit 2
fi
if [ -z "$CONFIG" ]; then
	echo "need -c full path to fsl config file for registration"
	exit 2
fi


if [ -z "$FREESURFER_HOME" ]; then
  export FREESURFER_HOME=${FREESURFER}
fi
source ${FREESURFER_HOME}/bin/SetUpFreeSurfer.sh

NAME=`basename $IMAGE_PATH`
NAME=`echo "$NAME" | cut -d'.' -f1`

NAME=${ID}_${NAME}

###FreeSurfer function to convert mgz to nifti if input is mgz
if [ -z "$EXTENSION" ] || ["$EXTENSION" = "mgz"]; then
	echo "Input file format file is taken mgz by default."

  #echo " Image is in .mgz format. Converting to nii ... "
  ${FREESURFER_HOME}/bin/mri_convert --in_type mgz --out_type nii --out_orientation LAS ${IMAGE_PATH} ${SAVE_PATH}/${NAME}.nii
  #echo " Conversion complete. "

  ### python script to extract grey matter regions from segmentation image
  python3 ${VBM_DIR}/tissue_segmentation.py -o ${SAVE_PATH}  -s ${SAVE_PATH}/${NAME}.nii -type GM -info freesurfer

  ### remove converted nifti image
  rm ${SAVE_PATH}/${NAME}.nii
else
  echo "Input file format file is "$EXTENSION". Input file is assumed to be GM segmentation nifti."
  cp ${IMAGE_PATH} ${SAVE_PATH}/GM_${NAME}.nii
fi


cd ${SAVE_PATH}

### FSL registration to template + save Jacobian of transformation field
echo ${FSLDIR}/bin/fsl_reg ${SAVE_PATH}/GM_${NAME}.nii ${TEMPLATE} ${SAVE_PATH}/${NAME}_GM_to_template_GM -fnirt "--refmask=${VBM_DIR}/brain_mask_1mm.nii.gz --config=${CONFIG} --jout=${SAVE_PATH}/${NAME}_JAC_nl"
${FSLDIR}/bin/fsl_reg ${SAVE_PATH}/GM_${NAME}.nii ${TEMPLATE} ${SAVE_PATH}/${NAME}_GM_to_template_GM -fnirt "--refmask=${VBM_DIR}/brain_mask_1mm.nii.gz --config=${CONFIG} --jout=${SAVE_PATH}/${NAME}_JAC_nl"

### remove GM mask image
rm ${SAVE_PATH}/GM_${NAME}.nii

### Apply modulation on transformed image (multiply voxel values by log(JAC))
${FSLDIR}/bin/fslmaths ${SAVE_PATH}/${NAME}_GM_to_template_GM.nii.gz -mul ${SAVE_PATH}/${NAME}_JAC_nl ${SAVE_PATH}/${NAME}_GM_to_template_GM_mod -odt float
### Smooth final image by kernel -s "x" (mm) if needed
#${FSLDIR}/bin/fslmaths ${SAVE_PATH}/${NAME}_GM_to_template_GM_mod.nii.gz -s 3  ${SAVE_PATH}/${NAME}_GM_to_template_GM_mod_s3

### remove images which we do not need for VBM. Comment lines below if you want to keep them
rm ${SAVE_PATH}/${NAME}_GM_to_template_GM.nii.gz
rm ${SAVE_PATH}/${NAME}_GM_to_template_GM_warp.nii.gz
rm ${SAVE_PATH}/${NAME}_JAC_nl.nii.gz
