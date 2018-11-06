#!/bin/bash

rat_fixed='r6'
rats_moving='r9'
# Slice 1
# rats_moving='r3 r4 r5 r6 r7 r8 r9 r10 r11 r13 r14 r15 r17 rr5 rr7 rr9 rr11 rr12 rr13 rr14 rr15 rr16 rr17 rr18 rr19 rr20 rr21 rr22 rr24 rr27 rr28 rr29 rr30 rr31 rr32 rr35 rr36 rr38'
# Slice 2
# rats_moving='r3 r4 r6 r8 r9 r10 r11 r14 r15 r17 rr5 rr7 rr11 rr12 rr13 rr14 rr15 rr16 rr17 rr18 rr19 rr20 rr21 rr22 rr24 rr27 rr28 rr29 rr30 rr31 rr32 rr33 rr34 rr35 rr36 rr38'
# Slice 3
# rats_moving='r17 r4 rr13 rr15 rr21 rr29 rr5 r3 r5 r9 rr14 rr20 rr22 rr30 rr7 r11 r15 r16 r19 r20 r21 rr11 rr12 rr33 rr34 rr38 r13 r14 r22 r7 r8 rr16 rr17 rr18 rr19 rr24 rr28 rr31 rr32'

input_dir=/home/julia/projects/fred_registration/Slice2_raw_nii/data/
output_dir=/home/julia/projects/fred_registration/Slice2_raw_nii/registration/

#mkdir ${output_dir}${rat_fixed}

echo "Masking fixed image"
fsl5.0-fslmaths ${input_dir}${rat_fixed}/im1.nii -mul ${output_dir}${rat_fixed}/mask_${rat_fixed}_fixed_hdr.nii.gz ${output_dir}${rat_fixed}/im1_masked.nii.gz

echo "Bias field correction fixed image"
N4BiasFieldCorrection --image-dimensionality 2 \
        --convergence [100x100x100x100,0.0] \
        --input-image ${output_dir}${rat_fixed}/im1_masked.nii.gz \
        --output ${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz \

echo "Copying fixed image data to output folder"
cp ${input_dir}${rat_fixed}/im* ${output_dir}${rat_fixed}

for rat_moving in $rats_moving
do
    # mkdir ${output_dir}${rat_moving}

    echo "Masking moving image $rat_moving"
    fsl5.0-fslmaths ${input_dir}${rat_moving}/im1.nii -mul ${output_dir}${rat_moving}/mask_${rat_moving}_fixed_hdr.nii.gz ${output_dir}${rat_moving}/im1_masked.nii.gz

    echo "Bias field correction moving image rat $rat_moving"
    N4BiasFieldCorrection --image-dimensionality 2 \
            --convergence [100x100x100x100,0.0] \
            --input-image ${output_dir}${rat_moving}/im1_masked.nii.gz \
            --output ${output_dir}${rat_moving}/im1_masked_corrected.nii.gz \

    echo "Affine registration rat $rat_moving"
    antsRegistration --dimensionality 2 --float 0 \
            --collapse-output-transforms 1 \
            --output [${output_dir}${rat_moving}/${rat_moving}_, ${output_dir}${rat_moving}/im1_masked_corrected_aff.nii.gz ]\
            --interpolation WelchWindowedSinc \
            --collapse-output-transforms 1 \
            --winsorize-image-intensities [0.005,0.995] \
            --use-histogram-matching 0 \
            --initial-moving-transform [${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1] \
            --transform Rigid[0.1] \
            --metric MI[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,32,Regular,0.25] \
            --convergence [1000x500x250x100,1e-6,10] \
            --shrink-factors 8x4x2x1 \
            --smoothing-sigmas 1.5x1x0.5x0 \
            --transform Affine[0.1] \
            --metric MI[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,32,Regular,0.25] \
            --convergence [1000x500x250x100,1e-6,10] \
            --shrink-factors 8x4x2x1 \
            --smoothing-sigmas 1.5x1x0.5x0


      echo "7DOF registration rat $rat_moving"
      antsRegistration --dimensionality 2 --float 0 \
              --collapse-output-transforms 1 \
              --output [${output_dir}${rat_moving}/${rat_moving}_sim_, ${output_dir}${rat_moving}/im1_masked_corrected_sim.nii.gz ]\
              --interpolation WelchWindowedSinc \
              --collapse-output-transforms 1 \
              --winsorize-image-intensities [0.005,0.995] \
              --use-histogram-matching 0 \
              --initial-moving-transform [${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1] \
              --transform Rigid[0.1] \
              --metric MI[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,32,Regular,0.25] \
              --convergence [1000x500x250x100,1e-6,10] \
              --shrink-factors 8x4x2x1 \
              --smoothing-sigmas 1.5x1x0.5x0 \
              --transform Similarity[0.1] \
              --metric MI[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,32,Regular,0.25] \
              --convergence [1000x500x250x100,1e-6,10] \
              --shrink-factors 8x4x2x1 \
              --smoothing-sigmas 1.5x1x0.5x0

      # echo "Nonlinear registration rat $rat_moving"
      # antsRegistration --dimensionality 2 --float 0 \
      #         --collapse-output-transforms 1 \
      #         --output [${output_dir}${rat_moving}/${rat_moving}_, ${output_dir}${rat_moving}/im1_masked_corrected_nonlin.nii.gz ]\
      #         --interpolation WelchWindowedSinc \
      #         --collapse-output-transforms 1 \
      #         --winsorize-image-intensities [0.005,0.995] \
      #         --use-histogram-matching 0 \
      #         --initial-moving-transform [${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1] \
      #         --transform Rigid[0.1] \
      #         --metric MI[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,32,Regular,0.25] \
      #         --convergence [1000x500x250x100,1e-6,10] \
      #         --shrink-factors 8x4x2x1 \
      #         --smoothing-sigmas 1.5x1x0.5x0 \
      #         --transform Affine[0.1] \
      #         --metric MI[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,32,Regular,0.25] \
      #         --convergence [1000x500x250x100,1e-6,10] \
      #         --shrink-factors 8x4x2x1 \
      #         --smoothing-sigmas 1.5x1x0.5x0 \
      #         --transform SyN[0.1,3,0] \
      #         --metric CC[${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz,${output_dir}${rat_moving}/im1_masked_corrected.nii.gz,1,4] \
      #         --convergence [100x70x50x20,1e-6,10] \
      #         --shrink-factors 8x4x2x1 \
      #         --smoothing-sigmas 1.5x1x0.5x0

    for image in {1..34}
    do
    echo "Apply affine transforms $image"
    antsApplyTransforms --dimensionality 2 --input-image-type 0 \
            --input ${input_dir}${rat_moving}/im${image}.nii \
            --reference-image ${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz \
            --output ${output_dir}${rat_moving}/im${image}_aff.nii.gz \
            --transform [${output_dir}${rat_moving}/${rat_moving}_0GenericAffine.mat] \
            --interpolation WelchWindowedSinc

    echo "Apply similarity transforms $image"
    antsApplyTransforms --dimensionality 2 --input-image-type 0 \
            --input ${input_dir}${rat_moving}/im${image}.nii \
            --reference-image ${output_dir}${rat_fixed}/im1_masked_corrected.nii.gz \
            --output ${output_dir}${rat_moving}/im${image}_sim.nii.gz \
            --transform [${output_dir}${rat_moving}/${rat_moving}_sim_0GenericAffine.mat] \
            --interpolation WelchWindowedSinc
    # echo "Apply nonlinear transforms $image"
    # antsApplyTransforms --dimensionality 2 --input-image-type 0 \
    #         --input ${input_dir}${rat_moving}/im${image}.nii \
    #         --reference-image ${input_dir}${rat_fixed}/im1.nii \
    #         --output ${output_dir}${rat_moving}/im${image}_nonlin.nii.gz \
    #         --transform [${output_dir}${rat_moving}/${rat_moving}_1Warp.nii.gz] \
    #         --transform [${output_dir}${rat_moving}/${rat_moving}_0GenericAffine.mat] \
    #         --interpolation WelchWindowedSinc
    done

done
