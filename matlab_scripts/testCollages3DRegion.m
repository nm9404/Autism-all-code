clear all;
info_table=readtable('data_collages.csv');
subBand=72;

for i=1:height(info_table)
    data_row=info_table(i, :);
    dataset=cell2mat(data_row.DATASET);
    dx_col=cell2mat(data_row.DX_COLOQUIAL);
    corr_add=cell2mat(data_row.RUTA_CORREC);
    corr_seg=cell2mat(data_row.RUTA_SEG);
    image_fold=num2str(cell2mat(data_row.IMAGE_FILE));
    region=data_row.REGION;
    
    path_subject_vol=[pwd, '\Sujetos_Region_3D\', image_fold, '\', corr_add ];
    path_subject_seg_vol=[pwd, '\Sujetos_Region_3D\', image_fold, '\', corr_seg ];
    path_work=[pwd '\Sujetos_Region_3D\Prueba3D\' dataset '\' dx_col '\' image_fold '\'];
    mkdir(path_work);
    
    brain_vol_struct=load_nii(path_subject_vol);
    brain_vol=brain_vol_struct.img;
    
    seg_vol_struct=load_nii(path_subject_seg_vol);
    seg_vol=seg_vol_struct.img;
    
    [collage,recover_data]=getCollageImageSaving(brain_vol, seg_vol, region);
    imwrite(collage/(max(max(collage))),[path_work '\collage-original.png']);
    save([path_work '\recoverData.mat'], 'recover_data');
    
    collage_sub_band=getCollageOnBand([path_work '\collage-original.png'], 72);
    imwrite(collage_sub_band/(max(max(collage_sub_band))),[path_work '\collage-sub-band.png']);
    
    getCollageInverted([path_work '\recoverData.mat'], collage, path_subject_vol,[path_work '\invertedCollage.nii.gz']);
    getCollageInverted([path_work '\recoverData.mat'], abs(collage_sub_band), path_subject_vol,[path_work '\invertedCollageSubBand.nii.gz']);
end