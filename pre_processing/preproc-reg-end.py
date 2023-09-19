import pandas as pd
import subprocess
import multiprocessing
import os

def dataset_name_cor(dataset):
    dataset_split=dataset.split('-')
    return dataset_split[0]+dataset_split[1]

def create_path(sub_id, site_id, dataset, proc_path, pipeline_name):
    dataset_c=dataset_name_cor(dataset)
    path=''
    if dataset_c=='ABIDEI':
        path=proc_path+'/'+dataset_c+'/'+site_id+'_'+str(sub_id)+'/'+pipeline_name
    elif dataset_c =='ABIDEII':
        path=proc_path+'/'+dataset_c+'/'+dataset_c+'-'+site_id+'/'+str(sub_id)+'/'+pipeline_name
    return path

def ants_registration(antspath, sub_path, moving_image, fixed_image, output_registration, register_type):
    function='antsRegistrationSyNQuick.sh'
    command=[antspath+'/'+function, '-f', fixed_image, '-m', sub_path+'/'+moving_image, 
             '-d', str(3), '-o', sub_path+'/'+output_registration, '-n', str(2), '-t', register_type]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def ants_registration_template_move(antspath, sub_path, moving_image, fixed_image, output_registration):
    function='antsRegistrationSyNQuick.sh'
    command=[antspath+'/'+function, '-f', sub_path+'/'+fixed_image, '-m', moving_image, 
             '-d', str(3), '-o', sub_path+'/'+output_registration, '-n', str(2)]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def ants_warp(antspath, sub_path, brain_bias_c, atlas_path, output_registration, affinemat, mask_output):
    function='antsApplyTransforms'
    command=[antspath+'/'+function, '-d', str(3), '-i', sub_path+'/'+atlas_path, '-r', sub_path+'/'+brain_bias_c, 
            '-t', sub_path+'/'+output_registration+affinemat, '-o', sub_path+'/'+mask_output]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def ants_warp_atlas(antspath, sub_path, brain_bias_c, atlas_path, output_registration, affinemat, mask_output):
    function='antsApplyTransforms'
    command=[antspath+'/'+function, '-d', str(3), '-i', atlas_path, '-r', sub_path+'/'+brain_bias_c, 
            '-t', sub_path+'/'+output_registration+affinemat, '-o', sub_path+'/'+mask_output]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def preprocessing_function(args):
    subject_path, subject_id, antspath, mrtrixpath, brain_template_path, cortical_seg_path, sub_cortical_seg_path = args
    
    
    brain_bias_c='mprage_bet_bias.nii.gz'
    cortical_mask = 'cortical_mask.nii.gz'
    subcortical_mask = 'subcortical_mask.nii.gz'

    output_rigid_registration='rigid_reg'
    output_affine_registration='affine_reg'
    affinemat='0GenericAffine.mat'
    rigid_cortical_output='rigid_cortical_mask.nii.gz'
    affine_cortical_output='affine_cortical_mask.nii.gz'
    rigid_sub_output='rigid_subcortical_mask.nii.gz'
    affine_sub_output='affine_subcortical_mask.nii.gz'
    prep_brain='mprage_bet_bias_hist.nii.gz'

    atlas_reg_for_rig = 'atlas_rigid_reg'
    atlas_reg_for_affine = 'atlas_affine_reg'

    if not os.path.exists(subject_path+'/'+affine_sub_output):
        #bc=ants_bias_correction(antspath, subject_path, brain_no_skull, brain_bias_c)
        rig_reg = ants_registration(antspath, subject_path, brain_bias_c, brain_template_path, 
        	output_rigid_registration, 'r')

        atlas_reg_rig = ants_registration_template_move(antspath, subject_path, brain_template_path,   
            output_rigid_registration+'Warped.nii.gz', atlas_reg_for_rig)

        rig_cortical_warp = ants_warp_atlas(antspath, subject_path, output_rigid_registration+'Warped.nii.gz', cortical_seg_path, 
        	atlas_reg_for_rig, affinemat, rigid_cortical_output)

        rig_subcortical_warp = ants_warp_atlas(antspath, subject_path, output_rigid_registration+'Warped.nii.gz', 
        	sub_cortical_seg_path, atlas_reg_for_rig, affinemat, rigid_sub_output)



        af_reg = ants_registration(antspath, subject_path, output_rigid_registration+'Warped.nii.gz', brain_template_path, 
        	output_affine_registration, 'a')

        atlas_af_rig = ants_registration_template_move(antspath, subject_path, 
            brain_template_path, output_affine_registration+'Warped.nii.gz', atlas_reg_for_affine)

        af_cortical_warp = ants_warp_atlas(antspath, subject_path, output_affine_registration+'Warped.nii.gz', cortical_seg_path, 
            atlas_reg_for_affine, affinemat, affine_cortical_output)

        af_subcortical_warp = ants_warp_atlas(antspath, subject_path, output_affine_registration+'Warped.nii.gz', 
            sub_cortical_seg_path, atlas_reg_for_affine, affinemat, affine_sub_output)
        

        return [subject_id,rig_reg,atlas_reg_rig,rig_cortical_warp,rig_subcortical_warp,af_reg,atlas_af_rig,af_cortical_warp,af_subcortical_warp]
    else:
        return [0,0,0,0,0]

if __name__=='__main__':
    data_file_path='/mnt/md0/nmunerag/Autismo/TABLA_CENTROS_MAQUINA_CORREC_PROC.csv'
    processed_path='/mnt/md0/ABIDE_PREP'
    brain_template_path='/mnt/md0/nmunerag/Herramientas/atlas/MNI152_T1_1mm_brain.nii.gz'
    cortical_seg_path='/mnt/md0/nmunerag/Herramientas/atlas/HarvardOxford-cortl-maxprob-thr25-1mm.nii.gz'
    sub_cortical_seg_path='/mnt/md0/nmunerag/Herramientas/atlas/HarvardOxford-sub-maxprob-thr25-1mm.nii.gz'
    ants_path='/bin/ants/bin'
    pipeline_name='pip-spm-ants'
    mrtrix_path='/mnt/md0/mrtrix3/bin'

    elastic_cortical_output='cortical_mask.nii.gz'
    elastic_sub_output='subcortical_mask.nii.gz'
    prep_brain='mprage_bet_bias_hist.nii.gz'

    data=pd.read_csv(os.path.normpath(data_file_path), delimiter=';', 
        dtype={'SUB_ID':int, 'SITE_ID':str, 'DATASET':str, 
        'DX_GROUP':int, 'GENERO':int, 'CENTRO_NOMBRE':str, 'MAQUINA':str, 
        'POTENCIA_MAQUINA':str, 'TAM_VOXEL':str ,'EDAD':float})

    paths=[create_path(row[0], row[1], row[2], processed_path, pipeline_name) for row in data[['SUB_ID','SITE_ID','DATASET']].values]
    subjects=data['SUB_ID'].values

    pool=multiprocessing.Pool(processes=8)
    constants=[ants_path,mrtrix_path,brain_template_path,cortical_seg_path,sub_cortical_seg_path]
    pool.map(preprocessing_function, [[paths[i]]+[subjects[i]]+constants for i in range(len(paths))])
    pool.close()