My current project is to integrate resting state and anatomical MRI data from the newly released [PRIME-DE Repository](http://fcon_1000.projects.nitrc.org/indi/indiPRIME.html)
I will be all data to a standard anatomical template, the [NIMH Macaque Template](https://github.com/jms290/NMT). 

From there, my goals are two-fold:
1. Use anatomical MRIs to improve the quality of our NIMH Macaque Template
2. Use resting state fMRI (rsfMRI) to create a cross-species correlation matrix of anatomical ROIs from the [D99 Macaque Atlas](https://afni.nimh.nih.gov/Macaque)

Current difficulties I am dealing with include:
+ Variable Data:
  + Integrating MRI data from multiple scan sites and multiple scanners.
  + Because each site provides different resources, I must create a pipeline that can handle all MRI data.
+ Preprocessing
  + Some sites include files needed for certain types of pre-processing. Others do not.
  + I am currently trying to determine whether it is better to use some preprocessing methods on a subset of data, or to preprocess all data the same way.
+ Computation Resources:
  + Each scan session from each subject can take an upwards of 12 hours to process on HPC clusters like Biowulf.
  + Biowulf's swarm capability has allowed for large-scale processing of the data.
