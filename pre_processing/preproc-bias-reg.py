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


def ants_bias_correction(antspath, sub_path, brain_no_skull, brain_bias_c):
    function='N4BiasFieldCorrection'
    command=[antspath+'/'+function, '-d', str(3), '-i', sub_path+'/'+brain_no_skull, '-o', sub_path+'/'+brain_bias_c]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def ants_registration(antspath, sub_path, brain_template, brain_bias_c, output_registration):
    function='antsRegistrationSyNQuick.sh'
    command=[antspath+'/'+function, '-f', sub_path+'/'+brain_bias_c, '-m', brain_template, 
             '-d', str(3), '-o', sub_path+'/'+output_registration, '-n', str(2)]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def ants_warp(antspath, sub_path, brain_bias_c, atlas_path, output_registration, affinemat, mask_output):
    function='antsApplyTransforms'
    command=[antspath+'/'+function, '-d', str(3), '-i', atlas_path, '-r', sub_path+'/'+brain_bias_c, 
            '-t', sub_path+'/'+output_registration+affinemat, '-o', sub_path+'/'+mask_output]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def mrtrix_normalization(mrtrixpath, sub_path, brain_bias_c, brain_template, prep_brain):
    function='mrhistmatch'
    command=[mrtrixpath+'/'+function, 'linear', sub_path+'/'+brain_bias_c, 
             brain_template, sub_path+'/'+prep_brain, '-force', '-nthreads', str(0)]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def preprocessing_function(args):
    subject_path, subject_id, antspath, mrtrixpath, brain_template_path, cortical_seg_path, sub_cortical_seg_path = args
    
    brain_no_skull='mprage_bet.nii.gz'
    brain_bias_c='mprage_bet_bias.nii.gz'
    output_registration='reg'
    pipeline_name='PreProc'
    affinemat='0GenericAffine.mat'
    elastic_cortical_output='cortical_mask.nii.gz'
    elastic_sub_output='subcortical_mask.nii.gz'
    prep_brain='mprage_bet_bias_hist.nii.gz'

    if not os.path.exists(subject_path+'/'+prep_brain):
        bc=ants_bias_correction(antspath, subject_path, brain_no_skull, brain_bias_c)
        reg=ants_registration(antspath, subject_path, brain_template_path, brain_bias_c, output_registration)
        cortical_warp=ants_warp(antspath, subject_path, brain_bias_c, 
                            cortical_seg_path, output_registration, affinemat, elastic_cortical_output)
        sub_cortical_warp=ants_warp(antspath, subject_path, brain_bias_c, 
                            sub_cortical_seg_path, output_registration, affinemat, elastic_sub_output)
        normalization=mrtrix_normalization(mrtrixpath, subject_path, brain_bias_c, brain_template_path, prep_brain)
        return [subject_id,bc,reg,cortical_warp,sub_cortical_warp,normalization]
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

    pool=multiprocessing.Pool(processes=15)
    constants=[ants_path,mrtrix_path,brain_template_path,cortical_seg_path,sub_cortical_seg_path]
    pool.map(preprocessing_function, [[paths[i]]+[subjects[i]]+constants for i in range(len(paths))])
    pool.close()
