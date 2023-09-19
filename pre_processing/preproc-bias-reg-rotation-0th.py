import pandas as pd
import subprocess
import multiprocessing
import os
from preprocessing_utils import VolumePreprocessing

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

def ants_registration_template_move(antspath, sub_path, brain_template, name_subject_file, output_registration):
    function='antsRegistrationSyNQuick.sh'
    command=[antspath+'/'+function, '-f', sub_path+'/'+name_subject_file, '-m', brain_template, 
             '-d', str(3), '-o', sub_path+'/'+output_registration, '-n', str(2)]
    comp_process=subprocess.run(command)
    return comp_process.returncode

def ants_registration(antspath, sub_path, moving_image, fixed_image, output_registration, register_type, template_flag=True):
    function='antsRegistrationSyNQuick.sh'
    if template_flag:
        command=[antspath+'/'+function, '-f', fixed_image, '-m', sub_path+'/'+moving_image, 
             '-d', str(3), '-o', sub_path+'/'+output_registration, '-n', str(2), '-t', register_type]
    else:
        command=[antspath+'/'+function, '-f', sub_path+'/'+fixed_image, '-m', sub_path+'/'+moving_image, 
             '-d', str(3), '-o', sub_path+'/'+output_registration, '-n', str(2), '-t', register_type]
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

def delete_file(sub_path, filename):
    os.remove(sub_path+'/'+filename)
    return True

def preprocessing_function(args):
    subject_path, subject_id, center_id, dataset, antspath, mrtrixpath, brain_template_path, cortical_seg_path, sub_cortical_seg_path = args

    
    brain_no_skull='mprage_bet.nii.gz'
    brain_bias_c='mprage_bet_bias.nii.gz'
    output_registration='reg'
    output_rigid_template='rigid_reg_temp'
    output_rigid_resampled='rigid_reg_sub'
    pipeline_name='PreProc'
    affinemat='0GenericAffine.mat'
    elastic_cortical_output='cortical_mask.nii.gz'
    elastic_sub_output='subcortical_mask.nii.gz'
    prep_brain='mprage_bet_bias_hist.nii.gz'
    resampling_output='mprage_resampled.nii.gz'
    rotation_corected_output='mprage_resample_rot_corrected.nii.gz'
    dummy_condition = 'dummy.nii.gz'

    if dataset == 'ABIDE-I':
        files_to_delete = ['c1mprage.nii', 'c2mprage.nii', 'c3mprage.nii',
        'c4mprage.nii', 'c5mprage.nii']

    if dataset == 'ABIDE-II':
        files_to_delete = ['c1anat.nii', 'c2anat.nii', 'c3anat.nii',
        'c4anat.nii', 'c5anat.nii']
	
    if not os.path.exists(subject_path):
        return 0

    if not os.path.exists(subject_path+'/'+elastic_sub_output):
        # 1. Bias correction with N4 Method
        print('initializing...'+' '+dataset+' '+center_id+' '+str(subject_id))
        bc=ants_bias_correction(antspath, subject_path, brain_no_skull, brain_bias_c)

        # 2. Resampling
        print('computing resampling')
        preprocessing_object = VolumePreprocessing(volume_path=subject_path+'/'+brain_bias_c)
        preprocessing_object.resample_subject(output=subject_path+'/'+resampling_output)

        # 3. Rigid registration from resampled-subject to template
        print('computing first registration')
        rigid_1 = ants_registration(antspath, subject_path, resampling_output, brain_template_path, output_rigid_template,
            register_type='r')

        # 4. Rigid registration from 3) to resampled-sbuject space
        #print('computing second registration')
        #rigid_2 = ants_registration(antspath, subject_path, output_rigid_template+'Warped.nii.gz', 
        #    resampling_output, output_rigid_resampled, register_type='t', template_flag=False)

        # 5. Rotation correction
        #print('computing rotation correction')
        #print(subject_path+'/'+elastic_sub_output)
        #print(os.exists(subject_path+'/'+elastic_sub_output))
        #preprocessing_object.set_template_path(subject_path+'/'+output_rigid_resampled+'Warped.nii.gz')
        #rotation = preprocessing_object.correct_subject_rotation(in_path=subject_path+'/'+resampling_output, 
        #    out_path=subject_path+'/'+rotation_corected_output)

        # 6. Registration from template to corrected volume and warps...
        reg=ants_registration_template_move(antspath, subject_path, brain_template_path, 
            output_rigid_template+'Warped.nii.gz', output_registration)

        cortical_warp=ants_warp(antspath, subject_path, output_rigid_template+'Warped.nii.gz', 
                            cortical_seg_path, output_registration, affinemat, elastic_cortical_output)

        sub_cortical_warp=ants_warp(antspath, subject_path, output_rigid_template+'Warped.nii.gz', 
                            sub_cortical_seg_path, output_registration, affinemat, elastic_sub_output)
        #normalization=mrtrix_normalization(mrtrixpath, subject_path, rotation_corected_output, brain_template_path, prep_brain)

        print('clearing_files...')

        #_ = [delete_file(subject_path, file) for file in files_to_delete]

        #print([subject_id,center_id,dataset]+rotation)
        return [subject_id,center_id,dataset]
    else:
        print('just deleting files... ')
        print(files_to_delete)
        for file in files_to_delete:
            try:
                delete_file(subject_path, file)
            except:
                print(str(file) + ' does not exist in ' + str(subject_path))
        return [0,0,0,0]


if __name__=='__main__':
    data_file_path='/mnt/md0/nmunerag/Autismo/TABLA_CENTROS_MAQUINA_CORREC_PROC.csv'
    processed_path='/mnt/md0/nmunerag/ABIDE_PREP_0'
    brain_template_path='/mnt/md0/nmunerag/Herramientas/atlas/MNI152_T1_1mm_brain.nii.gz'
    cortical_seg_path='/mnt/md0/nmunerag/Herramientas/atlas/HarvardOxford-cortl-maxprob-thr0-1mm.nii.gz'
    sub_cortical_seg_path='/mnt/md0/nmunerag/Herramientas/atlas/HarvardOxford-sub-maxprob-thr0-1mm.nii.gz'
    ants_path='/bin/ants/bin'
    pipeline_name='pip-spm-ants-rotation'
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
    centers=data['SITE_ID'].values
    datasets=data['DATASET'].values

    pool=multiprocessing.Pool(processes=17)
    constants=[ants_path,mrtrix_path,brain_template_path,cortical_seg_path,sub_cortical_seg_path]
    _ = pool.map(preprocessing_function, [[paths[i]]+[subjects[i]]+[centers[i]]+[datasets[i]]+constants for i in range(len(paths))])
    #print(rotations)
    #pd.DataFrame(rotations, columns=['subject_id', 'center_id', 'dataset', 'rot_sagital', 'rot_coronal', 'rot_axial']).to_csv('rotation_results.csv', index=False)
    pool.close()
