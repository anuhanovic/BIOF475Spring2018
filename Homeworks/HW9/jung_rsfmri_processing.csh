#!/bin/tcsh

#Variable Input
set in_files = $1
set out_dir = $2
set subject = $3
set session = $4

cd $in_files


set root_dir = `dirname $0`
set debug = 1
set script_dir = "/data/NIMH_LBC_49ers/resting_state/Rest_Atlas/scripts"

set site_name = `basename ${in_files}`

#Define wildcard strings
set anat_str = "anat/sub-*_ses-*_run*.nii.gz"


#Make root out
set root_out = ${out_dir}/${site_name}
mkdir ${root_out}

#Change to input subject directory
cd ${in_files}/${subject}

#Make Subject output directory
set out = ${root_out}/${subject}
mkdir ${out}

#Change to input session directory
set session = ${session}
cd ${session}

#Make Session output directory
set out_ses = ${root_out}/${subject}${session}
mkdir ${out_ses}
#Remove preexisting output data
if ( -d ${out_ses}imreg/ ) then
	rm -r ${out_ses}imreg/
endif
if ( -d ${out_ses}motion/ ) then
	rm -r ${out_ses}motion/
endif
if ( -f ${out_ses}dfile.rall.1D ) then
	rm ${out_ses}dfile.rall.1D
endif

#Make directories for outputing data
mkdir ${out_ses}anat
mkdir ${out_ses}imreg

#Set reference anatomy to the data that was aligned in NMT_subject_align.csh
set anat = "${out_ses}anat/anat.nii.gz"

#Check to make sure session actually has a T1w and rs-fMRI directory
if ( -d anat/ ) then
	echo "Anatomy data exists. Continuing."
else
	echo "Anatomy data does not exist. Skipping"
	exit
endif
if ( -d func/ ) then
	echo "Functional data exists. Continuing."
else
	echo "Functional data does not exist. Skipping"
	exit
endif


#Change to image registration output directory
cd ${out_ses}imreg/	

#Copy over necessary anatomy files
cp ../anat/anat_N4.nii.gz ./
cp ../anat/mask_in_anat_N4.nii.gz ./
cp ${script_dir}/template/NMT_symmetric_stereotax.nii.gz ../anat/


#Get input functional rs-fMRIscans
set epi_str = "${in_files}/${subject}${session}func/sub-*_ses-*_task-resting_run-*.nii.gz"
set epis = `ls ${epi_str}`
echo ${epis}
echo "----------------"

#Align all anats in session to NMT
python ${script_dir}/NeoImreg-v2.07.py -e ${epis} -m mask_in_anat_N4.nii.gz -low anat_N4.nii.gz --nifti -NMT ../anat/ --ss_anat -e2l affine
set al_files = `ls *_al2NMT.nii.gz`
rm ${in_files}/${subject}/${session}/func/*.BRIK
rm ${in_files}/${subject}/${session}/func/*.HEAD

#Concatonate motion files
mv motion/ ../ #move to base out
cd ../motion/
set motion_files = `ls *_motion.1D`
echo $motion_files
python ${script_dir}/cat_motion_1.1.py -m ${motion_files} -c 4
mv dfile.rall.1D ../ #move to base out

#Resample wm mask
cd ..
3dresample -master imreg/master_grid_NMT+orig.BRIK -prefix NMTss_WM_mask_resampled.nii.gz -input ${script_dir}/NMTss_WM_mask_reduced.nii.gz
3dresample -master imreg/master_grid_NMT+orig.BRIK -prefix NMTss_brainmask_resampled.nii.gz -input ${script_dir}/NMTss_brainmask_mirrored.nii.gz

#AFNI Proc: Preprocessing and Processing

#Remove unnecessary files to save space
rm imreg/anat_N4.nii.gz
rm imreg/anat_N4+orig*
rm imreg/mask_in_anat_N4+orig*
rm anat/NMT_symmetric_stereotax.nii.gz

#Generate subject name
set sub_name = `echo ${subject} | cut -d / -f 1-1`_`echo ${session} | cut -d / -f 1-1`

#Remove existing output directory for afni_proc.py
if ( -d ${sub_name}.results/ ) then
	rm -r ${sub_name}.results/
endif
if ( -f proc.${sub_name} ) then
	rm proc.${sub_name}
endif

#Run afni_proc.py for all aligned rs-fMRI scans.
afni_proc.py -subj_id ${sub_name} -dsets imreg/*_al2NMT.nii.gz \
   -copy_anat imreg/master_grid_NMT+orig			     \
   -blocks despike regress			     \
   -tcat_remove_first_trs 4                                   \
   -regress_motion_file dfile.rall.1D			     \
   -regress_censor_motion 0.2                                 \
   -regress_censor_outliers 0.1                               \
   -regress_bandpass 0.01 0.1                                 \
   -regress_apply_mot_types demean deriv                      \
   -anat_follower_ROI brain epi NMTss_brainmask_resampled.nii.gz 		\
   -anat_follower_ROI WM epi NMTss_WM_mask_resampled.nii.gz		\
   -regress_anaticor_label WM 						\
   -regress_anaticor_fast
#  -regress_est_blur_epits                                    \
#  -regress_est_blur_errts

tcsh -xef proc.${sub_name} |& tee output.proc.${sub_name}

#Convert from AFNI BRIK/HEAD to NIFTI format to save space
sh ${script_dir}/brik_to_nifti.sh ${sub_name}.results/

#Remove Extra files
rm ${sub_name}.results/Local_WM_rall.nii.gz
rm NMTss_WM_mask_resampled.nii.gz
rm NMTss_brainmask_resampled.nii.gz

