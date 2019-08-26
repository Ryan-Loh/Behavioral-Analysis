function displayall(imagefile, rows, columns, screen);

for i=1:length(imagefile)
    [row, col] = size(imagefile{i,1});
    avg(1,i)=mean(mean(imagefile{i,1}));
    stad(1,i)=std(reshape(imagefile{i,1},1,row*col));
    imgaussfilt(imagefile{i,1},0.5);
    %LL(1,i)=avg(1,i)-4*stad(1,i);
    %UL(1,i)=avg(1,i)+0*stad(1,i);
    LL(1,i)=avg(1,i)-1.25e-4;
    UL(1,i)=avg(1,i)+1.25e-4;
    figure(i);
    %imshow(imagefile{i,1},[LL(1,i) UL(1,i)]);
    imshow(imagefile{i,1}, [LL(i) UL(i)]);
    %imagesc(imagefile{i,1})
    colorbar;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    title(sprintf('%s_%d','ISimage',i));
end
    autoArrangeFigures(rows,columns,screen);
end
