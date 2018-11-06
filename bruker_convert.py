#!/bin/python

import os
from glob import glob
from bruker2nifti.converter import Bruker2Nifti

data_in = '/home/julia/projects/lc/20180808_162705_JH_lc_anatomy_02_1_2'
data_out = '/home/julia/projects/lc/20180808_162705_JH_lc_anatomy_02_1_2_nifti'

if not os.path.isdir(data_out):
    os.mkdir(data_out)

bru = Bruker2Nifti(data_in, data_out, study_name="")

print(bru.scans_list)
print(bru.list_new_name_each_scan)

bru.convert()
