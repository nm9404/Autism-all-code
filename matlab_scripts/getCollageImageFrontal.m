function y = getCollageImageFrontal(brain_vol, segmentationVolume, regionNumber, padding)
%Con esta función se obtiene el collage de la imagen
    %   brain_vol: volumen del cerebro de dimensiones mxnxk
    %   segmentationVolume: volumen de segmentacion para brain_vol de dimensiones mxnxk
    %   regionNumber: número de region, en este caso (HO) 
    % va de 1 a 96 para regiones corticales y 1 a 21 para subcorticales
    [h,w,k]=size(brain_vol);

    %Crear cell array con unicamente los cortes donde hay informacion de la
    %region
    counter=1;
    for i=1:h
        lut = double(squeeze(segmentationVolume(i,:,:)))';
        slice = double(squeeze(brain_vol(i,:,:)))';
        [hk, wk]=size(slice);
        if (sum(sum(regionCrop(regionNumber,slice,lut,hk,wk)))>0)
            slice_crop=regionCrop(regionNumber,slice,lut,hk,wk);
	    slice_crop_dims=size(slice_crop);
            region_slices{counter}=insertMatrix(zeros(slice_crop_dims(1)+2*padding,...
		 slice_crop_dims(2)+2*padding), slice_crop);
            region_slices_sizes{counter}=size(region_slices{counter});
            counter=counter+1;
        end
    end

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
    factor = sqrt(wco)/sqrt(hco);
    wco=ceil(wco/factor);
    hco=ceil(hco/factor);

    acumW=0;
    acumH=0;
    counter=1;

    collageImage=zeros(hco,wco);

    for i=1:wc
        slice=region_slices{1,i};
        [hs, ws]=size(slice);
        for j=1:hs
            for k=1:ws
                collageImage(j+acumH,k+acumW)=slice(j,k);
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
[hco,wco]=size(collageImage);
if hco>wco
    squaredCollageImage=zeros(hco,hco);
else
    squaredCollageImage=zeros(wco,wco);
end
y = insertMatrix(squaredCollageImage, collageImage);
end
