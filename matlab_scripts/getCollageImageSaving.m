function [y, recoverData] = getCollageImageSaving(brain_vol, segmentationVolume, regionNumber)
%UNTITLED3 Summary of this function goes here
    %   Detailed explanation goes here
    [h,w,k]=size(brain_vol);
    region_slices={};
    region_slices_sizes={};
    verticalSizes=[];
    horizontalSizes=[];
    itHeight=[];
    %Crear cell array con unicamente los cortes donde hay informacion de la
    %region
    counter=1;
    for i=1:k
        lut = double(squeeze(segmentationVolume(:,:,i)));
        slice = double(squeeze(brain_vol(:,:,i)));
        if (sum(sum(regionCrop(regionNumber,slice,lut,h,w)))>0)
            [region_slices{counter}, data{counter}]=regionCropSaving(regionNumber,slice,lut,h,w);
            region_slices_sizes{counter}=size(region_slices{counter});
            slice_cut(counter)=i;
            counter=counter+1;
        end
    end
    disp(counter);

    %Crear suma
    [~, wc] = size(region_slices_sizes);
    for i=1:wc
        regionSize=region_slices_sizes{1,i};
        verticalSizes(i)=regionSize(1);
        horizontalSizes(i)=regionSize(2);
    end

    %Generar Imagen Grande
    hco=max(verticalSizes);
    wco=sum(horizontalSizes);

    %Generar dimensiones cuadradas con algunos pixeles sobrantes con ceil
    factor = sqrt(wco)./sqrt(hco);
    wco=ceil(wco./factor);
    hco=ceil(hco./factor);

    acumW=0;
    acumH=0;
    counter=1;

    collageImage=zeros(hco,wco);

    for i=1:wc
        slice=region_slices{1,i};
        
        slice_data=data{i};
        
        rows=slice_data(1):slice_data(2);
        cols=slice_data(3):slice_data(4);
        slice_real_num=slice_cut(i);
        
        [hs, ws]=size(slice);
        recoverSizesSlices{i}=[hs ws];
        for j=1:hs
            for k=1:ws
                collageImage(j+acumH,k+acumW)=slice(j,k);
                collageImageRec{j+acumH, k+acumW}=[rows(j), cols(k), slice_real_num];
            end
        end
        itHeight(counter)=hs;
        acumW=acumW+ws;
        counter=counter+1;
        if acumW>wco
            acumH=acumH+max(itHeight);
            itHeight=[];
            counter=1;
            acumW=0;
        end
    end
recover{1}=data;
recover{2}=recoverSizesSlices;
recover{3}=slice_cut;
recover{4}=collageImageRec;
recoverData=recover;
y = collageImage;
end

