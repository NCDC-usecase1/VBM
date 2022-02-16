
#Prepare working directory
IMAGE=$1
OUTPUT=$2

mkdir -p $OUTPUT/QC
mkdir -p $OUTPUT/nparray
mkdir -p $OUTPUT/np_logs


# Convert niftis to nparrays 

for i in $(seq 0 118);
do
    python3 nii2np.py -i $IMAGE -o $OUTPUT/nparray -atlas ./brain_vbm_atlas.nii.gz -logs $OUTPUT/np_logs -code $i
done

# Do QCs

# QC with mode region: Threshold recommended to be 10

for i in $(seq 0 118);
do
    python3 QC_vbm_reg.py  -mode region -i $OUTPUT/nparray -o $OUTPUT/QC -logs $OUTPUT/np_logs -code $i -q 10
done

# run QC with mode summary
python3 QC_vbm_reg.py  -mode summary -i $OUTPUT/nparray -o $OUTPUT/QC -logs $OUTPUT/np_logs -q 10
