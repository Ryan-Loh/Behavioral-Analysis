function save_all_images(savParamStruct)
for i=1:size(savParamStruct,1)
    mini=abs(min(min(savParamStruct{i,1})));
    savParamStruct{i,1}=round(savParamStruct{i,1}.*2^16-1);
    imgaussfilt(savParamStruct{i,1},0.5);
    filename=sprintf('%s_%d.%s','Image',i,'tif')
    imwrite(savParamStruct{i,1},filename);
end
end
