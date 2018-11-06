#!/bin/python

import nibabel as nb
import os

input_dir = '/home/julia/projects/fred_registration/Slice2_raw_nii/data'
output_dir = '/home/julia/projects/fred_registration/Slice2_raw_nii/registration'
rats = os.listdir(input_dir)

for rat in rats:
    os.mkdir(os.path.join(output_dir, rat))
    im1 = nb.load(os.path.join(input_dir, rat, 'im1.nii'))
    mask = nb.load(os.path.join(input_dir, rat, 'mask_{0}.nii.gz'.format(rat)))
    mask_new = nb.Nifti1Image(mask.get_data(), im1.affine, im1.header)
    nb.save(mask_new, os.path.join(output_dir, rat, 'mask_{0}_fixed_hdr.nii.gz'.format(rat)))
