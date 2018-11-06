#!/bin/bash

#!/bin/bash

rat_fixed=7
rats_moving='5 13 14 15 20 21 22'

input_dir=/home/julia/projects/fred_registration/data/
output_dir=/home/julia/projects/fred_registration/registration_nonlinear/

mkdir ${output_dir}rat${rat_fixed}
fixed=rat${rat_fixed}/im1

echo "Bias field correction fixed image"
N4BiasFieldCorrection --image-dimensionality 2 \
        --convergence [100x100x100x100,0.0] \
        --input-image ${input_dir}${fixed}.nii\
        --output ${output_dir}${fixed}_corrected.nii.gz\

for rat_moving in $rats_moving
do
    mkdir ${output_dir}rat${rat_moving}
    moving=rat${rat_moving}/im1

    echo "Bias field correction moving image rat $rat_moving"
    N4BiasFieldCorrection --image-dimensionality 2 \
            --convergence [100x100x100x100,0.0] \
            --input-image ${input_dir}${moving}.nii\
            --output ${output_dir}${moving}_corrected.nii.gz\

    echo "Registration"
    antsRegistration --dimensionality 2 --float 0 \
            --collapse-output-transforms 1 \
            --output [${output_dir}${moving}_, ${output_dir}${moving}_nonlin.nii.gz ]\
            --interpolation WelchWindowedSinc \
            --collapse-output-transforms 1 \
            --winsorize-image-intensities [0.005,0.995] \
            --use-histogram-matching 0 \
            --initial-moving-transform [${output_dir}${fixed}_corrected.nii.gz,${output_dir}${moving}_corrected.nii.gz,1] \
            --transform Rigid[0.1] \
            --metric MI[${output_dir}${fixed}_corrected.nii.gz,${output_dir}${moving}_corrected.nii.gz,1,32,Regular,0.25] \
            --convergence [1000x500x250x100,1e-6,10] \
            --shrink-factors 8x4x2x1 \
            --smoothing-sigmas 1.5x1x0.5x0 \
            --transform Affine[0.1] \
            --metric MI[${output_dir}${fixed}_corrected.nii.gz,${output_dir}${moving}_corrected.nii.gz,1,32,Regular,0.25] \
            --convergence [1000x500x250x100,1e-6,10] \
            --shrink-factors 8x4x2x1 \
            --smoothing-sigmas 1.5x1x0.5x0 \
            --transform SyN[0.1,3,0] \
            --metric CC[${output_dir}${fixed}_corrected.nii.gz,${output_dir}${moving}_corrected.nii.gz,1,4] \
            --convergence [100x70x50x20,1e-6,10] \
            --shrink-factors 8x4x2x1 \
            --smoothing-sigmas 1.5x1x0.5x0

    for image in {2..34}
    do
    echo "Apply transform $image"
    antsApplyTransforms --dimensionality 2 --input-image-type 0 \
            --input ${input_dir}/rat${rat_moving}/im${image}.nii \
            --reference-image ${output_dir}${fixed}_corrected.nii.gz \
            --output ${output_dir}/rat${rat_moving}/im${image}_nonlin.nii.gz \
            --transform [${output_dir}${moving}_0GenericAffine.mat] \
            --interpolation WelchWindowedSinc
    done

done
