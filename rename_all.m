function A=rename_all(imagefile)
A{:}=zeros(length(imagefile),1);
for i=1:length(imagefile)
    A{i}=imagefile{i,1};
end

end
