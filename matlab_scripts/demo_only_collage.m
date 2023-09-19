
addpath('LibreriaNifti');
addpath('collage_utils');
%Demo corto para unicamente obtener el collage para una region
%region subcortical, region 9: left hippocampus
%ruta de imagenes de cerebro y segmentacion
brain_path='processed_pipeline_0th/ABIDE-I/Yale_50554.anat/T1_biascorr_brain.nii.gz';
subcortical_segmentation_path='processed_pipeline_0th/ABIDE-I/Yale_50554.anat/Elastic_SubCortical.nii.gz';
%abrir cerebro y segmentacion
brain_struc=load_nii(brain_path);
subc_struc=load_nii(subcortical_segmentation_path);
%obtener la imagen (volumenes) de ambas estructuras abiertas
brain_vol=brain_struc.img;
subcortical_segmentation=subc_struc.img;
%obtener collage
collage=getCollageImage(brain_vol, subcortical_segmentation, 9, 'axial', 5);
imwrite(collage/max(max(collage)), 'collagePrueba-padding.png');
collage=getCollageImage(brain_vol, subcortical_segmentation, 9, 'axial-transposed', 5);%queda en la carpeta de paquete
imwrite(collage/max(max(collage)), 'collageTransposedPrueba-padding.png');
%imshow(collage, []); %Descomentar para visualizar collage de ejemplo
collage=getCollageImage(brain_vol, subcortical_segmentation, 9, 'coronal', 5);%queda en la carpeta de paquete
imwrite(collage/max(max(collage)), 'collageCoronal-padding.png');
collage=getCollageImage(brain_vol, subcortical_segmentation, 9, 'sagital', 5);%queda en la carpeta de paquete
imwrite(collage/max(max(collage)), 'collageSagital-padding.png');